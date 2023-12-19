from dbm.ndbm import library
import json

from slither import Slither

def get_type(contract_path):
    contracts = Slither(contract_path)

    func_type = {"library": [], "function": [], "interface": []}

    for contract in contracts.contracts:
        for i in contract.state_variables:
            print(i)

    return func_type

if __name__ == "__main__":
    contract_path = "test"
    func_path = "test.json"

    func_type = get_type(contract_path)
    with open(func_path, "w") as file:
        json.dump(func_type, file, indent=4)
