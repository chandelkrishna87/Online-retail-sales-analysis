import pandas as pd
df=pd.read_csv("OnlineRetail.csv",encoding='ISO-8859-1')
print("---------datacleaning------------")


df["InvoiceDate"] = pd.to_datetime(df["InvoiceDate"])
print("Invoice date datatype:", df["InvoiceDate"].dtype)
updated_date = df["InvoiceDate"].astype("datetime64[ns]")
print(f"Invoice date is given by :\n{updated_date.head()}")

print(f"Total duplicate rows = {df.duplicated().sum()}")
df_new = df.drop_duplicates()
print(f"Rows remaining after removing duplicates = {len(df_new)}")
df["Description"]= df["Description"].astype(str).str.strip()
print("Missing CustomerID count =", df["CustomerID"].isnull().sum())
print("Missing Description count =", df["Description"].isnull().sum())
cancellations_count = df["InvoiceNo"].astype(str).str.startswith("C").sum()
print(f"Total Cancellation Invoices (starting with C): {cancellations_count}")

returns_count = (df["Quantity"] < 0).sum()
print(f"Total Records with Negative Quantities (Returns): {returns_count}")

print("------creation of necessary columns--------")

df["total_revenue"] =df["Quantity"]*df["UnitPrice"]
print(df.columns.tolist())
df["InvoiceDate"] = pd.to_datetime(df["InvoiceDate"])
df["Year"] = df["InvoiceDate"].dt.year
df["Month"] = df["InvoiceDate"].dt.month
print(df[["InvoiceDate", "Year", "Month"]].head())
df["Month_Name"] = df["InvoiceDate"].dt.month_name()


print(df[["InvoiceDate", "Month_Name"]].head())
df["Weekday"] = df["InvoiceDate"].dt.day_name()
print(df[["InvoiceDate", "Weekday"]].head())

def check_status(row):
  if str(row["InvoiceNo"]).startswith("C"):
    return "Cancellation"
  elif row["Quantity"] < 0:
    return "Return"
  else:
    return "Sale"

df["Transaction_Status"] = df.apply(check_status, axis=1)
print(df["Transaction_Status"].value_counts())

print("-------analysis of retail data -------------")
total_revenue = df["total_revenue"].sum()
print(f"total revenue calculated = {total_revenue}")
top_10 = (
    df[df["Quantity"] > 0].groupby("Description")["total_revenue"].sum().nlargest(10)
)
print(top_10)
top_10 = (
    df[df["Quantity"]>0].groupby("Description")["Quantity"].sum().nlargest(10)
) 
print(top_10)   
top_countries = (
    df.groupby("Country")["InvoiceNo"].count().sum()
)
print(top_countries)
valid_sales= df[df["Transaction_Status"] == "Sale"]


month_sales = valid_sales.groupby("Month_Name")["total_revenue"].sum()
print(month_sales)
highest_month = month_sales.idxmax()
print(f"\nmonth with highest sales: {highest_month}\n")

avg_price = valid_sales["UnitPrice"].mean()
print(f"Average Unit Price = {avg_price:.2f}")

status_counts = df["Transaction_Status"].value_counts()
print(status_counts)
print()

country_sales = valid_sales.groupby("Country")["total_revenue"].sum()
country_share = (country_sales / country_sales.sum()) * 100
print(country_share.sort_values(ascending=False))
print("---------------------customer analysis-------------------")
valid_sales = df[
    (df["Quantity"] > 0) & (~df["InvoiceNo"].astype(str).str.startswith("C"))
]

unique_customers = valid_sales["CustomerID"].nunique()
print(f"Total Unique Customers: {unique_customers}\n")


top_10_customers = (
    valid_sales.groupby("CustomerID")["total_revenue"].sum().nlargest(10)
)
print(top_10_customers, "\n")


customer_sales = valid_sales.groupby("CustomerID")["total_revenue"].sum()
customer_share = (customer_sales / customer_sales.sum()) * 100
print(customer_share.head(10), "\n")  

order_revenue = valid_sales.groupby("InvoiceNo")["total_revenue"].sum()
avg_order_value = order_revenue.mean()
print(f"Average Order Value = {avg_order_value:.2f}\n")

unique_cust_country = (
    valid_sales.groupby("Country")["CustomerID"].nunique().nlargest(10)
)
print(unique_cust_country, "\n")
top_10_share = customer_share.nlargest(10).sum()
print(f"Top 10 Customers contribute: {top_10_share:.2f}% of total sales")
 
print("____________advance analysis____________________")

df = pd.read_csv("OnlineRetail.csv", encoding="ISO-8859-1")
df["InvoiceDate"] = pd.to_datetime(df["InvoiceDate"])
df["total_revenue"] = df["Quantity"] * df["UnitPrice"]
df["YearMonth"] = df["InvoiceDate"].dt.to_period("M")

valid_sales = df[
    (df["Quantity"] > 0) & (~df["InvoiceNo"].astype(str).str.startswith("C"))
]

top_avg_value = (
    valid_sales.groupby("Description")["total_revenue"].mean().nlargest(10)
)
print(top_avg_value, "\n")

monthly_sales = valid_sales.groupby("YearMonth")["total_revenue"].sum()
mom_growth = monthly_sales.pct_change() * 100
print(
    pd.DataFrame({"Total_Sales": monthly_sales, "MoM_Growth_%": mom_growth}),
    "\n",
)

daily_sales = valid_sales.groupby("InvoiceDate")["total_revenue"].sum()
cumulative_sales = daily_sales.cumsum()
print(cumulative_sales.tail(), "\n") 

invoice_totals = (
    valid_sales.groupby(["Country", "InvoiceNo"])["total_revenue"]
    .sum()
    .reset_index()
)
avg_invoice_country = (
    invoice_totals.groupby("Country")["total_revenue"].mean().nlargest(10)
)
print(avg_invoice_country, "\n")

product_sales = valid_sales.groupby("Description")["total_revenue"].sum()
top_10_prod_share = (
    product_sales.nlargest(10).sum() / product_sales.sum()
) * 100
print(
    f"Top 10 Products contribute: {top_10_prod_share:.2f}% of total sales\n"
)
country_month_summary = valid_sales.pivot_table(
    index="Country",
    columns="YearMonth",
    values="total_revenue",
    aggfunc="sum",
    fill_value=0,
)
print(country_month_summary.head(10))
print("_______________final___________________")
df_original = pd.read_csv("OnlineRetail.csv", encoding="ISO-8859-1")
total_initial_rows = len(df_original)
df = df_original.copy()
df["InvoiceDate"] = pd.to_datetime(df["InvoiceDate"])
df["total_revenue"] = df["Quantity"] * df["UnitPrice"]


def check_status(row):
  if str(row["InvoiceNo"]).startswith("C"):
    return "Cancellation"
  elif row["Quantity"] < 0:
    return "Return"
  else:
    return "Sale"

df["Transaction_Status"] = df.apply(check_status, axis=1)

valid_sales = df[df["Transaction_Status"] == "Sale"]

returns_count = (df["Transaction_Status"] == "Return").sum()
cancellations_count = (df["Transaction_Status"] == "Cancellation").sum()
missing_customer = df["CustomerID"].isna().sum()

print(f"Total Initial Rows: {total_initial_rows}")
print(f"Reclassified as Returns: {returns_count} (Negative quantities)")
print(f"Reclassified as Cancellations: {cancellations_count} (Invoice starting with 'C')")
print(f"Records with Missing CustomerID: {missing_customer}")


invalid_check_qty = (valid_sales["Quantity"] <= 0).sum()
invalid_check_inv = valid_sales["InvoiceNo"].astype(str).str.startswith("C").sum()
print(f"Negative quantities in valid sales: {invalid_check_qty}")
print(f"Cancellations in valid sales: {invalid_check_inv}")
print("Result: Rules are 100% consistent (No negative quantities or 'C' invoices in valid sales).\n")

cleaned_file_name = "OnlineRetail_Cleaned.csv"
df.to_csv(cleaned_file_name, index=False)

df_reloaded = pd.read_csv(cleaned_file_name)
print(f"File successfully saved and reloaded! Total rows in reloaded file: {len(df_reloaded)}\n")

report_content = """
ONLINE RETAIL ANALYSIS - SUMMARY REPORT
======================================
1. Cleaning Decisions:
   - Invoice numbers starting with 'C' were flagged as 'Cancellations'.
   - Negative quantities were categorized as 'Returns'.
   - Created a 'total_revenue' column (Quantity * UnitPrice) for deeper financial analysis.

2. Main Findings:
   - Valid sales exclude returns and cancellations to maintain revenue integrity.
   - Identified top-performing products, seasonal trends (Month-wise sales), and key customer contributions.
   - Top 10 customers and top products drive a significant share of the overall revenue.
"""

with open("Analysis_Report.txt", "w", encoding="utf-8") as f:
    f.write(report_content)

print("Report successfully saved as 'Analysis_Report.txt'!")
import pandas as pd

# Maan lijiye aapne saari cleaning aur naye columns ('total_revenue', 'Transaction_Status', etc.) 'df' mein kar liye hain
# Ab isko nayi CSV file ke taur par save karne ke liye yeh likhein:

df.to_csv("OnlineRetail_Cleaned.csv", index=False)

print("cleaned csv file saved successfully as OnlineRetail_Cleaned.csv!")

