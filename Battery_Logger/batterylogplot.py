import pandas as pd
import matplotlib.pyplot as plt

# Load the data and specify column names explicitly if needed
data = pd.read_csv('battery_log.csv', names=['Timestamp', 'Battery_Percentage'], skiprows=1)

# Strip any leading/trailing spaces from column names
data.columns = data.columns.str.strip()

# Print columns to check if 'Timestamp' is correct
print("Columns:", data.columns)

# Convert the Timestamp column to datetime, handling parsing errors
data['Timestamp'] = pd.to_datetime(data['Timestamp'], errors='coerce')

# Drop any rows where the Timestamp couldn't be parsed (i.e., rows with NaT in the 'Timestamp' column)
data.dropna(subset=['Timestamp'], inplace=True)

# Convert Battery_Percentage to float, removing the '%' sign
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

