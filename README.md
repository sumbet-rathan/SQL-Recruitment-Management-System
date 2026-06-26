# US Staffing & Recruitment Analytics – SQL Project

A complete end-to-end SQL project that models a **US IT Staffing / Recruitment Agency** database and analyzes the full hiring lifecycle — from candidate sourcing to client placement and revenue generation.

---

## 📌 Project Overview

This project simulates the real-world workflow of a US staffing company, covering everything from **client requirements** and **candidate sourcing** to **submissions, interviews, offers, placements**, and **recruiter performance**.

The goal was to:
- Design a normalized relational database (ER Diagram) for a staffing business
- Clean and load **10 datasets** into MySQL
- Write **23 analytical SQL queries** to answer real business questions around hiring funnel performance, recruiter productivity, client revenue, and conversion rates

---

## 🗂️ Database: `Recruitment_Analytics_DB`

### Tables Used (10)

| # | Table | Description |
|---|-------|-------------|
| 1 | `clients` | Companies that post job requirements (industry, account manager, contract type, status) |
| 2 | `recruiters` | Recruiter master data (team, manager, experience, joining date) |
| 3 | `candidate_sources` | Lookup table for sourcing channels (LinkedIn, Referral, Job Boards, etc.) |
| 4 | `candidates` | Candidate profile data (skills, experience, salary expectations, visa status, source) |
| 5 | `requirements` | Job openings raised by clients (job title, bill/pay rate, priority, status) |
| 6 | `submissions` | Candidates submitted by recruiters against a requirement |
| 7 | `interviews` | Interview rounds scheduled for each submission |
| 8 | `offers` | Offers extended after a successful interview |
| 9 | `placements` | Final placement details — start date, revenue, status |
| 10 | `recruiter_activity` | Daily recruiter productivity metrics (calls, emails, submissions, interviews, placements) |

### Entity Relationship Diagram

The database follows a **hiring funnel structure**:

```
clients → requirements → submissions → interviews → offers → placements
                ↑              ↑
          recruiters      candidates ← candidate_sources

recruiters → recruiter_activity
```

See `Er_Diagram_US_Staffing.png` for the full ER diagram with all keys and relationships.

---

## 🧹 Data Preparation

- Sourced/created **10 raw datasets** corresponding to each table above
- Cleaned the data prior to loading: removed duplicates, standardized date formats, handled missing values (nulls in salary/visa/feedback fields), fixed inconsistent text casing, and validated foreign key references
- Loaded the cleaned datasets into MySQL tables created via the schema in `SQL_Project_US_Staffing.sql`

---

## 🛠️ Tech Stack

- **Database:** MySQL
- **Concepts Used:** Joins (INNER/LEFT), Aggregations, GROUP BY/HAVING, Subqueries, CTEs, Window Functions (`RANK`, `DENSE_RANK`, `ROW_NUMBER`, running totals), Conversion Rate Analysis

---

## 📊 Business Questions Answered (23 Queries)

| Category | Examples |
|----------|----------|
| **Volume Metrics** | Total candidates, recruiters, open requirements |
| **Candidate Insights** | Candidates by visa status, source performance, average experience |
| **Recruiter Performance** | Submissions per recruiter, success rate, top recruiters by placements, monthly best recruiter |
| **Client Insights** | Top clients by requirements, revenue by client, client fill rate |
| **Hiring Funnel** | Candidate → Submission → Interview → Offer → Placement counts |
| **Conversion Rates** | Submission→Interview, Interview→Offer, Offer→Placement conversion % |
| **Trend Analysis** | Interviews per month, monthly revenue trend, running revenue (window function) |
| **Rankings** | Recruiter ranking by placements, top candidate sources (DENSE_RANK) |

Full query list with comments available in [`SQL_Project_US_Staffing.sql`](./SQL_Project_US_Staffing.sql).

---

## 🚀 Key Insights

- Built a complete **hiring funnel** view to track drop-off at every stage (submission → interview → offer → placement)
- Identified **top-performing recruiters and clients** by placement volume and revenue
- Measured **fill rate** per client to evaluate requirement closure efficiency
- Tracked **monthly revenue trends** and recruiter performance using window functions

---

## 📁 Repository Structure

```
├── SQL_Project_US_Staffing.sql      # Schema creation + all 23 analytical queries
├── Er_Diagram_US_Staffing.png       # Entity Relationship Diagram
└── README.md                        # Project documentation
```

---

## ▶️ How to Use

1. Run the schema section of `SQL_Project_US_Staffing.sql` in MySQL to create the database and 10 tables
2. Load the cleaned datasets into their respective tables
3. Run the 23 queries individually to reproduce the analysis/insights

---

## 🙋‍♂️ Author

Feel free to connect or reach out if you have feedback or questions about this project.
