from doctest import debug
import json
from slither import Slither
from slither.slithir.variables.constant import Constant
from slither.slithir.variables.reference import ReferenceVariable
from slither.slithir.operations.return_operation import Return
from slither.core.expressions.call_expression import CallExpression
from slither.core.expressions.binary_operation import BinaryOperation
from slither.core.expressions.assignment_operation import AssignmentOperation
from slither.core.cfg.node import NodeType
from slither.analyses.data_dependency.data_dependency import get_dependencies

from graph_function import get_Graph, find_path, plot_CFG, plot_FCG
from utils import processConditionEasy, get_node_related_variable


def getReturnNode(function):
    res = []
    for node in function.nodes:
        for ir in node.irs:
            if isinstance(ir, Return):
                res.append(node)
    return res


def getReturnConstraint(contract_path):
    contracts = Slither(contract_path)
    all_func = []
    func_type = dict()

    for contract in contracts.contracts:
        for function in contract.functions:
            
            func_new_str = []
            func_info = contract.name + " " + function.name
            func_new_str.append(contract.name + '.' + function.name)
            for arg in function.parameters:
                func_info += " " + str(arg)
                func_new_str.append(str(arg.type))
            if contract._is_interface:
                func_type[func_info] = 'interface'
            elif contract._is_library:
                func_type[func_info] = 'library'
            else:
                func_type[func_info] = 'function'

    for contract in contracts.contracts:
        '''
        if contract._is_interface:
            continue
        '''
        for function in contract.functions:
            '''
            if function.return_type == None:
                continue
            '''
            
            all_vars = dict()
            for parameter in function.variables_read:
                try:
                    if str(parameter.name) not in all_vars:
                        
                            all_vars[str(parameter.name)] = str(parameter.type)
                except:
                    pass
                        # print((str(parameter.name) + " "+str(parameter.type)))
            for parameter in function.variables_written:
                try:
                    if str(parameter.name) not in all_vars:
                        
                            all_vars[str(parameter.name)] = str(parameter.type)
                except:
                    pass
            return_vars = function.return_values
            dep_datas = set()
            for return_var in return_vars:
                dep_data = get_dependencies(return_var, function)
                dep_datas.update(dep_data)
                dep_datas.add(return_var)
            dep_datas = [str(i) for i in dep_datas]
            if len(function.nodes) == 0:
                continue
            func_cfg = get_Graph(function)
            ret_nodes = getReturnNode(function)
            if function.name == "submitTransaction":
                print("debug")
                plot_CFG(func_cfg)
            if len(ret_nodes) == 0:
                continue
            paths = []
            for ret_node in ret_nodes:
                pathss, new_dependency = find_path(func_cfg, function.nodes[0], ret_node)
                dep_datas.extend(new_dependency)
                paths.extend(pathss)
            
            if contract.name == 'Address' and function.name == 'functionCall':
                #plot_CFG(func_cfg)
                print('debug')
            
            for path in paths:
                event_expression = dict()
                event_expression["visibility"] = function.visibility
                event_expression["return_vars"] = []
                event_expression["modifier"] = [modifier.name for modifier in function.modifiers]
                event_expression["return_expressions"] = []
                event_expression["info"] = [contract.name, function.name]
                for arg in function.parameters:
                    event_expression["info"].append(str(arg))
                event_expression["vars"] = all_vars
                event_expression["loop_info"] = []
                event_expression['related_expression'] = []
                event_expression['related_expression_type'] = []
                # event_expression['call_info'] = []
                print(event_expression["info"])
                # event_conditions = []
                # event_require_conditions = []
                for path_node in path:
                    #print(str(path_node.expression)+ "   type    " + str(path_node.type))
                    if path_node in ret_nodes:
                        event_expression["return_vars"] = []
                        ret_expressions = processConditionEasy(path_node.expression)
                        event_expression["return_expressions"] = ret_expressions
                        for ret in path_node.local_variables_read:
                            if isinstance(ret, Constant):
                                event_expression["return_vars"].append(str(ret) + "--" + str(ret.type))
                            elif isinstance(ret, ReferenceVariable):
                                event_expression["return_vars"].append(ret.points_to.name + "_element" + "--variables")
                            else:
                                event_expression["return_vars"].append(str(ret) + "--variables")
                        continue
                    # get condition in IF
                    # add_reference_from_raw_source
                    if path_node.type == NodeType.STARTLOOP:
                        event_expression["isloop"] = True
                        event_expression["loop_info"].append(len(event_expression['related_expression']))
                        # event_expression['related_expression'].append("BEGIN_LOOP")
                        continue
                    if path_node.type == NodeType.ENDLOOP:
                        # event_expression['related_expression'].append("END_LOOP")
                        event_expression["loop_info"].append(len(event_expression['related_expression']) - 1)
                        continue
                    isIf = path_node.contains_if(include_loop=True)
                    if isIf:
                        edge_info = ''
                        sons = list(func_cfg.successors(path_node))
                        for son in sons:
                            if son in path:
                                edge_info = func_cfg.get_edge_data(path_node, son)['branch']
                                if edge_info == 'true':
                                    break
                        booleanExpression = path_node.expression
                        result = processConditionEasy(booleanExpression=booleanExpression)
                        # call_info = []
                        # processCall(booleanExpression, call_info)
                        # event_expression['call_info'].append(call_info)
                        if edge_info == 'false':
                            for i in range(0, len(result)):
                                # for call in call_info:
                                #     result[i] = result[i].replace(call[0], call[1] + '_' + call[2], 1)
                                result[i] = 'not(' + result[i] + ')'
                        # event_conditions.append(result)
                        for item in result:
                            event_expression['related_expression'].append(item)
                            event_expression['related_expression_type'].append("Condition")
                        continue
                    # get condition in require and assert
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
                            event_expression['related_expression'].append(item)
                            event_expression['related_expression_type'].append("Condition")
                        continue
                    # get expression about data_dependency
                    Expression = path_node.expression
                    if Expression is not None:
                        #print(str(Expression.type))
                        # CallExpression
                        parse_expressions = processConditionEasy(Expression)
                        # call_info = []
                        # processCall(Expression, call_info)
                        # print(call_info)
                        # event_expression['call_info'].append(call_info)
                        opts = get_node_related_variable(path_node)
                        dumped = False
                        for i in range(0, len(parse_expressions)):
                            for opt in opts:
                                if opt in dep_datas:
                                    # for call in call_info:
                                    #     parse_expressions[i] = parse_expressions[i].replace(call[0], call[1] + '_' + call[2], 1)
                                    event_expression['related_expression'].append(parse_expressions[i])
                                    dumped = True
                                    if isinstance(Expression,AssignmentOperation):
                                        event_expression['related_expression_type'].append("AssignmentOperation" + "_" + str(Expression.type))
                                    elif isinstance(Expression,CallExpression):
                                        event_expression['related_expression_type'].append("CallExpression")
                                    elif isinstance(Expression,BinaryOperation):
                                        event_expression['related_expression_type'].append("BinaryOperation")
                                    else:
                                        event_expression['related_expression_type'].append("Expression")
                                    break
                        # print(opts)
                # output condition
                
                all_func.append(event_expression)
                #print(event_expression['related_expression_type'])
                print("---------------------------")
        print("***************************")
    return all_func


if __name__ == "__main__":
    contract_path = r"/home/ubuntu/event/Bridge.sol"  # Solidity合约文件路径
    expression_path = r"./func_expression/Bridge.json"
    # func_path = r"./func_expression/func_0x0ca553DE0599a79Aaf43943cf254E60183a0cCA3.json"
    res = getReturnConstraint(contract_path)
    # FCG = get_FCG(contract_path)
    json.dump(res, open(expression_path, 'w'))
    # json.dump(get_call_info, open(func_path, 'w'))
    
    