# 🛒 Online Retail Sales Analysis: Python, MySQL & Power BI

An end-to-end data analytics project on the **UCI Online Retail dataset**. Raw transactional data is audited and cleaned with **Python (Pandas)**, queried for business insights with **MySQL**, and presented in an interactive **Power BI** dashboard.

![Python](https://img.shields.io/badge/Python-3.x-blue?logo=python&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-Data%20Analysis-150458?logo=pandas&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-Database-4479A1?logo=mysql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?logo=powerbi&logoColor=black)

---

## 📑 Table of Contents

- [Business Problem](#-business-problem)
- [Dataset](#-dataset)
- [Project Workflow](#-project-workflow)
- [Repository Structure](#-repository-structure)
- [Phase 1: Data Cleaning & Analysis (Python)](#-phase-1-data-cleaning--analysis-python--pandas)
- [Phase 2: SQL Analysis (MySQL)](#-phase-2-sql-analysis-mysql)
- [Phase 3: Dashboard (Power BI)](#-phase-3-dashboard-power-bi)
- [Key Findings](#-key-findings)
- [How to Run](#-how-to-run)
- [Limitations & Assumptions](#-limitations--assumptions)
- [Future Improvements](#-future-improvements)
- [Author](#-author)

---

## 🎯 Business Problem

Raw retail transaction data is rarely analysis-ready. It contains missing values, duplicates, returns, cancellations and inconsistent text. This project cleans and audits the raw data, then answers practical business questions:

- Which **products** and **countries** generate the most revenue?
- How do **sales trend** month over month, and when is the peak season?
- Who are the **top customers**, and how concentrated is revenue among them?
- What is the **average order value (AOV)**, and how does it vary by country?

## 📦 Dataset

| Property | Detail |
|---|---|
| **Source** | [UCI Machine Learning Repository: Online Retail](https://archive.ics.uci.edu/dataset/352/online+retail) (also on Kaggle) |
| **Business** | UK-based, non-store online retailer selling unique all-occasion gifts |
| **Period** | 01 Dec 2010 to 09 Dec 2011 |
| **Size** | 541,909 rows × 8 columns |
| **Coverage** | 38 countries · 25,900 invoices · 4,070 products · 4,372 customers |
| **Columns** | `InvoiceNo`, `StockCode`, `Description`, `Quantity`, `InvoiceDate`, `UnitPrice`, `CustomerID`, `Country` |

> The raw file `OnlineRetail.csv` is not included in this repository. Download it from the link above and place it in the project root.

## 🔄 Project Workflow

importing file from Kaggle--->cleaning through pandas-----> extracting insights using SQL-----> preparing dashboard through PowerBI
## 📁 Repository Structure

```
├── datacleaning.py                  # Phases 1–7: load, audit, clean, engineer features, analyse
├── final_cleaning.py                # Phase 8: final cleaning pipeline and CSV export
├── OnlineRetail_Pandas_Analysis.ipynb   # Notebook version of the Pandas analysis
├── onlineretail_extraction.sql      # 20 MySQL queries (KPIs, rankings, window functions)
├── retaildashboard.pbix             # Power BI dashboard
├── Python_Documentation.pdf         # Detailed phase-by-phase documentation with output screenshots
└── README.md
```

---

## 🐍 Phase 1: Data Cleaning & Analysis (Python / Pandas)

The Python work was executed in eight phases:

| Phase | Focus | What was done |
|---|---|---|
| 1 | Load & understand | Loaded with `ISO-8859-1` encoding, inspected shape, dtypes, date range and unique entities |
| 2 | Data quality audit | Counted missing values, duplicates, negative quantities, zero/negative prices and cancelled invoices |
| 3 | Cleaning | Converted dates to `datetime`, removed duplicates, stripped whitespace from descriptions |
| 4 | Feature engineering | Added `total_revenue`, `Year`, `Month`, `Month_Name`, `Weekday` and `Transaction_Status` |
| 5 | Sales analysis | Total revenue, top products, month-wise sales, country revenue share |
| 6 | Customer analysis | Unique customers, top spenders, AOV, customers per country |
| 7 | Advanced analysis | MoM growth, cumulative revenue, average invoice value by country, top-10 product share, country × month pivot |
| 8 | Final export | Built the error-checked pipeline in `final_cleaning.py` and exported `OnlineRetail_Cleaned_Final.csv` for SQL ingestion |

### Data quality audit results

| Check | Result |
|---|---|
| Missing `CustomerID` | 135,080 |
| Missing `Description` | 1,454 |
| Exact duplicate rows | 5,268 |
| Negative quantities | 10,624 |
| Zero or negative unit prices | 2,517 |
| Cancelled invoices (start with `C`) | 9,288 |

### Transaction classification

Every row is tagged using a simple rule set:

| Status | Rule | Rows |
|---|---|---|
| **Cancellation** | `InvoiceNo` starts with `C` | 9,288 |
| **Return** | `Quantity < 0` (non-cancelled) | 1,336 |
| **Sale** | Everything else | 531,285 |

*Valid sales* (used for most revenue analysis) exclude returns and cancellations so gross revenue is not distorted.

### Final cleaning pipeline (`final_cleaning.py`)

1. Check that the input file exists
2. Drop fully empty rows
3. Drop exact duplicates
4. Convert blank or whitespace-only cells to missing values
5. Fill missing cells with `NULL`
6. Export as `OnlineRetail_Cleaned_Final.csv` (`utf-8-sig` encoding for Excel/SQL compatibility)

---

## 🗄️ Phase 2: SQL Analysis (MySQL)

The cleaned CSV was imported into MySQL (database `retaildata`) and analysed with **20 queries** in `onlineretail_extraction.sql`.

| Theme | Queries | Techniques |
|---|---|---|
| **Data profiling** | Q1–Q3 | `COUNT(DISTINCT)`, `CASE WHEN` null checks, cancelled/negative records |
| **Revenue & KPIs** | Q4, Q19, Q20 | Total revenue, quantity, orders, AOV summary |
| **Products** | Q5, Q6, Q17 | Top 10 by revenue and quantity, `RANK()` within country |
| **Time series** | Q7, Q16, Q18 | `STR_TO_DATE`, `DATE_FORMAT`, `LAG()`, cumulative `SUM() OVER()` |
| **Orders** | Q8 | CTE for invoice totals, AOV, top invoices |
| **Customers** | Q9–Q12 | Top spenders, repeat customers, High/Medium/Low segmentation |
| **Geography** | Q13–Q15 | Revenue and orders by country, top 10 excluding the UK, AOV by country |

**Customer segmentation (Q12):** High ≥ 5,000 · Medium ≥ 1,000 · Low < 1,000 (total spend).

---

## 📊 Phase 3: Dashboard (Power BI)

`retaildashboard.pbix` contains a two-page interactive report.

**Page 1: Overview**
- KPI cards: **Total Revenue**, **Total Orders**, **Unique Customers**, **Average Order Value**
- Line chart: revenue trend over time
- Bar chart: top products by revenue
- Treemap: revenue by country
- **Country slicer** to filter the whole page

**Page 2: Detailed Analysis**
- Matrix: revenue and volume breakdown by country and product (revenue, quantity, orders)
- Funnel chart: bottom 10 countries by sales
- Donut chart: revenue contribution by customer
- Table: product-level revenue

> 📸 *Add dashboard screenshots here, for example `![Dashboard Overview](images/dashboard_overview.png)`*

---

## 💡 Key Findings

> Figures come from the Pandas analysis on valid sales unless noted otherwise.

- **Revenue concentration in the UK:** the United Kingdom contributes about **84.6%** of valid-sales revenue. The Netherlands (2.7%), EIRE (2.7%), Germany (2.2%) and France (2.0%) follow.
- **Strong seasonality:** **November 2011** is the peak month at about **£1.51M**, followed by a strong Q4 (Sept–Nov). Sales rise sharply from September, consistent with gift-season demand.
- **Latest month is partial:** December 2011 shows a −57.7% MoM drop only because the data ends on **9 Dec 2011**.
- **Top products by revenue:** *Dotcom Postage*, *Regency Cakestand 3 Tier* and *Paper Craft, Little Birdie* lead the ranking. Non-merchandise lines (postage, fees, manual entries) also appear in revenue rankings, so filtering them out would give a cleaner product view.
- **Top products by quantity:** *Paper Craft, Little Birdie* (80,995 units), *Medium Ceramic Top Storage Jar* (78,033) and *World War 2 Gliders Asstd Designs* (55,047).
- **Low product concentration:** the top 10 products make up only about **10.8%** of sales, so revenue is spread across a wide catalogue.
- **Customers:** **4,339** unique identified customers placed valid orders, with an **average order value of about £513.54**. The top customer (ID 14646) spent roughly **£280K**.
- **Customer base by country:** the UK has 3,921 active customers, far ahead of Germany (94) and France (87).
- **Average unit price** for valid sales is about **£3.86**.

---

## ▶️ How to Run

### Prerequisites
- Python 3.8+
- MySQL Server and MySQL Workbench
- Power BI Desktop (to open the `.pbix` file)

### 1. Clone the repository
```bash
git clone https://github.com/<your-username>/<your-repo-name>.git
cd <your-repo-name>
```

### 2. Add the dataset
Download `OnlineRetail.csv` from the [UCI repository](https://archive.ics.uci.edu/dataset/352/online+retail) and place it in the project folder, next to the Python scripts.

### 3. Install dependencies
```bash
pip install pandas numpy
```

### 4. Run the Python pipeline
```bash
# Audit, clean, engineer features and run the analysis
python datacleaning.py

# Generate the final cleaned CSV used for SQL import
python final_cleaning.py
```
This produces `OnlineRetail_Cleaned_Final.csv`.

### 5. Load data into MySQL
1. Open MySQL Workbench and run the first lines of `onlineretail_extraction.sql` (`CREATE DATABASE retaildata; USE retaildata;`).
2. Import `OnlineRetail_Cleaned_Final.csv` using the **Table Data Import Wizard**.
3. Name the table `OnlineRetail_Cleaned_Final 1(in)`, as the queries expect. If you use another name, find-and-replace it in the SQL file.
4. Run the queries in `onlineretail_extraction.sql`.

> **Note:** the SQL queries reference columns named `` `Invoice No` `` and `` `Invoice Date` `` (with spaces) and parse dates with the format `%d/%m/%Y %h:%i %p`. Make sure your imported table's column names and date format match, or adjust the queries.

### 6. Open the dashboard
Open `retaildashboard.pbix` in Power BI Desktop. If prompted, refresh or re-point the data source to your cleaned dataset.

---

## ⚠️ Limitations & Assumptions

- **Missing `CustomerID`:** about 25% of rows have no customer ID. These are kept for revenue analysis but excluded from customer-level metrics.
- **Returns & cancellations:** treated separately in the Pandas analysis to avoid distorting sales metrics. The SQL KPI queries sum all rows (including returns and cancellations), so their totals are **net revenue** and will differ from the Pandas *valid-sales* figures.
- **Non-product lines:** entries such as `POSTAGE`, `DOTCOM POSTAGE`, `AMAZON FEE` and `Manual` are not merchandise but are included in product rankings.
- **Partial months:** the dataset starts on 1 Dec 2010 and ends on 9 Dec 2011, so first and last months are not directly comparable to full months.
- **Month name grouping:** the Pandas month-wise totals group by month name, which merges December 2010 and December 2011.
- **Placeholder nulls:** missing values in the final CSV are filled with the text `NULL`; handle these as true nulls when importing into SQL (for example, with `NULLIF`).

## 🔮 Future Improvements

- Customer **RFM segmentation** (Recency, Frequency, Monetary)
- Exclude non-product stock codes from product analysis
- Cohort and retention analysis
- Revenue forecasting and time-series modelling
- Automate the pipeline from CSV load through to MySQL import

---

## 👤 Author

**Your Name**
- GitHub: (https://github.com/chandelkrishna87)
- LinkedIn(:www.linkedin.com/in/krishnasinghchandel8748)
- Email: chandelkrishna97@gmail.com
## 📜 Licenses

This project is for educational and portfolio purposes. The dataset is provided by the UCI Machine Learning Repository: please refer to their terms of use. *(Add a license such as MIT here if you plan to share the code openly.)*

---
 dashboard ss page 1 [https://github.com/chandelkrishna87/Online-retail-sales-analysis/blob/main/dashboard%20page%201.png]
 dashboard ss page 2[https://github.com/chandelkrishna87/Online-retail-sales-analysis/blob/main/dashboard%20page%202.png]
