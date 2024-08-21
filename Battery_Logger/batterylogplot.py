import pandas as pd
import matplotlib.pyplot as plt



# Load the data
data = pd.read_csv('battery_log.csv', header=None, names=['Timestamp', 'Battery_Percentage'])

# Print columns to check if 'Timestamp" is correct
print(data.columns)

# Convert the Timestamp column to datetime
data['Timestamp'] = pd.to_datetime(data['Timestamp'])

# Plot the data
plt.figure(figsize=(10, 5))
plt.plot(data['Timestamp'], data['Battery_Percentage'].str.rstrip('%').astype(float), marker='o')

plt.title('Battery Percentage Over Time')
plt.xlabel('Timestamp')
plt.ylabel('Battery Percentage (%)')
plt.grid(True)
plt.xticks(rotation=45)
plt.tight_layout()

# Save the plot as a PNG file
plt.savefig('battery_plot.png')

# Show the plot
plt.show()

