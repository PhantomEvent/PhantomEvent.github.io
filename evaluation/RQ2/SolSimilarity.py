import json
import os
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from concurrent.futures import ThreadPoolExecutor, as_completed
from tqdm import tqdm

root = ''

def read_file(file_path):
    with open(file_path, 'r') as file:
        return file.read()

def cos_sim(vector_a, vector_b):
    num = float(np.dot(vector_a, vector_b))
    denom = np.linalg.norm(vector_a) * np.linalg.norm(vector_b)
    return num / denom if denom != 0 else 0

def calculate_file_similarity(content1, content2):
    tfidf_vectorizer = TfidfVectorizer()
    tfidf_matrix = tfidf_vectorizer.fit_transform([content1, content2])
    return cos_sim(*tfidf_matrix.toarray())

file_list = []
with open(r"F:\DApp_measure\EventSense-main\Dataset\file.txt", 'r') as file:
    i = 0
    for line in file:
        file_list.append(line.strip())
        i += 1
        if i >= 10000:
            break

num_files = len(file_list)
similarity_matrix = np.zeros((num_files, num_files))

def compute_similarity(i, j):
    content1 = read_file(file_list[i])
    content2 = read_file(file_list[j])
    return i, j, calculate_file_similarity(content1, content2)

with ThreadPoolExecutor(max_workers=6) as executor: 
    future_to_pair = {executor.submit(compute_similarity, i, j): (i, j) for i in range(num_files) for j in range(i+1, num_files)}

    for future in tqdm(as_completed(future_to_pair), total=len(future_to_pair), desc="Calculating Similarities"):
        i, j = future_to_pair[future]
        similarity = future.result()
        similarity_matrix[i, j] = similarity
        similarity_matrix[j, i] = similarity
        print(i, j, similarity)

np.save('similarity_matrix.npy', similarity_matrix)

final_res = []

for i in range(0, num_files):
    for j in range(i + 1, num_files):
        final_res.append([file_list[i], file_list[j], similarity_matrix[i][j]])

json.dump(final_res)