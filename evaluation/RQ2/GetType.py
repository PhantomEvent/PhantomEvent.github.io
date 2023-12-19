from dbm.ndbm import library
import json

from slither import Slither

def get_type(contract_path):
    contracts = Slither(contract_path)

    func_type = {"library": [], "function": [], "interface": []}

    for contract in contracts.contracts:
        for function in contract.functions:
            func_info = {
                "name": function.name,
                "return_type": [str(i) for i in function.return_type] if function.return_type else []
            }

            if contract._is_interface:
                func_type["interface"].append(func_info)
            elif contract._is_library:
                func_type["library"].append(func_info)
            else:
                func_type["function"].append(func_info)

    return func_type

if __name__ == "__main__":
    contract_path = "/path/to/your/contract.sol"
    func_path = "/path/to/your/output.json"

    func_type = get_type(contract_path)
    with open(func_path, "w") as file:
        json.dump(func_type, file, indent=4)
