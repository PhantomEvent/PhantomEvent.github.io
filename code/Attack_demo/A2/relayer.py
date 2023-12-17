from web3 import Web3, HTTPProvider
from web3.middleware import geth_poa_middleware
import json
#from transfer import send_erc20_transfer

web3 = Web3(Web3.HTTPProvider("https://data-seed-prebsc-1-s1.binance.org:8545"))
web3.middleware_onion.inject(geth_poa_middleware, layer=0)
assert web3.is_connected(), "Failed to connect to the node."

with open('qubit.abi', 'r') as abi_file:
    ptoken_abi = json.load(abi_file)

address_of_interest = web3.to_checksum_address("0x3BBb1F5382fC02a78D3354f55528B5dcFFB733F7")
qubit_contract = web3.eth.contract(address=address_of_interest, abi=ptoken_abi)

def process_transaction(tx):
    try:
        receipt = web3.eth.get_transaction_receipt(tx)
        for log in receipt.logs:
            if log['address'].lower() == address_of_interest.lower():
                try:
                    event_data = qubit_contract.events.Deposit().process_log(log)
                    sender = event_data['args']['sender']
                    amount = event_data['args']['amount']
                    token = event_data['args']['token']
                    destinationChainId = event_data['args']['destinationChainId']
                    print(f"sender: {sender}, amount: {amount}, token: {token} , destinationChainId:{destinationChainId}")
                except:
                    pass

    except:
        pass


new_block_filter = web3.eth.filter('latest')

while True:
    for block_hash in new_block_filter.get_new_entries():
        block = web3.eth.get_block(block_hash, full_transactions=True)
        for tx in block.transactions:
            process_transaction(tx.hash)
