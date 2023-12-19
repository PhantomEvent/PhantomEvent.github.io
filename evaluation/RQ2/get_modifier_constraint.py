import json

from slither import Slither
from slither.core.expressions.call_expression import CallExpression
from slither.core.expressions.binary_operation import BinaryOperation
from slither.core.expressions.assignment_operation import AssignmentOperation
from utils import processConditionEasy, get_node_related_variable

def getModifierConstraint(contract_path):
    contracts = Slither(contract_path)
    all_modifier = []
    identify = []

    for contract in contracts.contracts:
        for function in contract.functions:
            modifiers = function.modifiers
            if len(modifiers) == 0:
                continue
            for modifier in modifiers:
                all_vars = dict()
                for var in modifier.variables_read_or_written:
                    try:
                        if str(var.name) not in all_vars:
                        
                            all_vars[str(var.name)] = str(var.type)
                    except:
                        pass
                modifier_info = dict()
                if modifier.name in identify:
                    continue
                if modifier.name == "onlyOwner":
                    print("debug")
                identify.append(modifier.name)
                modifier_info["name"] = modifier.name
                modifier_info["arguments"] = []
                for parameter in modifier.parameters:
                    try:
                        modifier_info["arguments"].append(parameter.name + "--" + parameter.type.name)
                    except:
                        continue
                modifier_info["related_expression"] = []
                modifier_info["vars"] = all_vars
                modifier_info["related_expression_type"] = []
                for path_node in modifier.nodes:
                    isRequireOrAssert = path_node.contains_require_or_assert()
                    if isRequireOrAssert:
                        requireArguments = path_node.expression.arguments
                        require_condition = requireArguments[0]
                        # event_require_conditions.append(processConditionEasy(require_condition))
                        result = processConditionEasy(require_condition)
                        # call_info = []
                        # processCall(require_condition, call_info)
                        # event_expression['call_info'].append(call_info)
                        # for i in range(0, len(result)):
                        #     for call in call_info:
                        #         result[i] = result[i].replace(call[0], call[1] + '_' + call[2], 1)
                        for item in result:
                            modifier_info['related_expression'].append(item)
                            modifier_info['related_expression_type'].append("Condition")
                        continue
                    # get expression about data_dependency
                    '''
                    Expression = path_node.expression
                    if Expression is not None:
                        #print(str(Expression.type))
                        # CallExpression
                        parse_expressions = processConditionEasy(Expression)
                        # call_info = []
                        # processCall(Expression, call_info)
                        # print(call_info)
                        # event_expression['call_info'].append(call_info)
                        
                        for i in range(0, len(parse_expressions)):
                            
                            modifier_info['related_expression'].append(parse_expressions[i])
                                    
                            if isinstance(Expression,AssignmentOperation):
                                modifier_info['related_expression_type'].append("AssignmentOperation" + "_" + str(Expression.type))
                            elif isinstance(Expression,CallExpression):
                                modifier_info['related_expression_type'].append("CallExpression")
                            elif isinstance(Expression,BinaryOperation):
                                modifier_info['related_expression_type'].append("BinaryOperation")
                            else:
                                modifier_info['related_expression_type'].append("Expression")
                            break
                    '''
                        # print(opts)
                # output condition
                
                all_modifier.append(modifier_info)
                #print(event_expression['related_expression_type'])
                print("---------------------------")
        print("***************************")
    return all_modifier

if __name__ == "__main__":
    contract_path = r"/home/ubuntu/event/Bridge.sol"  # Solidity合约文件路径
    expression_path = r"./func_expression/Modifier_Bridge.json"
    # func_path = r"./func_expression/func_0x0ca553DE0599a79Aaf43943cf254E60183a0cCA3.json"
    res = getModifierConstraint(contract_path)
    # FCG = get_FCG(contract_path)
    json.dump(res, open(expression_path, 'w'))
    # json.dump(get_call_info, open(func_path, 'w'))