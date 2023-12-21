import json
from z3 import *
import sys
import symengine as se
from solver_utils import *


symbols, symbols_type, symbol_count, symbol_constraints, symbol_arrays, symbol_mappings = {}, {}, {}, [], {}, {}

function_stack = {}

f1_event, f1_vars, f1_parameters, f1_related_expressions, f1_related_expression_type, f1_modifier, f1_loop_num, f1_loop_flag, f1_loop_position = None, None, None, None, None, None, 1, False, None

f2_event, f2_vars, f2_parameters, f2_related_expressions, f2_related_expression_type, f2_modifier, f2_loop_num, f2_loop_flag, f2_loop_position = None, None, None, None, None, None, 1, False, None

pre_condition,event_expressions,return_expressions,modifier_expressions,type_expressions = None,None,None,None,None



f1_name = "burn"
f2_name = "burnFrom"
operator = ['+','-','*','/','>=','<=','=','==','%','(',')',"||","&&"]


def create_address_constraints(z3_var):
    constraints = []
    constraints.append(z3.Length(z3_var) == 42)
    constraints.append(z3.SubSeq(z3_var, 0, 2) == z3.StringVal('0x'))
    for i in range(2, 42):
        char = z3.SubSeq(z3_var, i, 1)
        constraints.append(z3.Or([char == z3.StringVal(c) for c in "0123456789abcdefABCDEF"]))

    return constraints

def create_numeric_constraints(z3_var: Int, bit_length: int, signed: bool = False) -> List:
    lower_bound = -2**(bit_length - 1) if signed else 0
    upper_bound = 2**bit_length - 1 if not signed else 2**(bit_length - 1) - 1
    return [z3_var >= lower_bound, z3_var <= upper_bound]


def is_function_call(s):
    # Pattern to identify function calls and capture function names and arguments
    pattern = r'(?:(?:[a-zA-Z_][a-zA-Z_0-9]*)\.)?([a-zA-Z_][a-zA-Z_0-9]*)\(([^\)]*)\)$'
    
    match = re.match(pattern, s)
    if match:
        # Extract the function name and arguments from the match
        function_name, arguments = match.groups()
        return function_name, arguments
    else:
        return None, None
    
def insert_uint(tmp_var):
    tmp_vars,tmp_contransts,tmp_symbol_arrays,tmp_symbol_mappings = create_symbolic(tmp_var,"uint")
    symbols.update(tmp_vars)
    symbol_constraints.extend(tmp_contransts)
    symbol_arrays.update(tmp_symbol_arrays)
    symbol_mappings.update(tmp_symbol_mappings)

def insert_array(tmp_var):
    tmp_vars,tmp_contransts,tmp_symbol_arrays,tmp_symbol_mappings = create_symbolic(tmp_var,is_array(symbol_arrays,tmp_var))
    symbols.update(tmp_vars)
    symbol_constraints.extend(tmp_contransts)
    symbol_arrays.update(tmp_symbol_arrays)
    symbol_mappings.update(tmp_symbol_mappings)



def create_symbolic(var: str, var_type: str) -> Tuple[Dict[str, Int], List]:
    z3_vars = {}
    z3_constraints = []
    arrays = {}
    mappings = {}

    symbols_type[var] = var_type
    if var_type == "bool":
        z3_vars[var] = Bool(var)
    elif var_type == "address":
        z3_vars[var] = String(var)
        z3_constraints.extend(create_address_constraints(z3_vars[var]))
    elif var_type in {"uint256", "uint"}:
        z3_vars[var] = Int(var)
        z3_constraints.extend(create_numeric_constraints(z3_vars[var], 256))
    elif var_type in {"int256", "int"}:
        z3_vars[var] = Int(var)
        z3_constraints.extend(create_numeric_constraints(z3_vars[var], 256, signed=True))
    elif var_type in {"int128", "uint128", "int64", "uint64", "int32", "uint32", "int16", "uint16", "int8", "uint8"}:
        bit_length = int(var_type[3:]) if var_type.startswith("int") else int(var_type[4:])
        z3_vars[var] = Int(var)
        z3_constraints.extend(create_numeric_constraints(z3_vars[var], bit_length, signed=var_type.startswith("int")))
    elif var_type.startswith('bytes'):
        bit_length = 8 * int(var_type[5:]) if var_type != "bytes" else 8
        z3_vars[var] = BitVec(var, bit_length)
    elif var_type == "string":
        z3_vars[var] = String(var)
    elif var_type[-1] == "]":
        array_type = var_type.split('[', 1)[0]
        arrays[var] = array_type
    elif var_type.startswith("mapping"):
        mappings[var] = var_type


    return z3_vars, z3_constraints,arrays,mappings


def read_json_file(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            return json.load(file)
    except FileNotFoundError:
        print(f"The file {file} was not found.")
        raise
    except json.JSONDecodeError:
        print("Failed to decode JSON.")
        raise
    
def Var_normalization(f_name, f_var, flag):
    if flag not in ['f1', 'f2']:
        raise ValueError("Flag must be 'f1' or 'f2'")

    return f"{flag}_{f_name}_{f_var}"

def Process_condition_expression(expr, z3_vars):
    expr = expr.replace(" ","")
    if '>=' in expr:
        token = expr.split(">=")
        if (token[1] in z3_vars):
            return z3_vars[token[0]] >= z3_vars[token[1]]
        else:
            return z3_vars[token[0]] >= token[1]
    elif '<=' in expr:
        token = expr.split("<=")
        if (token[1] in z3_vars):
            return z3_vars[token[0]] <= z3_vars[token[1]]
        else:
            return z3_vars[token[0]] <= token[1]
    elif '==' in expr:
        token = expr.split("==")
        if (token[1] in z3_vars):
            return z3_vars[token[0]] == z3_vars[token[1]]
        elif "keccak256(bytes)" in token[0]:
           match = re.search(r'keccak256\(bytes\)\(abi\.encodePacked\((.*)\)\)', token[0])
           token[0] = match.group(1)
           match = re.search(r'keccak256\(bytes\)\(abi\.encodePacked\((.*)\)\)', token[1])
           token[1] = match.group(1)
           if token[1] in z3_vars:
               return z3_vars[token[0]] == token[1]
           else:
               return z3_vars[token[0]] == StringVal(str(token[1]))
        else:
            return z3_vars[token[0]] == token[1]
    elif '!=' in expr:
        token = expr.split("!=")
        if (token[1] in z3_vars):
            return z3_vars[token[0]] != z3_vars[token[1]]
        elif "keccak256(bytes)" in token[0]:
           match = re.search(r'keccak256\(bytes\)\(abi\.encodePacked\((.*)\)\)', token[0])
           token[0] = match.group(1)
           match = re.search(r'keccak256\(bytes\)\(abi\.encodePacked\((.*)\)\)', token[1])
           token[1] = match.group(1)
           if token[1] in z3_vars:
               return z3_vars[token[0]] != token[1]
           else:
               return z3_vars[token[0]] != StringVal(str(token[1]))
        else:
            return z3_vars[token[0]] != token[1]
    elif '>' in expr:
        token = expr.split(">")
        if (token[1] in z3_vars):
            return z3_vars[token[0]] > z3_vars[token[1]]
        else:
            return z3_vars[token[0]] > token[1]
    elif '<' in expr:
        token = expr.split("<")
        if (token[1] in z3_vars):
            return z3_vars[token[0]] < z3_vars[token[1]]
        else:
            return z3_vars[token[0]] < token[1]
    return None

def parse_condition(condition, z3_vars):
    try:
        if condition.startswith("not(") and condition.endswith(")"):
            inner_expr = condition[4:-1]
            return Not(parse_condition(inner_expr, z3_vars))
        elif condition.startswith("(") and condition.endswith(")"):
            inner_expr = condition[1:-1]
            return parse_condition(inner_expr, z3_vars)
        elif "&&" in condition:
            parts = condition.split("&&")
            return And([parse_condition(part.strip(), z3_vars) for part in parts])
        elif "||" in condition:
            parts = condition.split("||") 
            return Or([parse_condition(part.strip(), z3_vars) for part in parts])
        elif condition.startswith("!"):
            inner_expr = condition[1:]
            return Not(parse_condition(inner_expr, z3_vars))
        else:
            return Process_condition_expression(condition, z3_vars)
    except:
        return None

def parse_arithmetic_expression(expr, z3_vars):
    expr = expr.replace(" ", "")

    while '(' in expr:
        match = re.search(r'\([^\(\)]*\)', expr)
        if match:
            sub_expr = match.group(0)[1:-1] 
            sub_result = parse_arithmetic_expression(sub_expr, z3_vars)
            expr = expr.replace(match.group(0), str(sub_result), 1)

    if '+' in expr:
        parts = expr.split('+')
        return parse_arithmetic_expression(parts[0].strip(), z3_vars) + parse_arithmetic_expression(parts[1].strip(), z3_vars)
    elif '-' in expr:
        parts = expr.split('-')
        return parse_arithmetic_expression(parts[0].strip(), z3_vars) - parse_arithmetic_expression(parts[1].strip(), z3_vars)
    elif '*' in expr:
        parts = expr.split('*')
        return parse_arithmetic_expression(parts[0].strip(), z3_vars) * parse_arithmetic_expression(parts[1].strip(), z3_vars)
    elif '/' in expr:
        parts = expr.split('/')
        return parse_arithmetic_expression(parts[0].strip(), z3_vars) / parse_arithmetic_expression(parts[1].strip(), z3_vars)
    else:
        if expr.isdigit():
            return int(expr)
        elif expr in z3_vars:
            return z3_vars[expr]
        else:
            raise ValueError(f"Error: {expr}")


def parse_assignment(expression, z3_vars):
    lhs, rhs = [e.strip() for e in expression.split('==')]
    return z3_vars[lhs] == parse_arithmetic_expression(rhs, z3_vars)



def parse_expression1(expression,index):
    try:
        if f1_related_expression_type[index] == "Condition":
            symbol_constraints.append(parse_condition(expression,symbols))
        else:
            symbol_constraints.append(parse_assignment(expression,symbols))
    except:
        return None

def parse_expression2(expression,index):
    try:
        if f2_related_expression_type[index] == "Condition":
            symbol_constraints.append(parse_condition(expression,symbols))
        else:
            symbol_constraints.append(parse_assignment(expression,symbols))
    except:
        return None

def process_modifier(f_name,modifier_name,f_flag):
    for modifier in modifier_expressions:
        if modifier["name"] == modifier_name:
            modifier_related_expression = modifier["related_expression"]
            if modifier_related_expression == None:
                return
            modifier_vars = modifier["vars"]
            modifier_related_expression_type = modifier["related_expression_type"]
            for var in modifier_vars:
                var1 = Var_normalization(f_name,var,f_flag)
                if var1 not in symbols:
                    tmp_vars,tmp_contransts,tmp_symbol_arrays,tmp_symbol_mappings = create_symbolic(var1,modifier_vars[var])
                    symbols.update(tmp_vars)
                    symbol_constraints.extend(tmp_contransts)
                    symbol_arrays.update(tmp_symbol_arrays)
                    symbol_mappings.update(tmp_symbol_mappings)

            for index1,expression in enumerate(modifier_related_expression):
                not_flag = False
                #print(expression)
                if expression.startswith("not("):
                    not_flag = True
                    expression = expression.replace('not(','')
                    expression[-1] = ""

                tmp_expression = convert_compound_to_regular(expression)
                tmp_format_expression = format_solidity_expressions(tmp_expression)

                tmp_format_expression = tmp_format_expression.split(" ")

                for index2, var in enumerate(tmp_format_expression):
                    if var[0] == '!':
                        var = var[1:]
                    if (not var or var.isspace()):
                        continue
                    if var == '=':
                        tmp_format_expression[index2] = "=="
                        continue
                    if var in operator:
                        continue          
                    else:
                        if is_constant(var):
                            continue
                        else:
                            tmp_var = Var_normalization(f_name,var,f_flag)
                            #print(tmp_var)
                            if tmp_var in symbols:
                                #print(tmp_var)
                                if tmp_var in symbol_count:
                                    #print(tmp_var)
                                    symbol_count[tmp_var.strip()] += 1
                                    new_symbloic = str(tmp_var.strip())+"_"+str(symbol_count[tmp_var.strip()])
                                    tmp_vars,tmp_contransts,tmp_symbol_arrays,tmp_symbol_mappings = create_symbolic(new_symbloic,symbols_type[tmp_var])
                                    symbols.update(tmp_vars)
                                    symbol_constraints.extend(tmp_contransts)
                                    symbol_arrays.update(tmp_symbol_arrays)
                                    symbol_mappings.update(tmp_symbol_mappings)
                                    tmp_format_expression[index2] = new_symbloic
                                   # symbol_constraints.append(symbols[tmp_var] == symbols[new_symbloic])

                                else:
                                        #print(tmp_var)
                                        symbol_count[tmp_var.strip()] = 1
                                        tmp_format_expression[index2] = tmp_var
                                        #print(tmp_format_expression)

                            else:
                                #print(tmp_var)
                                if is_array(symbol_arrays,tmp_var) != None:
                                    #print(tmp_var)
                                    tmp_format_expression[index2] = tmp_var
                        
                                    tmp_vars,tmp_contransts,tmp_symbol_arrays,tmp_symbol_mappings = create_symbolic(tmp_var,is_array(symbol_arrays,tmp_var))
                                    symbols.update(tmp_vars)
                                    symbol_constraints.extend(tmp_contransts)
                                    symbol_arrays.update(tmp_symbol_arrays)
                                    symbol_mappings.update(tmp_symbol_mappings)

                                elif is_mapping(symbol_mappings,tmp_var):
                                    #print(tmp_var)
                                    tmp_format_expression[index2] = tmp_var
                                    insert_uint(tmp_var)

                                else:
                                    #print(tmp_var)
                                    tmp_format_expression[index2] = tmp_var
                                    insert_uint(tmp_var)               
  

                #print(tmp_format_expression)
                tmp_format_expression = ''.join(tmp_format_expression)
                tmp_format_expression = format_solidity_expressions(tmp_format_expression)       
                #print(tmp_format_expression)
                if not_flag:
                    tmp_format_expression = "not( " + tmp_format_expression + " )"

                if modifier_related_expression_type[index1] == "Condition":
                    tmp = parse_condition(tmp_format_expression,symbols)
                    if tmp!= None:
                        symbol_constraints.append(parse_condition(tmp_format_expression,symbols))
                #symbol_constraints.append(parse_condition(tmp_format_expression,symbols))
                else:
                    tmp = parse_assignment(tmp_format_expression,symbols)
                    if tmp!= None:
                        symbol_constraints.append(parse_assignment(tmp_format_expression,symbols))


def process_loop(f_name,f_flag,process_position,process_expressions,process_expression_types):
    try:
        for position in range(process_position[0],process_position[-1]+1):
            not_flag = False
            expression = process_expressions[position]
            if expression.startswith("not("):
                not_flag = True
                expression = expression.replace('not(','')
                expression[-1] = ""

            tmp_expression = convert_compound_to_regular(expression)

            tmp_format_expression = format_solidity_expressions(tmp_expression)

            tmp_format_expression = tmp_format_expression.split(" ")

            for index2, var in enumerate(tmp_format_expression):
                if (not var or var.isspace()):
                    continue
                if var == '=':
                    tmp_format_expression[index2] = "=="
                    continue
                if var in operator:
                    continue

                else:
                    if is_constant(var):
                        continue
                    tmp_var = Var_normalization(f_name,var,f_flag)
                    if tmp_var in symbols:
                    
                        if tmp_var in symbol_count:
                            symbol_count[tmp_var.strip()] += 1
                            new_symbloic = str(tmp_var.strip())+"_"+str(symbol_count[tmp_var.strip()])
                            tmp_vars,tmp_contransts,tmp_symbol_arrays,tmp_symbol_mappings = create_symbolic(new_symbloic,symbols_type[tmp_var])
                            symbols.update(tmp_vars)
                            symbol_constraints.extend(tmp_contransts)
                            symbol_arrays.update(tmp_symbol_arrays)
                            symbol_mappings.update(tmp_symbol_mappings)
                            tmp_format_expression[index2] = new_symbloic

                        else:
                            symbol_count[tmp_var.strip()] = 1
                            tmp_format_expression[index2] = tmp_var

                    else:
                        if is_array(symbol_arrays,tmp_var) != None:
                                tmp_format_expression[index2] = tmp_var
                                insert_array(tmp_var)

                        elif is_mapping(symbol_mappings,tmp_var):
                                tmp_format_expression[index2] = tmp_var
                                insert_uint(tmp_var)

                        else:
                            function_name, function_parameters = is_function_call(var)
                            if function_name != None:
                                process_function(function_name,function_parameters,f1_name,"f1",tmp_var)
                            else:
                                tmp_format_expression[index2] = tmp_var
                                insert_uint(tmp_var)         

            tmp_format_expression = ''.join(tmp_format_expression)
            tmp_format_expression = format_solidity_expressions(tmp_format_expression)

            if not_flag:
                tmp_format_expression = "not( " + tmp_format_expression + " )"

            if process_expression_types[position] == "condition":
                tmp = parse_condition(tmp_format_expression,symbols)
                if tmp != None:
                    symbol_constraints.append(parse_condition(tmp_format_expression,symbols))
            else:
                tmp = parse_assignment(tmp_format_expression,symbols)
                if tmp != None:
                    symbol_constraints.append(parse_condition(tmp_format_expression,symbols))
    except:
        return None
    

def function_constraints(f_flag,expressions,expression_types,s_function,p_name,s_parameters,p_parameters,p_vars,overall,return_exp):
    for var in p_vars:
        var1 = Var_normalization(p_name,var,f_flag)
        tmp_vars,tmp_contransts,tmp_symbol_arrays,tmp_symbol_mappings = create_symbolic(var1,p_vars[var])
        symbols.update(tmp_vars)
        symbol_constraints.extend(tmp_contransts)
        symbol_arrays.update(tmp_symbol_arrays)
        symbol_mappings.update(tmp_symbol_mappings)

    if s_parameters != "[]":
        for i in range(len(s_parameters)):
            var1 = Var_normalization(s_function,p_parameters[i],f_flag)
            var2 = Var_normalization(p_name,s_parameters[i],f_flag)

            if var1 not in symbols:
                insert_uint(var1)
        
            if var2 not in symbols:
                insert_uint(var2)

            if var1 in symbols and symbol_count[var1.strip()]!= None:
                var1 = str(var1.strip())+"_"+str(f1_parameter[tmp_var.strip()])
            
            if var1 in symbols and symbol_count[var1.strip()]!= None:
                var2 = str(var2.strip())+"_"+str(f2_parameter[tmp_var.strip()])

            tmp_constraint  = str(var1) + " " + "==" + " " + str(var2)
            tmp = parse_assignment(tmp_constraint,symbols)
            symbol_constraints.append(tmp)

    insert_uint(overall)

    for index1,expression in enumerate(expressions):

        not_flag = False
        if expression.startswith("not("):
            not_flag = True
            expression = expression.replace('not(','')
            expression[-1] = ""

        tmp_expression = convert_compound_to_regular(expression)
        tmp_format_expression = format_solidity_expressions(tmp_expression)

        tmp_format_expression = tmp_format_expression.split(" ")

        for index2, var in enumerate(tmp_format_expression):
            if (not var or var.isspace()):
                continue
            if var == '=':
                tmp_format_expression[index2] = "=="
                continue
            if var in operator:
                continue
            else:
                if is_constant(var):
                    continue
                else:
                    tmp_var = Var_normalization(f1_name,var,"f1")
                    if tmp_var in symbols:
                    
                        if tmp_var in symbol_count:
                            symbol_count[tmp_var.strip()] += 1
                            new_symbloic = str(tmp_var.strip())+"_"+str(symbol_count[tmp_var.strip()])
                            tmp_vars,tmp_contransts,tmp_symbol_arrays,tmp_symbol_mappings = create_symbolic(new_symbloic,symbols_type[tmp_var])
                            symbols.update(tmp_vars)
                            symbol_constraints.extend(tmp_contransts)
                            symbol_arrays.update(tmp_symbol_arrays)
                            symbol_mappings.update(tmp_symbol_mappings)
                            tmp_format_expression[index2] = new_symbloic

                        else:
                            symbol_count[tmp_var.strip()] = 1
                            tmp_format_expression[index2] = tmp_var
                    

                    else:
                        if is_array(symbol_arrays,tmp_var) != None:
                                tmp_format_expression[index2] = tmp_var
                                insert_array(tmp_var)

                        elif is_mapping(symbol_mappings,tmp_var):
                                tmp_format_expression[index2] = tmp_var
                                insert_uint(tmp_var)

                        else:
                            function_name, function_parameters = is_function_call(var)
                            if function_name != None:
                                process_function(function_name,function_parameters,f1_name,"f1",tmp_var)
                            else:
                                tmp_format_expression[index2] = tmp_var
                                insert_uint(tmp_var)                

        tmp_format_expression = ''.join(tmp_format_expression)
        tmp_format_expression = format_solidity_expressions(tmp_format_expression)

        if not_flag:
            tmp_format_expression = "not( " + tmp_format_expression + " )"
        
        if expression_types[index1] == "Condition":
            symbol_constraints.append(parse_condition(tmp_format_expression,symbols))
        else:
            symbol_constraints.append(parse_assignment(tmp_format_expression,symbols))

        


    for expression in return_exp:
        tmp_expression = convert_compound_to_regular(expression)
        tmp_format_expression = format_solidity_expressions(tmp_expression)

        tmp_format_expression = tmp_format_expression.split(" ")

        for index2, var in enumerate(tmp_format_expression):
            if (not var or var.isspace()):
                continue
            if var == '=':
                tmp_format_expression[index2] = "=="
                continue
            if var in operator:
                continue
            else:
                if is_constant(var):
                    continue
            
                else:
                    tmp_var = Var_normalization(f1_name,var,"f1")
                    if tmp_var in symbols:
                    
                        if tmp_var in symbol_count:
                            symbol_count[tmp_var.strip()] += 1
                            new_symbloic = str(tmp_var.strip())+"_"+str(symbol_count[tmp_var.strip()])
                            tmp_vars,tmp_contransts,tmp_symbol_arrays,tmp_symbol_mappings = create_symbolic(new_symbloic,symbols_type[tmp_var])
                            symbols.update(tmp_vars)
                            symbol_constraints.extend(tmp_contransts)
                            symbol_arrays.update(tmp_symbol_arrays)
                            symbol_mappings.update(tmp_symbol_mappings)
                            tmp_format_expression[index2] = new_symbloic

                        else:
                            symbol_count[tmp_var.strip()] = 1
                            tmp_format_expression[index2] = tmp_var
                    

                    else:
                        if is_array(symbol_arrays,tmp_var) != None:
                                tmp_format_expression[index2] = tmp_var
                                insert_array(tmp_var)

                        elif is_mapping(symbol_mappings,tmp_var):
                                tmp_format_expression[index2] = tmp_var
                                insert_uint(tmp_var)

                        else:
                            function_name, function_parameters = is_function_call(var)
                            if function_name != None:
                                process_function(function_name,function_parameters,f1_name,"f1",tmp_var)
                            else:
                                tmp_format_expression[index2] = tmp_var
                                insert_uint(tmp_var)                

        tmp_format_expression = ''.join(tmp_format_expression)
        tmp_format_expression = format_solidity_expressions(tmp_format_expression)


        tmp_format_expression = str(overall) + " == " + tmp_format_expression
        symbol_constraints.append(parse_assignment(tmp_format_expression,symbols))
    


def process_function(p_name,f_parameters,s_function,f_flag,overall):
    exist_flag = False
    for return_expression in return_expressions:
        if exist_flag:
            break
        if p_name == return_expression["info"][1]:
            for i in type_expressions["interface"]:
                if p_name == i["name"]:
                    insert_uint(overall)
                    return
            for i in type_expressions["library"]:
                if p_name == i["name"]:
                    if i["return_type"] == ["bool"] or i["return_type"] == []:
                        insert_uint(overall)
                        return
            
            for i in type_expressions["function"]:
                if p_name == i["name"]:
                    if i["return_type"] == ["bool"] or i["return_type"] == []:
                        insert_uint(overall)
                        return

            function_constraints(f_flag,return_expression["related_expression"],return_expression['related_expression_type'],s_function,p_name,f_parameters,return_expression["info"][2:],return_expression["vars"],overall,return_expression["return_expressions"])
            exist_flag = True
    if exist_flag == False:
        insert_uint(overall)

    

if __name__ == '__main__':
    try:
        event_expressions_file = 'event_expressions/1_ORCToken.json'
        return_expressions_file = 'return_expressions/1_ORCToken.json'
        modifier_expressions_file = 'modifier_expressions/1_ORCToken.json'
        type_expressions_file = 'type_expressions/1_ORCToken.json'
        pre_condition_file = "./pre_function.json"


        event_expressions = read_json_file(event_expressions_file)
        return_expressions = read_json_file(return_expressions_file)
        modifier_expressions = read_json_file(modifier_expressions_file)
        type_expressions = read_json_file(type_expressions_file)
        pre_condition = read_json_file(pre_condition_file)

#Analysis function pair (pair can be found in final_sameEvent.sjon)

        if f1_name == f2_name:
            print("Please input two functions")
            sys.exit()


        for function in event_expressions:
            if (function["info"][1] == f1_name):
                f1_event = function["info"][2]
                f1_vars = function["vars"]
                f1_parameters = function["info"][3]
                f1_related_expressions = function["related_expression"]
                f1_related_expression_type = function["related_expression_type"]
                f1_modifier = function["modifier"]
                f1_loop_flag = function["isloop"]
                f1_loop_position = function["loop_info"]
                f1_related_expressions,f2_related_expression_type = remove_modifier(f1_modifier,f1_related_expressions,f1_related_expression_type)
            
            if (function["info"][1] == f2_name): 
                f2_event = function["info"][2]
                f2_vars = function["vars"]
                f2_parameters = function["info"][3]
                f2_related_expressions = function["related_expression"]
                f2_related_expression_type = function["related_expression_type"]
                f2_modifier = function["modifier"]
                f2_loop_flag = function["isloop"]
                f2_loop_position = function["loop_info"]
                f2_related_expressions,f2_related_expression_type = remove_modifier(f2_modifier,f2_related_expressions,f2_related_expression_type)
    
        if f1_event == None or f2_event == None or f1_event != f2_event:
            print("Please input a right pair")
            sys.exit()
    
# create symbloc 
# symbolc: fx + function_name + vars_name
        
        for var in f1_vars:
            var1 = Var_normalization(f1_name,var,"f1")
            tmp_vars,tmp_contransts,tmp_symbol_arrays,tmp_symbol_mappings = create_symbolic(var1,f1_vars[var])
            symbols.update(tmp_vars)
            symbol_constraints.extend(tmp_contransts)
            symbol_arrays.update(tmp_symbol_arrays)
            symbol_mappings.update(tmp_symbol_mappings)

        for var in f2_vars:
            var2 = Var_normalization(f2_name,var,"f2")
            tmp_vars,tmp_contransts,tmp_symbol_arrays,tmp_symbol_mappings = create_symbolic(var2,f2_vars[var])
            symbols.update(tmp_vars)
            symbol_constraints.extend(tmp_contransts)
            symbol_arrays.update(tmp_symbol_arrays)
            symbol_mappings.update(tmp_symbol_mappings)

        for modifier_name in f1_modifier:
            process_modifier(f1_name,modifier_name,"f1")

        for modifier_name in f2_modifier:
            process_modifier(f2_name,modifier_name,"f2")


#process pre-function
        if pre_condition != None:
            for var in pre_condition["vars"]:
                tmp_vars,tmp_contransts,tmp_symbol_arrays,tmp_symbol_mappings = create_symbolic(var,pre_condition["vars"][var])
                symbols.update(tmp_vars)
                symbol_constraints.extend(tmp_contransts)
                symbol_arrays.update(tmp_symbol_arrays)
                symbol_mappings.update(tmp_symbol_mappings)

            for index,expression in enumerate(pre_condition["constraints"]):
                if pre_condition["constraint_types"][index] == "Condition":
                    tmp_format_expression = format_solidity_expressions(expression)
                    symbol_constraints.append(parse_condition(tmp_format_expression,symbols))
                else:
                    tmp_format_expression = convert_compound_to_regular(expression)
                    tmp_format_expression = format_solidity_expressions(tmp_format_expression)
                    symbol_constraints.append(parse_assignment(tmp_format_expression,symbols))
                    

                
# process f1
    
        for index1,expression in enumerate(f1_related_expressions):

            not_flag = False
            if expression.startswith("not("):
                not_flag = True
                expression = expression.replace('not(','')
                expression[-1] = ""

            tmp_expression = convert_compound_to_regular(expression)
            tmp_format_expression = format_solidity_expressions(tmp_expression)

            tmp_format_expression = tmp_format_expression.split(" ")

    #print(tmp_format_expression)
            for index2, var in enumerate(tmp_format_expression):
                if (not var or var.isspace()):
                    continue
                if var == '=':
                    tmp_format_expression[index2] = "=="
                    continue
                if var in operator:
                    continue
                else:
                    if is_constant(var):
                        continue
                    else:
                        tmp_var = Var_normalization(f1_name,var,"f1")
                        if tmp_var in symbols:
                    
                            if tmp_var in symbol_count:
                                symbol_count[tmp_var.strip()] += 1
                                new_symbloic = str(tmp_var.strip())+"_"+str(symbol_count[tmp_var.strip()])
                                tmp_vars,tmp_contransts,tmp_symbol_arrays,tmp_symbol_mappings = create_symbolic(new_symbloic,symbols_type[tmp_var])
                                symbols.update(tmp_vars)
                                symbol_constraints.extend(tmp_contransts)
                                symbol_arrays.update(tmp_symbol_arrays)
                                symbol_mappings.update(tmp_symbol_mappings)
                                tmp_format_expression[index2] = new_symbloic

                            else:
                                symbol_count[tmp_var.strip()] = 1
                                tmp_format_expression[index2] = tmp_var
                    

                        else:
                            if is_array(symbol_arrays,tmp_var) != None:
                                    tmp_format_expression[index2] = tmp_var
                                    insert_array(tmp_var)

                            elif is_mapping(symbol_mappings,tmp_var):
                                    tmp_format_expression[index2] = tmp_var
                                    insert_uint(tmp_var)

                            else:
                                function_name, function_parameters = is_function_call(var)
                                if function_name != None:
                                    process_function(function_name,function_parameters,f1_name,"f1",tmp_var)
                                else:
                                    tmp_format_expression[index2] = tmp_var
                                    insert_uint(tmp_var)                

            tmp_format_expression = ''.join(tmp_format_expression)
            tmp_format_expression = format_solidity_expressions(tmp_format_expression)

            if not_flag:
                tmp_format_expression = "not( " + tmp_format_expression + " )"
            parse_expression1(tmp_format_expression,index1)

        if f1_loop_flag == True:
            for i in range(f1_loop_num-1):
                process_loop(f1_name,"f1",f1_loop_position,f1_related_expressions,f1_related_expression_type)

# process f2

        for index1,expression in enumerate(f2_related_expressions):

            not_flag = False
            if expression.startswith("not("):
                not_flag = True
                expression = expression.replace('not(','')
                expression[-1] = ""

            tmp_expression = convert_compound_to_regular(expression)

            tmp_format_expression = format_solidity_expressions(tmp_expression)

            tmp_format_expression = tmp_format_expression.split(" ")    

            for index2, var in enumerate(tmp_format_expression):
                if (not var or var.isspace()):
                    continue
                if var == '=':
                    tmp_format_expression[index2] = "=="
                    continue
                if var in operator:
                    continue
                else:
                    if is_constant(var):
                        continue
                    else:
                        tmp_var = Var_normalization(f2_name,var,"f2")
                        if tmp_var in symbols:

                            if tmp_var in symbol_count:
                                symbol_count[tmp_var.strip()] += 1
                                new_symbloic = str(tmp_var.strip())+"_"+str(symbol_count[tmp_var.strip()])
                                tmp_vars,tmp_contransts,tmp_symbol_arrays,tmp_symbol_mappings = create_symbolic(new_symbloic,symbols_type[tmp_var])
                                symbols.update(tmp_vars)
                                symbol_constraints.extend(tmp_contransts)
                                symbol_arrays.update(tmp_symbol_arrays)
                                symbol_mappings.update(tmp_symbol_mappings)
                                tmp_format_expression[index2] = new_symbloic

                            else:
                                symbol_count[tmp_var.strip()] = 1
                                tmp_format_expression[index2] = tmp_var

                        else:
                            if is_array(symbol_arrays,tmp_var) != None:
                                    tmp_format_expression[index2] = tmp_var
                                    insert_array(tmp_var)

                            elif is_mapping(symbol_mappings,tmp_var):
                                    tmp_format_expression[index2] = tmp_var
                                    insert_uint(tmp_var)

                            else:
                                function_name, function_parameters = is_function_call(var)
                                if function_name != None:
                                    process_function(function_name,function_parameters,f2_name,"f2",tmp_var)
                                else:
                                    tmp_format_expression[index2] = tmp_var
                                    insert_uint(tmp_var)

                            
            tmp_format_expression = ''.join(tmp_format_expression)
            tmp_format_expression = format_solidity_expressions(tmp_format_expression)
            if not_flag:
                tmp_format_expression = "not( " + tmp_format_expression + " )"
            parse_expression2(tmp_format_expression,index1)
    
        if f2_loop_flag == True:
            for i in range(f2_loop_num-1):
                process_loop(f2_name,"f2",f2_loop_position,f2_related_expressions,f2_related_expression_type)

# check parameters

        for i in range(0,len(f1_parameters)):
            solver = Solver()
            compare_symbols = symbols
            compare_constraints = symbol_constraints
            f1_var = f1_parameters[i].split("--")
            f2_var = f2_parameters[i].split("--")

            if f1_var[1] == "variables":
                f1_parameter = Var_normalization(f1_name,f1_var[0],"f1")
                if f1_parameter in symbols:
                    if f1_parameter.strip() not in symbol_count:
                        pass
                    elif symbol_count[f1_parameter.strip()] == 1:
                        pass
                    else:
                        f1_parameter = str(f1_parameter.strip())+"_"+str(symbol_count[f1_parameter.strip()])
                else:
                    tmp_vars,tmp_contransts,tmp_symbol_arrays,tmp_symbol_mappings = create_symbolic(f1_parameter,"uint")
                    compare_symbols.update(tmp_vars)
                    compare_constraints.extend(tmp_contransts)
        
            if f2_var[1] == "variables":
                f2_parameter = Var_normalization(f2_name,f2_var[0],"f2")
                if f2_parameter in symbols:
                    if f2_parameter.strip() not in symbol_count:
                        pass
                    elif symbol_count[f2_parameter.strip()] == 1:
                        pass
                    else:
                        f2_parameter = str(f2_parameter.strip())+"_"+str(symbol_count[f2_parameter.strip()])
                else:
                    tmp_vars,tmp_contransts,tmp_symbol_arrays,tmp_symbol_mappings = create_symbolic(f2_parameter,"uint")
                    compare_symbols.update(tmp_vars)
                    compare_constraints.extend(tmp_contransts)


            if f1_var[1] == f2_var[1]:
                if f1_var[1] == "variables":
                    compare_constraints.append(symbols[f1_parameter] == symbols[f2_parameter])
                else:
                    compare_constraints.append(f1_var[0] == f2_var[0])
            else:
                if f1_var[1] == "variables":
                    compare_constraints.append(symbols[f1_parameter] == f2_var[0])
                else:
                    compare_constraints.append(symbols[f2_parameter] == f1_var[0])
    
            solver.add(compare_constraints)
            if solver.check() == z3.sat:
                print("Potential phantom parameter: " + str(i))
    except:
        print("error")