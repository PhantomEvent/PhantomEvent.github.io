import pandas as pd

df = pd.read_csv('total.csv')

common_events_counts = df['Common Events'].value_counts()

most_common_event = common_events_counts.idxmax()
max_count = common_events_counts.max()

print(f"Common Event is '{most_common_event}'，total {max_count}")
