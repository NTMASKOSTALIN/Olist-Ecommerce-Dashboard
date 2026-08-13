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

<img width="1599" height="899" alt="Executive Overview" src="https://github.com/NTMASKOSTALIN/Olist-Ecommerce-Dashboard/blob/main/Customer%20Retention%20&%20Churn.png?raw=true" />

<img width="1599" height="899" alt="Executive Overview" src="https://github.com/NTMASKOSTALIN/Olist-Ecommerce-Dashboard/blob/main/Revenue,%20Customer%20Value%20&%20Experience.png?raw=true" />

<img width="1599" height="899" alt="Revenue   CLV" src="https://github.com/NTMASKOSTALIN/Olist-Ecommerce-Dashboard/blob/main/Delivery%20Performance%20(1).png?raw=true" />


## Key Insights:

1. **Customer Retention:** The platform retained **40.99%** of customers, with most making a single purchase. This limits long-term revenue growth and increases customer acquisition costs. Implement **loyalty programs, personalized campaigns, and cross-selling initiatives** to improve **repeat purchases**.

2. **Churn:** The platform has a **59.01% churn rate**. More importantly, **97% of customers are one-time buyers**, while only **3% return**. RFM also shows **34.12% of customers are At-Risk**, indicating a large pool that could potentially be **reactivated**. **Implement loyalty programs, retargeting campaigns, and post-purchase email** sequences to convert **one-time buyers into repeat customers.**

3. **RFM Segmentation:** RFM analysis showed **40.81% Loyal** customers, while **34.12% were At-Risk** and only **16.72% were High Value**. The large At-Risk segment highlights a **strong opportunity** to improve **customer retention**. **Target At-Risk customers** with **personalized campaigns** while rewarding VIP customers to **maximize retention and revenue**.

4. **Revenue at Risk:** **At-Risk customers contribute $3.39M (22.03%)** of the platform's **$15.39M revenue**, representing the largest immediate revenue-recovery opportunity. Their **Avg. Monetary value of $106** is substantially **lower than High Value ($312) and Loyal ($184) customers**, while **Churned customers average only $56**. Prioritize **At-Risk customers with targeted reactivation campaigns, personalized offers and loyalty incentives to convert them into Loyal or High Value** customers and protect this revenue.

5. **Delivery Experience Impact:** Delivery delays average **10.62 days, with top sellers reaching 15.16 days**, contributing to higher low-rating rates. Premature reviews also generate **43.18% 1-star ratings vs. 6.72%** for normal reviews.
Recommendation: **Strengthen seller/carrier SLAs, prioritize high-delay sellers, and fix premature review** triggers to improve customer experience and retention.

## Hypothesis Testing:

Customers with delayed deliveries had a **59.11% churn rate vs. 57.77% for on-time deliveries (+1.34%)**. The **Chi-Square test** confirmed the association was **statistically significant (p = 0.0036)** at the **5%(α = 0.05) Significance level**. Although delivery delays are associated with higher churn, the small gap indicates **churn is primarily driven by structural purchasing behavior**. Prioritize **loyalty programs, personalized marketing, customer retention and repeat purchase strategies** while continuing to improve delivery performance.

## Conclusion:

This analysis of **99,252 orders** across Olist's Brazilian e-commerce platform (Sept 2016 – Oct 2018) reveals that the analysis indicates platform's primary retention challenge is structural rather than operational.

The hypothesis that delivery delays are the primary driver of churn was statistically confirmed **(Chi-Square p = 0.00364, α = 0.05)** — but the practical **gap of only 1.34% between delayed (57.77%) and on-time (59.11%)** churn rates tells the deeper story. Customers churn almost equally whether their order arrived late or on time. This makes clear that churn on Olist is a structural behavioral pattern, not a consequence of poor experience.

The revenue picture sharpens this finding. **High Value and Loyal segments together generate $11.57M — 75% of total $15.39M revenue** — yet represent a minority of customers. The **At-Risk segment (34.12%) and Churned segment (8.34%)** together hold customers whose lifetime spend **($106 and $56 CLV respectively)** reflects disengagement rather than dissatisfaction. The platform attracts new customers but struggles to convert them into repeat buyers.

Operational fixes stand out as immediate priorities independent of the structural problem. **First, 8,120 premature reviews averaging 2.77 stars** are artificially suppressing the platform's **4.16 average score** — a review email timing fix resolves this at zero cost.

The path forward requires action on **two parallel tracks — operational improvements to delivery SLAs and the review trigger bug, and strategic investment** in loyalty programs, post-purchase retargeting and cross-selling to address the structural repeat purchase gap that no amount of delivery optimization alone can fix.
