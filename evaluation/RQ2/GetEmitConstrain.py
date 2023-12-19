import json

from slither import Slither
from slither.slithir.operations.event_call import EventCall
from slither.slithir.variables.constant import Constant
from slither.slithir.variables.reference import ReferenceVariable
from slither.core.expressions.call_expression import CallExpression
from slither.core.expressions.binary_operation import BinaryOperation
from slither.core.expressions.assignment_operation import AssignmentOperation
from slither.core.cfg.node import NodeType

from graph_function import get_Graph, find_path
from utils import get_dependency_data, processConditionEasy, get_node_related_variable


def get_event(contract, function):
    hasEvents_slither = []
    for node in function.nodes:
        for ir in node.irs:
            #print(ir)
            
            if isinstance(ir, EventCall):
                if ir.name == "AllowListAddressSet":
                    print("debug")
                event_params_slither = []
                for param in ir.read:
                    event_params_slither.append(param)
                hasEvents_slither.append([contract.name, function.name, ir.name, event_params_slither, node])
    return hasEvents_slither


def get_condition(contract_path):
    # get AST
    # ast_json = compile_and_get_ast(contract_path)


    contracts = Slither(contract_path)

    func_type = dict()
    func_new_strs = []

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

    all_event = []

    for contract in contracts.contracts:
        for function in contract.functions:
            if function.name == "safeTransfer":
                print("debug")
            function_variables = dict()
            for parameter in function.variables_read:
                try:
                    if str(parameter.name) not in function_variables:
                        
                            function_variables[str(parameter.name)] = str(parameter.type)
                except:
                    pass
                    # print((str(parameter.name) + " "+str(parameter.type)))
            for parameter in function.variables_written:
                try:
                    if str(parameter.name) not in function_variables:
                        
                        function_variables[str(parameter.name)] = str(parameter.type)
                except:
                    pass
                # print((str(parameter.name) + " "+str(parameter.type)))
            # print(function_variables)
            event_info_slither = get_event(contract, function)

            if len(event_info_slither) > 0:
                # print(event_info_slither)
                print(function.name)
                event_CFG = get_Graph(function)
                if function.name == 'constructor':
                    print("debug")
                    # plot_CFG(event_CFG)
                #print(event_CFG)
                for event_item in event_info_slither:                    
                    # get data_dependency expression
                    dependency_data_slither = get_dependency_data(event_item, function)
                    #print(dependency_data_slither)
                    dependency_data = [str(i) for i in dependency_data_slither]
                    '''
                    if len(dependency_data) != 0:
                        print("dependency_data:")
                        print(dependency_data_slither)
                    '''
                    event_node = event_item[4]
                    paths, new_dependency = find_path(event_CFG, function.nodes[0], event_node)
                    dependency_data.extend(new_dependency)
                    for path in paths:
                        event_expression = dict()
                        event_expression["isloop"] = False
                        event_expression["loop_info"] = []
                        event_expression["vars"] = function_variables
                        event_expression["info"] = event_item[0: len(event_item) - 1]
                        new_event_parameters = []
                        for i in event_expression["info"][3]:
                            if isinstance(i, Constant):
                                new_event_parameters.append(str(i) + "--" + str(i.type))
                            elif isinstance(i, ReferenceVariable):
                                new_event_parameters.append(i.points_to.name + "_element" + "--variables")
                            else:
                                new_event_parameters.append(str(i) + "--variables")
                        event_expression["info"][3] = new_event_parameters
                        event_expression['related_expression'] = []
                        event_expression['related_expression_type'] = []
                        # event_expression['call_info'] = []
                        print(event_expression["info"])
                        # event_conditions = []
                        # event_require_conditions = []
                        for path_node in path:
                            #print(str(path_node.expression)+ "   type    " + str(path_node.type))
                            if path_node == event_node:
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
                                sons = list(event_CFG.successors(path_node))
                                for son in sons:
                                    if son in path:
                                        edge_info = event_CFG.get_edge_data(path_node, son)['branch']
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
                                for i in range(0, len(parse_expressions)):
                                    for opt in opts:
                                        if opt in dependency_data:
                                            # for call in call_info:
                                            #     parse_expressions[i] = parse_expressions[i].replace(call[0], call[1] + '_' + call[2], 1)
                                            event_expression['related_expression'].append(parse_expressions[i])
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
                        
                        all_event.append(event_expression)
                        #print(event_expression['related_expression_type'])
                        print("---------------------------")
                print("***************************")

    return all_event, func_type
