import csv

file_path = 'xx.csv'

hashes = set()

with open(file_path, 'r') as file:
    reader = csv.reader(file)
    for row in reader:
        transaction_hash = row[0]
        hashes.add(transaction_hash)

print(f"Unique transaction hashes: {len(hashes)}")
