import os
data_path = r"/home/ubuntu/event/Bridge_test_V1/Bridge_test/"


sol_num = 0
filesys = []

for filepath,dirnames,filenames in os.walk(data_path):
    for filename in filenames:
        if filename.split('.')[-1] == 'sol':
            sol_num += 1


print(sol_num)