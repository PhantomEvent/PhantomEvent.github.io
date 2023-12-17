from web3 import Web3
import json

web3 = Web3(Web3.HTTPProvider("https://eth-goerli.api.onfinality.io/public"))
assert web3.is_connected(), "Failed to connect to network."
token_address = Web3.to_checksum_address('0xf7Ff5a7FFC406d3D47757858cf0430bDef5F5742')
with open('erc20_abi.json', 'r') as abi_file:
    token_abi = json.load(abi_file)
token_contract = web3.eth.contract(address=token_address, abi=token_abi)

from_address= Web3.to_checksum_address('0xD4C855ef30AaC1c3AcFF219c55a483d49b330DEE')
private_key =  "02e01d49632d6fac78ba6192eac1a39b058d05af005226bb8fd803281084bc11"

def send_erc20_transfer(to_address, amount):

    to_address = Web3.to_checksum_address(to_address)
    amount = web3.to_wei(amount, 'ether')
    nonce = web3.eth.get_transaction_count(from_address)

    tx = token_contract.functions.transfer(to_address, amount).build_transaction({
        'chainId': 5,  
        'gas': 2000000,
        'gasPrice': web3.to_wei('50', 'gwei'),
        'nonce': nonce,
    })

    signed_tx = web3.eth.account.sign_transaction(tx, private_key)

    tx_hash = web3.eth.send_raw_transaction(signed_tx.rawTransaction)

    return web3.to_hex(tx_hash)



#print(send_erc20_transfer("0xD4C855ef30AaC1c3AcFF219c55a483d49b330DEE",1))