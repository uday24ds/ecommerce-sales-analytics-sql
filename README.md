# E-Commerce Sales & Customer Analytics (MySQL)

## 📌 Project Overview
An end-to-end SQL analytics project analyzing e-commerce transactions and customer behavior. Using MySQL, this project validates raw data, evaluates revenue metrics, tracks Month-over-Month (MoM) and Year-over-Year (YoY) growth, and segments high-value customers.

---

## 📊 Dataset Summary
* **Customers:** 1,000 profiles across multiple cities
* **Orders:** 10,000 records (spanning Jan 2024 – Aug 2026)
* **Total Simulated Revenue:** $21,824,734.30

---

## 🛠️ Tech Stack & Key Concepts
* **Database Engine:** MySQL
* **SQL Techniques:** CTEs (`WITH` clauses), Window Functions (`ROW_NUMBER`, `RANK`, `LAG`), Aggregations, Joins, Conditional Logic (`CASE`).

---

## 🔍 Key Analyses Covered

1. **Data Validation & Hygiene:** Audits duplicate IDs, missing fields, orphan records, and signup date anomalies.
2. **Revenue Performance:** Tracks overall revenue, Average Order Value (AOV), min/max purchase amounts, and monthly trends.
3. **Advanced Growth Metrics:**
   * **Running Totals:** Cumulative revenue calculation across periods.
   * **MoM & YoY Growth:** Uses `LAG()` to calculate percentage changes across months and years.
4. **Customer Segmentation:**
   * **High Value:** Total spend ≥ $20,000
   * **Medium Value:** Total spend between $10,000 and $19,999
   * **Low Value:** Total spend < $10,000
5. **Customer Behavior:** Measures purchase frequency distribution and top 20% revenue concentration.

---

## 📁 Repository Structure
```text
├── data/
│   ├── customers.csv              # Customer demographics dataset (1,000 rows)
│   └── orders.csv                 # Transaction dataset (10,000 rows)
├── ecommerce_sales_analysis.sql   # Complete SQL analysis script
└── README.md                      # Project documentationocumentation
