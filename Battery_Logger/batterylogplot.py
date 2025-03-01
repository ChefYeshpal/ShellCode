import pandas as pd
import matplotlib.pyplot as plt

# Function to convert time strings to hours
def convert_time_to_hours(time_str):
    # Handle NaN or float values by returning 0 or some default value
    if pd.isna(time_str) or isinstance(time_str, float):
        return 0.0
    
    try:
        # Otherwise, process the string normally
        time_parts = time_str.split()
        hours = 0

        for part in time_parts:
            if 'h' in part:
                hours += int(part.replace('h', ''))
            elif 'm' in part:
                hours += int(part.replace('m', '')) / 60  # convert minutes to hours
        return hours
    except ValueError:
        print(f"Warning: Could not parse time string '{time_str}'")
        return 0.0  # Default to 0 hours if parsing fails

# Load the battery log data from CSV
data = pd.read_csv('battery_log.csv')

# Convert the Timestamp column to datetime
data['Timestamp'] = pd.to_datetime(data['Timestamp'], errors='coerce')

# Convert Battery_Percentage to numeric (optional, if needed)
data['Battery_Percentage'] = pd.to_numeric(data['Battery_Percentage'], errors='coerce')

# Apply the conversion function to Time_Remaining (if Time_Remaining exists)
if 'Time_Remaining' in data.columns:
    data['Time_Remaining'] = data['Time_Remaining'].apply(convert_time_to_hours)

# Plotting battery percentage over time
plt.figure(figsize=(10, 6))
plt.plot(data['Timestamp'], data['Battery_Percentage'], label='Battery Percentage', marker='o')

# Optional: Plot Time Remaining if that column exists
if 'Time_Remaining' in data.columns:
    plt.plot(data['Timestamp'], data['Time_Remaining'], label='Time Remaining (hours)', marker='x')

plt.xlabel('Timestamp')
plt.ylabel('Battery Percentage / Time Remaining (hours)')
plt.title('Battery Log Over Time')
plt.legend()
plt.grid(True)
plt.xticks(rotation=45)
plt.tight_layout()

# Show the plot
plt.show()

