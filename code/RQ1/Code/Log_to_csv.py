import pandas as pd

with open('xx.log', 'r') as file:
    lines = file.readlines()

transactions = []
total = 0

for i in range(0, len(lines), 5):
    if i + 3 < len(lines):  
        total+=1
        print(total)
        line1 = lines[i].strip()
        line2 = lines[i+1].strip()
        line3 = lines[i+2].strip()
        line4 = lines[i+3].strip()

        if line1.startswith('Transaction Hash:') and line2.startswith('Block Number:'):
            transaction_hash = line1.split(': ')[1]
            block_number = line2.split(': ')[1]
            common_events = line3.split(': ')[1]
            contracts = line4.split(': ')[1].split(', ')

            transactions.append([transaction_hash, block_number, common_events, contracts])

df = pd.DataFrame(transactions, columns=['Transaction Hash', 'Block Number', 'Common Events', 'Contracts'])

df.to_csv('transactions.csv', index=False)
