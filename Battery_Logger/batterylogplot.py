import pandas as pd
import matplotlib.pyplot as plt

# Load the data, assuming there are no headers in the CSV file
data = pd.read_csv('battery_log.csv', header=None)

# Manually set the column names
data.columns = ['Timestamp', 'Battery_Percentage']

# Print columns to confirm 'Timestamp' and 'Battery_Percentage'
print("Columns:", data.columns)

# Convert the Timestamp column to datetime
data['Timestamp'] = pd.to_datetime(data['Timestamp'])

# Remove the '%' sign from the Battery_Percentage column and convert it to float
data['Battery_Percentage'] = data['Battery_Percentage'].str.rstrip('%').astype(float)

# Plot the data
plt.figure(figsize=(10, 5))
plt.plot(data['Timestamp'], data['Battery_Percentage'], marker='o')

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

