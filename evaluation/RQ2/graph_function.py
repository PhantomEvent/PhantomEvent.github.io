import matplotlib.pyplot as plt
import networkx as nx
import re

from slither import Slither
import slither.printers.call.call_graph as cg
from slither.core.expressions.binary_operation import BinaryOperation

from utils import getCallInfo, getIDName, get_node_related_variable

get_call_info = []


def plot_CFG(CFG):
    plt.figure(figsize=(10, 8))

    pos = nx.spring_layout(CFG, seed=42)  
    labels = {node: node for node in CFG.nodes()}  

    edge_colors = []
    for edge in CFG.edges(data=True):
        if edge[2]['branch'] == 'true':
            edge_colors.append('g')  
        else:
            edge_colors.append('r')  

    nx.draw(CFG, pos, with_labels=True, labels=labels, node_size=500, node_color='lightblue', font_size=10, font_color='black', edge_color=edge_colors, width=2, font_weight='bold')

    plt.show()


def get_Graph(function):
    CFG = nx.DiGraph()
    for node in function.nodes:
        CFG.add_node(node)
    nodes = [function.nodes[0]]
    node_state = dict()
    node_state[function.nodes[0]] = True
    while(len(nodes) > 0):
        node = nodes[0]
        for son in node.sons:
            if son == node.son_false:
                CFG.add_edge(node, son,branch = 'false')
            else:
                CFG.add_edge(node, son,branch = 'true')
            if son not in nodes:
                if son not in node_state or node_state[son] is False:
                    nodes.append(son)
                    node_state[son] = True
        nodes.remove(node)
    #if(function.name == "swapBack"):
    #    plot_CFG(CFG);
    return CFG


def plot_FCG(FCG):
    plt.figure(figsize=(10, 8))

    pos = nx.spring_layout(FCG, seed=42)  
    labels = {node: node for node in FCG.nodes()}  

    nx.draw(FCG, pos, with_labels=True, labels=labels, node_size=500, node_color='lightblue', font_size=10, font_color='black', width=2, font_weight='bold')

    plt.show()


def get_FCG(contract_path):
    contracts = Slither(contract_path)
    all_functionss = [compilation_unit.functions for compilation_unit in contracts.compilation_units]
    all_functions = [item for sublist in all_functionss for item in sublist]
    res = cg._process_functions(all_functions)
    # print(res)
    # print(type(res))

    subgraph_pattern = r'\{(.*?)\}'
    subgraphs = re.findall(subgraph_pattern, res, re.DOTALL)
    id_name_dict = dict()
    subgraph_id_name_pattern = r'subgraph (.*?) {'
    id_names = re.findall(subgraph_id_name_pattern, res, re.DOTALL)

    for id_name in id_names:
        id_name_info = id_name.strip()
        id, name = getIDName(id_name_info)
        if id is not None and name is not None:
            id_name_dict[id] = name
    
    # print(id_name_dict)
    FCG = nx.DiGraph()
    for subgraph in subgraphs:
        # print(subgraph)
        subgraph_info = subgraph.strip().split('\n')

        pattern = r'"(.*?)"'
        contract_name = re.findall(pattern, subgraph_info[0])[0]
        # print(contract_name)

        for item in range(1, len(subgraph_info)):
            if '->' not in subgraph_info[item]:
                func_info = subgraph_info[item].split(' ')[0][1: -1] + '_' + contract_name
                FCG.add_node(func_info)
    

    for subgraph in subgraphs:
        subgraph_info = subgraph.strip().split('\n')
        for item in range(1, len(subgraph_info)):
            if '->' in subgraph_info[item]:
                caller = subgraph_info[item].split('->')[0].strip()[1: -1]
                callee = subgraph_info[item].split('->')[1].strip()[1: -1]
                caller_node = getCallInfo(caller, id_name_dict)
                callee_node = getCallInfo(callee, id_name_dict)
                FCG.add_edge(caller_node, callee_node)
                get_call_info.append([caller_node, callee_node])


    external_pattern = r'\}([^\}]+)$'
    external_res = re.search(external_pattern, res, re.DOTALL)
    if external_res:
        external_contents = external_res.group(1).strip().split('\n')
        for external_content in external_contents:
            caller = external_content.split('->')[0].strip()[1: -1]
            callee = external_content.split('->')[1].strip()[1: -1]
            caller_node = getCallInfo(caller, id_name_dict)
            callee_node = getCallInfo(callee, id_name_dict)
            FCG.add_edge(caller_node, callee_node)
            get_call_info.append([caller_node, callee_node])
    
    return FCG


def find_path(CFG, start, dest):

    cycles = list(nx.simple_cycles(CFG))
    all_paths = []
    _all_path = list(nx.all_simple_paths(CFG, start, dest))
    new_dependency = []
    for path in _all_path:
        for node in path:

            node_expression = node.expression
            if isinstance(node_expression, BinaryOperation):
                target_cycles = [cycle for cycle in cycles if node in cycle]
                if target_cycles:
                    opts = get_node_related_variable(node)
                    new_dependency.extend(opts)
                    new_sub_path = []
                    for _node in target_cycles[0]:
                        new_sub_path.append(_node)
                    new_path = []
                    _loc = 0
                    while _loc < len(path):
                        if path[_loc] != node:
                            new_path.append(path[_loc])
                        else:
                            break
                        _loc += 1
                    new_path.extend(new_sub_path)
                    _loc += 1
                    while _loc < len(path):
                        new_path.append(path[_loc])
                        _loc += 1
                    all_paths.append(new_path)
        all_paths.append(path)
    return all_paths, new_dependency