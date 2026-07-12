# 🚗 Car Sales & Business Intelligence Analysis

An end-to-end data analytics and business intelligence project utilizing **Python** and **Power BI** to optimize regional dealership performance, track sales volume, and analyze purchasing trends.

![Python](https://img.shields.io/badge/Python-3.x-blue?logo=python)
![PowerBI](https://img.shields.io/badge/PowerBI-Dashboard-yellow?logo=powerbi)
![Pandas](https://img.shields.io/badge/Pandas-Data%20Analysis-green?logo=pandas)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

---

## 📋 Project Overview & Problem Statement

Automotive dealership executives need clear, real-time insights to understand regional consumer demand, optimize vehicle distribution, and maximize top-line revenue. This project analyzes **23,664 vehicle transactions (2022–2023)** to uncover critical factors driving sales across car body styles, regional markets, transmission types, and customer segments.

---

## 📸 Dashboard Preview

![Car Sales Dashboard](images/car_sales_dashboard.png)
![Attrition and Demographics](images/attrition.png)
![Demographics and Brand Performance](images/demographics_brand_performance.png)

---

## 🛠️ Tech Stack & Architecture

| Tool | Purpose |
|------|---------|
| Python, Pandas, NumPy | Data exploration & preprocessing |
| Microsoft Power BI Desktop | Data modeling & visualizations |
| DAX (Data Analysis Expressions) | Advanced metrics & KPIs |

---

## 📁 Repository Structure

```
car-sales-dashboard-project/
├── images/                          # Dashboard screenshots
│   ├── sales overview.png
│   ├── attrition.png
│   └── Demographics and Brand Performance.png
├── Car_Sales_Cleaned.csv            # Cleaned dataset (23,664 rows)
├── EDA_analysis.ipynb               # Jupyter Notebook for EDA & validation
├── car_sales_dashboard.pbix         # Master Power BI report file
└── README.md                        # Project documentation

```

📊 Dataset Overview

- **Rows:** 23,664 transactions
- **Columns:** 20 features
- **Date Range:** January 2022 – December 2023
- **Price Range:** $1,200 – $75,400
- **Brands Covered:** 30 manufacturers (Ford, Toyota, BMW, Dodge, Cadillac, and more)
- **Regions:** 7 dealership regions (Austin, Janesville, Scottsdale, Aurora, Greenville, Pasco, Middletown)

### Dataset Preview

| Car_id | Date | Customer_Name | Gender | Annual_Income | Company | Model | Price |
|:---|:---|:---|:---|:---|:---|:---|:---|
| C_CND_000001 | 2022-01-02 | Geraldine | Male | $13,500 | Ford | Expedition | $26,000 |
| C_CND_000002 | 2022-01-02 | Gia | Male | $1,480,000 | Dodge | Durango | $19,000 |
| C_CND_000003 | 2022-01-02 | Gianna | Male | $1,035,000 | Cadillac | Eldorado | $31,500 |

---

## 📖 Data Dictionary

| Column Name | Data Type | Description |
|:---|:---|:---|
| **Car_id** | String | Unique identifier for each car sale transaction |
| **Date** | Date | Date when the vehicle transaction occurred |
| **Customer_Name** | String | Name of the vehicle buyer |
| **Gender** | String | Gender of the buyer |
| **Annual_Income** | Integer | Customer's yearly income in USD |
| **Dealer_Name** | String | Name of the dealership franchise |
| **Company** | String | Car manufacturer / brand (e.g., Ford, Toyota) |
| **Model** | String | Specific model name of the vehicle |
| **Engine** | String | Engine architecture type (e.g., Overhead Camshaft) |
| **Transmission** | String | Transmission type — Auto or Manual |
| **Color** | String | Exterior color of the sold vehicle |
| **Price** | Integer | Final sale price in USD |
| **Body_Style** | String | Vehicle classification — SUV, Sedan, Hatchback, Hardtop, Passenger |
| **Dealer_Region** | String | Geographic market location of the dealership |
| **Price_Category** | String | Price tier — Low, Mid, or High |
| **Affordability_Ratio** | Decimal | Price-to-income ratio for the buyer |
| **Year** | Integer | Year of the transaction |
| **Month** | Integer | Month number (1-12) |
| **Month_Name** | String | Full month name |
| **Income_Category** | String | Customer income bracket — Low, Mid, or High Income |

---
## 📊 Key Performance Indicators (KPIs)

- Total Sales Revenue: 651,550,154
- Total Cars Sold: 23,664
- Average Selling Price: 27,533.39
- Top Selling Brand: Ford
- Top Dealer Region: Austin
- Unique Customers: 3,014

## 💡 Business Insights

- Ford generated the highest sales revenue among all brands.
- Austin was the top-performing dealer region by revenue.
- SUVs were the most frequently sold body style with 6,318 sales.
- Automatic transmission vehicles (12,553) slightly outsold manual vehicles (11,111).
- Male customers accounted for the majority of purchases (18,630 compared to 5,034 female customers).

---

## 🚀 How to Run the Project Locally

### Requirements
- [Microsoft Power BI Desktop](https://powerbi.microsoft.com/desktop/) (free)
- Python 3.x with `pandas`, `numpy` for EDA notebook

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/NandanR75/car-sales-dashboard-project.git
   cd car-sales-dashboard-project
   ```

2. **Explore the EDA Notebook**
   ```bash
   jupyter notebook EDA_analysis.ipynb
   ```

3. **Open the Power BI Dashboard**
   - Double-click `car_sales_dashboard.pbix` to open in Power BI Desktop
   - If prompted to update data source path:
     - Go to **Home → Transform Data → Data Source Settings**
     - Click **Change Source** and browse to your local `Car_Sales_Cleaned.csv`
     - Click **Apply Changes** to refresh all visuals

---

## 🤝 Let's Connect!

Interested in collaborating or discussing this project?

- 💼 **LinkedIn:** https://www.linkedin.com/in/nandan-r-010564224
- 📧 **Email:** nandanr121995@gmail.com
