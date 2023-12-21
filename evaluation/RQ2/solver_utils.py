import re
import json
from z3 import *
from typing import Dict, Tuple, List
from lark import Lark, Transformer, v_args
import ast

def format_solidity_expressions(expressions):
    pattern = r'([<>=!]=|[-+*/%&|]=|&&|\|\||[+\-*/%&|<>=])'
    
    spaced_expressions = []
    
    if isinstance(expressions, list):
        for expression in expressions:

            spaced_expression = re.sub(pattern, r' \1 ', expression)
            spaced_expressions.append(spaced_expression)
    else:

        spaced_expressions.append(re.sub(pattern, r' \1 ', expressions))
    

    if len(spaced_expressions) == 1:
        return spaced_expressions[0]
    else:
        return spaced_expressions


# List of expressions provided
def convert_compound_to_regular(expressions):
    operator_mapping = {
        '+=': '+',
        '-=': '-',
        '*=': '*',
        '/=': '/',
        '%=': '%',
        '**=': '**'
    }

    def convert_expression(expr):
        for compound_op, regular_op in operator_mapping.items():
            if compound_op in expr:
                variable, value = expr.split(compound_op)
                return f'{variable.strip()} = {variable.strip()} {regular_op} ( {value.strip()} )'
        return expr  # If no compound operator found, keep the expression as is

    # Check if the input is a list or a single expression
    if isinstance(expressions, list):
        # If it's a list, process each expression in the list
        return [convert_expression(expr) for expr in expressions]
    else:
        # If it's a single expression, process it directly
        return convert_expression(expressions)


def remove_spaces_in_function_calls(code):
    pattern = r'(\w+)\(([^)]+)\)'

    def replace_func(match):
        function_name = match.group(1)
        args = match.group(2)
        args_without_spaces = args.replace(" ", "")  
        return f"{function_name}({args_without_spaces})"

    return re.sub(pattern, replace_func, code)


def is_constant(var):
    try:
        val = ast.literal_eval(var)  
        return isinstance(val, (int, float, complex))
    except:
        return False
    

def is_mapping(mapping, string):
    """
    Checks if there is a key in the mapping that is a prefix of the given string,
    and is immediately followed by a '[' character in the string.

    :param mapping: A dictionary containing keys to be checked.
    :param string: The string to check against the keys in the mapping.
    :return: True if such a key exists; otherwise False.
    """
    for key in mapping:
        # Check if the string starts with the key and the character immediately
        # following the key is '['
        if string.startswith(key) and string[len(key):].startswith('['):
            return True
    return False

def is_array(mapping, string):
    """
    If there is a key in the mapping that is a prefix of the given string and
    is immediately followed by a '[' character in the string, return the value
    corresponding to that key in the mapping. Otherwise, return None.

    :param mapping: A dictionary containing keys and their corresponding values.
    :param string: The string to check against the keys in the mapping.
    :return: The value corresponding to the key if such a key exists; otherwise None.
    """
    for key in mapping:
        if string.startswith(key) and string[len(key):].startswith('['):
            return mapping[key]
    return None
def remove_modifier(a, b, c):
    x = len(a)

    b_filtered = []
    c_filtered = c[:] 

    for index, item in enumerate(b[:x]):
        if not any(item.startswith(prefix) for prefix in a):
            b_filtered.append(item)
        else:
            if index < len(c_filtered):
                c_filtered.pop()

    b_filtered.extend(b[x:])
    return b_filtered, c_filtered


if __name__ == '__main__':
    expressions = [
    "_value<=allowance[_from][msg.sender]+b+d+f+e+a.sub()+a+add(1)",
    "frozenAccount[target]=(freeze)",
    "balanceOf[_from]>=_value",
    "_value<=allowance[_from][msg.sender]",
    "balanceOf[_from]-=_value",
    "allowance[_from][msg.sender]-=_value+a",
    "not(totalSupply-=_value)"
]

    for expression in expressions:
# Format the expressions
        convert_expressions = convert_compound_to_regular(expression)
        print(convert_expressions)
        formatted_expressions = format_solidity_expressions(convert_expressions)
   # formatted_expressions = remove_spaces_in_function_calls(formatted_expressions)
        print(formatted_expressions)

