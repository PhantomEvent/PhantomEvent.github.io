import subprocess
import json

from slither.core.expressions.literal import Literal
from slither.core.expressions.type_conversion import TypeConversion
from slither.core.expressions.call_expression import CallExpression
from slither.core.expressions.unary_operation import UnaryOperation
from slither.core.expressions.binary_operation import BinaryOperation
from slither.core.expressions.assignment_operation import AssignmentOperation
from slither.analyses.data_dependency.data_dependency import get_dependencies


EQ = "=="
NEQ = "!="
GT = ">"
GEQ = ">="
LT = "<"
LEQ = "<="
AND = "&&"
OR = "||"
NOT = "!"
ADD_1 = "+"
ADD_2 = "++"
SUB = "-"
MULTIPLY = "*"
DIVIDE = "/"
MOD = "%"


def translateOpType(opType): 
    if opType == EQ:
        return "EQ"
    elif opType == NEQ:
        return "NEQ"
    elif opType == GT:
        return "GT"
    elif opType == GEQ:
        return  "GEQ"
    elif opType == LT:
        return "LT"
    elif opType == LEQ:
        return "LEQ"
    elif opType == AND:
        return "AND"
    elif opType == OR:
        return "OR"
    elif opType == NOT:
        return "NOT"
    elif opType == ADD_1 or opType == ADD_2:
        return "ADD"
    elif opType == SUB:
        return "SUB"
    elif opType == MULTIPLY:
        return "MUL"
    elif opType == DIVIDE:
        return "DIV"
    elif opType == MOD:
        return "MOD"
    else:
        print(opType)
        assert False  


# compile solidity to generate AST
def compile_and_get_ast(contract_path):
    # cmd = f'solc-select install 0.8.9 && solc-select use 0.8.9 && solc --ast-compact-json {contract_path}'
    cmd = f'solc-select use 0.8.9 && solc --ast-compact-json {contract_path}'
    result = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE)
    temp = '{' + result.stdout.decode().split('\n', 1)[1].split('{', 1)[1]
    ast_json = json.loads(temp)
    return ast_json


def processCondition(booleanExpression): 
    result = []
    result2 = []
    result2.append(str(booleanExpression).replace(" ", ""))
    print(result2)
    if isinstance(booleanExpression, BinaryOperation):
        opType = translateOpType(str(booleanExpression.type)) 
        left = processCondition(booleanExpression.expression_left)
        right = processCondition(booleanExpression.expression_right)
        result.append(str(opType))
        result.extend(left)
        result.extend(right)
        return result 
    elif isinstance(booleanExpression, Literal):
        result.append(str(booleanExpression))
        return result 
    elif isinstance(booleanExpression, TypeConversion):
        result.append(str(booleanExpression))
        return result
    elif isinstance(booleanExpression, CallExpression):
        result.append(str(booleanExpression))
        return result
    elif isinstance(booleanExpression, UnaryOperation):
        opType = translateOpType(str(booleanExpression.type)) 
        exp = booleanExpression.expression
        result.append(str(opType))
        result.append(str(exp))
        return result
    else:
        result.append(str(booleanExpression).replace(" ", ""))
        return result


def processConditionEasy(booleanExpression): 
    result = []
    result.append(str(booleanExpression).replace(" ", ""))
    return result


def processCall(Expression, call_info): 
    if isinstance(Expression, AssignmentOperation):
        processCall(Expression.expression_right, call_info)
    if isinstance(Expression, BinaryOperation):
        processCall(Expression.expression_left, call_info)
        processCall(Expression.expression_right, call_info)
    if isinstance(Expression, CallExpression):
        return_type = Expression.type_call
        func_str = str(Expression.called) + '('
        if len(Expression.arguments) == 0:
            func_str += ')'
        else:
            for index in range(0, len(Expression.arguments)):
                func_str += chr(ord('a') + index) + ','
            # print(func_str)
            func_str = func_str.strip()[: len(func_str) - 1] + ')'
            # print(func_str)
        func_str = func_str.replace('(', '_')
        func_str = func_str.replace(')', '_')
        func_str = func_str.replace('.', '_')
        func_str = func_str.replace(',', '_')
        if return_type == 'tuple()':
            call_info.append([str(Expression), 'None', func_str])
        else:
            call_info.append([str(Expression), return_type, func_str])


def getIDName(info):
    _num = 0
    loc = 0
    _loc = []
    while _num < 2 and loc < len(info):
        if(info[loc] == '_'):
            _num += 1
            _loc.append(loc)
        loc += 1
    if(len(_loc) == 2):
        id = info[_loc[0] + 1: _loc[1]]
        name = info[_loc[1] + 1:]
        return id, name
    else:
        return None, None
    

def getCallInfo(caller, id_name_dict):
    if '_' in caller:
        caller_id = caller.split('_')[0]
        caller_name = id_name_dict[caller_id]
        caller_node = caller + '_' + caller_name
    else:
        caller_node = caller + '_[Solidity]'

    return caller_node


def get_dependency_data(event_info, function):
    dependency_data = set()
    for event_arg in event_info[3]:
        dependency_data_arg = get_dependencies(event_arg, function)
        # print(dependency_data_arg)
        dependency_data.update(dependency_data_arg)
        dependency_data.add(event_arg)
    return dependency_data


def get_node_related_variable(node):
    opts = set()
    opts.update([str(i) for i in node.local_variables_read])
    opts.update([str(i) for i in node.local_variables_written])
    opts.update([str(i) for i in node.state_variables_read])
    opts.update([str(i) for i in node.state_variables_written])
    return opts
