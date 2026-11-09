
import pandas as pd
import os

# Input and output file names
input_file = "OnlineRetail.csv"
output_file = "OnlineRetail_Cleaned_Final.csv"

# Check if input file exists
if not os.path.exists(input_file):
    print("ERROR: file not found")
    print("Please keep the CSV file in the same folder as this Python script.")
else:
    # 1. Load dataset
    df = pd.read_csv(input_file, encoding="ISO-8859-1")

    print("Original dataset shape:", df.shape)

    # 2. Remove completely empty rows
    df = df.dropna(how="all")

    # 3. Remove exact duplicate rows
    df = df.drop_duplicates(keep="first")

    # 4. Convert empty strings/spaces into missing values
    df = df.replace(r"^\s*$", pd.NA, regex=True)

    # 5. Remove completely empty rows again
    df = df.dropna(how="all")

    # 6. Fill missing cells with NULL
    df = df.fillna("NULL")

    # 7. Save cleaned CSV file
    df.to_csv(output_file, index=False, encoding="utf-8-sig")

    print("\nCleaning completed successfully!")
    print("Original file remains unchanged.")
    print("Final dataset shape:", df.shape)
    print("Output file saved at:", os.path.abspath(output_file))
