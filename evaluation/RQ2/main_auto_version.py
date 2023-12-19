import json
import re
import os
import subprocess
import sys
from GetCFG_final import get_condition as get_event_condition
from GetFCG_final import getReturnConstraint as get_return_condition
from get_modifier_constraint import getModifierConstraint as get_modifier_condition
from GetType import get_type

def compile_contract(contract_path, version):
    """Compile the Solidity contract using solc."""
    cmd = f'solc-select use {version} && solc {contract_path}'
    try:
        # Execute the compilation command
        subprocess.run(cmd, check=True, shell=True)
        print(f"Compilation successful: {contract_path}")
    except subprocess.CalledProcessError:
        # If compilation fails, log the error message
        with open("error.log", "a") as log_file:
            log_file.write(f"Error compiling contract: {contract_path}\n")
        print(f"Error compiling contract: {contract_path}")

if __name__ == "__main__":
    # Get the contract path from command line argument
    if len(sys.argv) < 2:
        print("Please provide the contract file path.")
        sys.exit(1)

    contract_path = sys.argv[1]

    # Extract filename without extension
    filename_without_extension = os.path.splitext(os.path.basename(contract_path))[0]

    # Read and parse the Solidity version

    with open(contract_path, "r") as fh:
        version = ""
        for line in fh:
            if line.startswith('pragma solidity'):
                pattern = r'\^(\d+\.\d+\.\d+)'
                match = re.search(pattern, line)
                if match:
                    version = match.group(1)
                    break

    if len(version) == 0:
        error_message = f"Version information not found: {contract_path}\n"
        with open("error.log", "a") as log_file:
            log_file.write(error_message)
        print(error_message)
        sys.exit(1)

    # Compile the contract
    compile_contract(contract_path, version)

    # Call functions and save results
    event_res = get_event_condition(contract_path)
    return_res = get_return_condition(contract_path)
    modifier_res = get_modifier_condition(contract_path)
    type_res = get_type(contract_path)

    # Construct output JSON file paths
    event_path = f"./event_expressions/{filename_without_extension}.json"
    return_path = f"./return_expressions/{filename_without_extension}.json"
    modifier_path = f"./modifier_expressions/{filename_without_extension}.json"
    type_path = f"./type_expressions/{filename_without_extension}.json"

    # Save results to JSON files
    json.dump(event_res, open(event_path, "w"))
    json.dump(return_res, open(return_path, "w"))
    json.dump(modifier_res, open(modifier_path, "w"))
    json.dump(type_res, open(type_path, "w"))
