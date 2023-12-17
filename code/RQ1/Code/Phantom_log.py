import csv
from datetime import datetime
from web3 import Web3, HTTPProvider
from web3.middleware import geth_poa_middleware

w3 = Web3(Web3.HTTPProvider("https://bsc-dataseed1.binance.org/"))
w3.middleware_onion.inject(geth_poa_middleware, layer=0)

end_block = w3.eth.block_number
print(end_block)
blocks_per_hour = 99
start_block = end_block - blocks_per_hour
print(start_block)
log_file = open('Phantom.log', 'w')

for block_num in range(start_block, end_block + 1):
    block = w3.eth.get_block(block_num, full_transactions=True)
    for tx in block.transactions:
        receipt = w3.eth.get_transaction_receipt(tx.hash)
        logs_by_contract = {}

        for log in receipt.logs:
            contract_address = log['address']
            event_signature = log['topics'][0] if log['topics'] else None

            if contract_address not in logs_by_contract:
                logs_by_contract[contract_address] = set()
            
            if event_signature:
                logs_by_contract[contract_address].add(event_signature)

        for address, events in logs_by_contract.items():
            for other_address, other_events in logs_by_contract.items():
                if address != other_address:
                    common_events = events.intersection(other_events)
                    if common_events:
                        print("Found!")
                        log_file.write(f"Transaction Hash: {tx.hash.hex()}\n")
                        log_file.write(f"Block Number: {tx.blockNumber}\n")
                        log_file.write(f"Common Events: {common_events}\n")
                        log_file.write(f"Contracts: {address}, {other_address}\n\n")

log_file.close()

