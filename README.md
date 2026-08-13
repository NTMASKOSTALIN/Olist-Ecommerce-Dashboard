## Project Title:
Customer Retention & Revenue Optimization in Olist E-Commerce Platform

## Problem Statement:
Olist's transaction data reveals a critical business challenge: the majority of customers never return after their first purchase, representing significant lost lifetime value and revenue leakage. This project investigates the operational and experiential factors driving this churn — including delivery failures, product dissatisfaction, and seller unreliability — and quantifies their financial impact on the platform.
By analysing customer transactions, delivery performance, review behaviour, and seller metrics, this project delivers data-driven recommendations to improve customer retention, increase lifetime value, and optimise platform revenue.

## Project Links:

Tableau: https://public.tableau.com/app/profile/masko.stalin.n.t/viz/OlistEcommerceProject_17861174450860/CustomerRetentionChurn

## Business Objective:
Identify the key operational and experiential drivers of customer churn on the Olist platform, and provide actionable recommendations to increase repeat purchase rates, optimise delivery performance, and maximise customer lifetime value (CLV).

## Hypothesis:
Delivery delays are associated with higher customer churn.

## Business Questions:
**1. Customer Retention & Churn**
   
• What percentage of customers are one-time vs. repeat buyers?

• After how many days do customers typically stop purchasing?

• Which customers show early signs of churn based on recency?

**2. Revenue & Customer Value**
   
• Do repeat customers contribute disproportionately more revenue than one-time buyers?

• Which customer segments generate the highest lifetime value?

• How does basket size (AOV) and purchase frequency influence total revenue?

**3. Delivery Performance**
   
• Is there a measurable delay threshold beyond which customer satisfaction drops sharply?

• Which regions and sellers are responsible for the highest delivery delays?

**4. Customer Experience**
   
• What factors — delay, price, product type — most strongly predict low review scores?

• Do customers who leave low ratings have measurably lower repeat purchase rates?

**5. Seller & Product Performance**
    
• Which sellers contribute most to delays, cancellation, bad ratings?

## KPIs
• Repeat Purchase Rate
• Churn Rate
• Retention Rate
• Total Revenue
• Average Order Value (AOV)
• GMV
• CLV(Monetary)
• Delivery Delay Rate
• Avg Delay Duration
• Average Review Score
• Low Rating Rate
• Delivery Delay Rate
• Seller Cancellation Rate

## Advanced Analysis
    
• RFM Analysis

• Cohort Analysis

## Tools & Technologies

• SQL (ETL, Profiling, Cleaning)

• Python (EDA, Feature Engineering, Statistical Analysis)

• Tableau (Dashboarding)

## Process

**Data Extraction, Profiling & Cleaning (SQL):** Imported and integrated **9 Olist e-commerce relational datasets** containing customer, order, payment, review, seller, product, and geolocation data. Performed comprehensive **data profiling**, data quality audits, duplicate checks, null value analysis, referential integrity validation, timeline anomaly detection, and business rule verification. Cleaned, standardized, and transformed data using **CTEs, Window Functions, CASE statements, Joins, and Aggregations**, while deriving business metrics to create a **single analytics-ready master dataset** for Python EDA and Tableau dashboard development.

**Exploratory Data Analysis (Python):** Conducted **univariate, bivariate, and time-series analysis** to evaluate customer purchasing behavior, delivery performance, review patterns, payment trends, and seller performance. Performed **feature engineering, outlier treatment, and customer-level aggregations** to uncover key drivers of customer satisfaction, order value, purchasing patterns, and revenue generation.

**Advanced Analytics:** : Developed **RFM Segmentation, Cohort Retention Analysis**. Performed **customer segmentation, retention analysis, feature engineering, and hypothesis testing (Chi-Square Test)** to evaluate the relationship between delivery delays and customer churn.

**Interactive Dashboard Development (Tableau):** Designed a **3-page interactive Tableau dashboard** featuring **Customer Retention & Churn, Revenue, Customer Value & Experience, Delivery Performance**. Developed **13 KPIs**. Implemented **interactive filters, calculated fields, parameters, and dashboard actions** to enable dynamic business performance analysis.

<img width="1599" height="899" alt="Executive Overview" src="https://github.com/NTMASKOSTALIN/Olist-Ecommerce-Dashboard-/blob/main/Executive%20Overview-%201.png" />

<img width="1599" height="899" alt="Customer Retention" src="https://github.com/NTMASKOSTALIN/Olist-Ecommerce-Dashboard-/blob/main/Customer%20Retention-%202.png" />

<img width="1599" height="899" alt="Revenue   CLV" src="https://github.com/user-attachments/assets/9ab6d565-f2fd-4057-acf2-1b7f55f53a05" />

<img width="1599" height="899" alt="Delivery Performance" src="https://github.com/user-attachments/assets/3fc67c61-3c30-426b-ae51-3cf667c4e6a2" />

<img width="1599" height="899" alt="Customer Experience" src="https://github.com/NTMASKOSTALIN/Olist-Ecommerce-Dashboard-/blob/main/Customer%20Experience-%205.png" />

<img width="1599" height="899" alt="Seller   Product" src="https://github.com/user-attachments/assets/fc314517-4ed9-4eea-a61e-a1f6880e8da8" />

## Key Insights:

1. **Customer Retention:** The platform retained only **3.12%** of customers, with most making a single purchase. This limits long-term revenue growth and increases customer acquisition costs. Implement **loyalty programs, personalized campaigns, and cross-selling initiatives** to improve **repeat purchases**.

2. **Churn:** **96.88%** of customers **never returned** after their **first purchase**, despite **churned customers** having the **highest average review score** (**4.15 vs. 4.10** platform average). **High satisfaction** alone is **not driving repeat purchases**, indicating a **structural retention challenge**. **Implement loyalty programs, retargeting campaigns, and post-purchase email** sequences to convert **one-time buyers into repeat customers.**

3. **RFM Segmentation:** RFM analysis showed **40.74% Loyal** customers, while **34.24% were At-Risk** and only **16.60% were VIP**. The large At-Risk segment highlights a **strong opportunity** to improve **customer retention**. **Target At-Risk customers** with **personalized campaigns** while rewarding VIP customers to **maximize retention and revenue**.

4. **Revenue at Risk:** **VIP and Loyal customers** generated **$12.0M (75.1%)** of the **platform's $15.98M revenue**, with **AOVs of $261.2 and $180.5 vs. $107.3 for At-Risk and $56.5 for Churned customers**. High-value customers drive most revenue, making their retention essential for sustained growth. **Prioritize VIP and Loyal customers** with exclusive **retention programs and personalized offers** to maximize long-term value.

5. **Delivery Experience Impact:** Review scores **dropped from 4.29 (on-time) to 2.11 after 4–7 day delays and 1.70 after 7+ days**, while **late orders averaged a 10.62-day delay**. Satisfaction drops sharply after 4 days, with **carrier transit accounting for 74%** of delivery time. **Trigger SLA alerts after 3 days and strengthen carrier partnerships** in high-delay regions.

6. **Regional Delivery Performance:** **AL (20.6%), MA (16.8%), SE (14.6%), PI (13.4%) and CE (13.2%)** had delay rates up to **3× the platform average (6.58%)**, while SP accounted for **1,842 sellers generating $10.22M**. Regional delivery performance varies significantly, indicating opportunities to improve logistics in high-delay states. **Expand regional fulfilment partnerships or warehouses in high-delay states** to reduce delivery delays and improve customer satisfaction.

## Hypothesis Testing:

Customers with delayed deliveries had a **94.63% churn rate vs. 93.61% for on-time deliveries (+1.02%)**. The **Chi-Square test** confirmed the association was **statistically significant (p = 0.0012)** at the **5%(α = 0.05) Significance level**. Although delivery delays are associated with higher churn, the small gap indicates **churn is primarily driven by structural purchasing behavior**. Prioritize **customer retention and repeat purchase strategies** while continuing to improve delivery performance.

## Conclusion:

This analysis of **99,252 orders** across Olist's Brazilian e-commerce platform (Sept 2016 – Oct 2018) reveals that the analysis indicates platform's primary retention challenge is structural rather than operational.

The hypothesis that delivery delays are the primary driver of churn was statistically confirmed **(Chi-Square p = 0.0012, α = 0.05)** — but the practical **gap of only 1.02% between delayed (94.63%) and on-time (93.61%)** churn rates tells the deeper story. Customers churn almost equally whether their order arrived late or on time. **High satisfaction is not driving repeat purchases** either — **Churned customers hold the highest average review score at 4.15**, above the **platform average of 4.10**. This makes clear that churn on Olist is a structural behavioural pattern, not a consequence of poor experience.

The revenue picture sharpens this finding. **VIP and Loyal segments together generate $12.0M — 75.1% of total $15.98M revenue** — yet represent a minority of customers. The **At-Risk segment (34.24%) and Churned segment (8.42%)** together hold customers whose lifetime spend **($107.3 and $56.5 AOV respectively)** reflects disengagement rather than dissatisfaction. The platform attracts new customers but struggles to convert them into repeat buyers.

Two operational fixes stand out as immediate priorities independent of the structural problem. **First, 8,121 premature reviews averaging 2.77 stars** are artificially suppressing the platform's **4.09 average score** — a review email timing fix resolves this at zero cost. Second, Northern and Northeast states (AL 20.6%, MA 16.8%, SE 14.6%) face delay rates **2–3× the 6.58% platform average** while seller activity is heavily concentrated in SP, highlighting an opportunity for regional fulfilment expansion."

The path forward requires action on **two parallel tracks — operational improvements to delivery SLAs and the review trigger bug, and strategic investment** in loyalty programs, post-purchase retargeting and cross-selling to address the structural repeat purchase gap that no amount of delivery optimisation alone can fix.
