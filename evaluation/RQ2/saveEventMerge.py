import json
import os

data_path = r""

final_same_event = {}

for filepath,dirnames,filenames in os.walk(data_path):
    for filename in filenames:
        if not filename.startswith("sameEvent"):
            continue
        if filename.split('.')[-1] != "json":
            continue
        path = filepath + '/' + filename
        print(filename)
        same_event = json.load(open(path, "r", encoding="utf-8"))
        for event in same_event:
            if len(same_event[event]) > 1:
                print(same_event[event][0])
                newkey = event + same_event[event][0].split('.')[0]
                final_same_event[newkey] = same_event[event]

json.dump(final_same_event, open(r"same_event.json", "w"))

        