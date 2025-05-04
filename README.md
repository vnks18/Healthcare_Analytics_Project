# 🏥 Healthcare Analytics – Advanced SQL Project

This project simulates a healthcare analytics environment using T-SQL on MSSQL Server. It demonstrates how to transform raw appointment, billing, and prescription data into a robust analytical model using materialized views and complex SQL logic.

---

## 📊 Objectives

- Track patient visits and appointment trends
- Analyze prescriptions by doctor, patient, and medication
- Summarize billing and revenue by department
- Handle no-shows and cancellations
- Create **silver-layer materialized views** for reporting and dashboards

---

## 🧱 Schema Overview

**patients.csv**  
`patient_id`, `first_name`, `last_name`, `date_of_birth`, `gender`, `contact_info`

**appointments.csv**  
`appointment_id`, `patient_id`, `appointment_date`, `doctor_id`, `department`, `status`

**prescriptions.csv**  
`prescription_id`, `patient_id`, `medication`, `dosage`, `prescribed_date`, `doctor_id`

**billing.csv**  
`billing_id`, `patient_id`, `appointment_id`, `amount`, `billing_date`, `payment_status`

---

## 🧠 Key SQL Concepts Used

- Common Table Expressions (CTEs)
- Window Functions (LAG, RANK)
- Subqueries
- Conditional Aggregates
- Multi-table JOINs
- Case Statements
- Date Functions (DATEDIFF, DATEPART)

---

## 🧾 Materialized Views (Silver Layer)

| View | Description |
|------|-------------|
| `mv_patient_visit_summary` | Visit counts and average gap between visits |
| `mv_prescription_stats` | Total prescriptions by medication |
| `mv_revenue_summary` | Department-level revenue breakdown |

---

## 🚀 Run Instructions

1. Load all CSVs into SQL Server as tables (`patients`, `appointments`, etc.)
2. Run queries in `sql/initial_queries.sql`
3. Create silver layer by executing `views/materialized_views.sql`
4. Analyze with BI tools like Power BI or Tableau (optional)

---

## 📦 Folder Structure

```
Healthcare_Analytics_Project/
├── data/                         # Contains CSV files
├── sql/
│   └── initial_queries.sql       # Full logic (~200+ lines)
├── views/
│   └── materialized_views.sql    # Silver-layer definitions
├── README.md
└── requirements.txt
```

---

## 🧪 Future Enhancements

- Add CDC (change data capture) logic
- Optimize query execution with indexes
- Include dashboards with Power BI visuals
- Dev branch: optimized queries for performance

---

## 📬 Contact

Maintainer: Nirupam Velagapudi  
LinkedIn: [linkedin.com/in/nirupamvelagapudi](https://www.linkedin.com/in/nirupamvelagapudi)

---
