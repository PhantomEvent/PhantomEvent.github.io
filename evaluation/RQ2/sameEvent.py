import os
import json

from slither import Slither

from GetCFG_final import *

data_path = r"/home/ubuntu/event/two_bridge/Orbit"
hash = "0x662b67d00a13faf93254714dd601f5ed49ef2f51"

for filepath,dirnames,filenames in os.walk(data_path):
    for filename in filenames:
        if filename.split('.')[-1] != 'sol':
            continue
        mapping = dict()
        
        # os.system(cmd)
        sols = Slither(filepath + '/' + filename)

        for contract in sols.contracts:
            for function in contract.functions:
                if function.visibility == "private" or function.visibility == "internal":
                    continue
                # if contract.name == 'SonOfDogeFinal' and function.name == 'constructor':
                # if contract.name == 'SonOfDogeFinal':
                #     print(function.name)
                    # plot_CFG(get_Graph(function))
                events = get_event(contract, function)
                for event in events:
                    event_name = event[2]
                    emit_info = hash + '.' + filename.split('.')[0] + '.' + event[0] + '.' + event[1]
                    if event_name in mapping:
                        mapping[event_name].append(emit_info)
                    else:
                        mapping[event_name] = [emit_info]

        json.dump(mapping, open(filepath + '/' + 'sameEvent' + '_' + filename.split('.')[0] + '.json', "w"))