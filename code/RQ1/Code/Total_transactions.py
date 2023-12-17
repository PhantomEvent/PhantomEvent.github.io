from web3 import Web3, HTTPProvider
from web3.middleware import geth_poa_middleware


w3 = Web3(Web3.HTTPProvider("https://bsc-dataseed1.binance.org/"))
w3.middleware_onion.inject(geth_poa_middleware, layer=0)

start_block = 34288241
end_block = 34288340

total_transactions = 0

for block_num in range(start_block, end_block + 1):
    block = w3.eth.get_block(block_num)
    total_transactions += len(block.transactions)

print(f"Total transactions from block {start_block} to {end_block}: {total_transactions}")
