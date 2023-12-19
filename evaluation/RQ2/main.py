import json
import re
import os
import sys
from GetCFG_final import get_condition as get_event_condition
from GetFCG_final import getReturnConstraint as get_return_condition
from get_modifier_constraint import getModifierConstraint as get_modifier_condition
from GetType import get_type

if __name__ == "__main__":
    # Check if the correct number of arguments are provided
    if len(sys.argv) < 3:
        print("Usage: script.py <contract_file_path> <index>")
        sys.exit(1)

    contract_path = sys.argv[1]
    index = sys.argv[2]

    # Extract filename without extension
    filename_without_extension = os.path.splitext(os.path.basename(contract_path))[0]

    # Call functions and save results
    event_res = get_event_condition(contract_path)
    return_res = get_return_condition(contract_path)
    modifier_res = get_modifier_condition(contract_path)
    type_res = get_type(contract_path)

    # Construct output JSON file paths using the index and filename
    json_filename = f"{index}_{filename_without_extension}.json"
    event_path = f"./event_expressions/{json_filename}"
    return_path = f"./return_expressions/{json_filename}"
    modifier_path = f"./modifier_expressions/{json_filename}"
    type_path = f"./type_expressions/{json_filename}"

    # Save results to JSON files
    json.dump(event_res, open(event_path, "w"))
    json.dump(return_res, open(return_path, "w"))
    json.dump(modifier_res, open(modifier_path, "w"))
    json.dump(type_res, open(type_path, "w"))
