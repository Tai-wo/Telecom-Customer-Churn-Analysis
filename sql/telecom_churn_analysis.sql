-- =====================================================
-- TELECOM CUSTOMER CHURN ANALYSIS
-- SQL Analysis using DuckDB
-- =====================================================

-- Load and preview the cleaned dataset

SELECT *
FROM read_csv_auto('data/processed/telco_Customer_Churn_clean.csv');
-- Overall Customer Churn Rate
SELECT
    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN Churn = 'Yes' THEN 1
            ELSE 0
        END
    ) AS churned_customers,

    SUM(
        CASE
            WHEN Churn = 'No' THEN 1
            ELSE 0
        END
    ) AS retained_customers,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN Churn = 'Yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS churn_rate_percentage

FROM read_csv_auto(
    'data/processed/telco_Customer_Churn_clean.csv'
);
-- =====================================================
--  CHURN RATE BY CONTRACT TYPE
-- =====================================================

SELECT
    Contract,

    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN Churn = 'Yes' THEN 1
            ELSE 0
        END
    ) AS churned_customers,

    SUM(
        CASE
            WHEN Churn = 'No' THEN 1
            ELSE 0
        END
    ) AS retained_customers,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN Churn = 'Yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS churn_rate_percentage

FROM read_csv_auto(
    'data/processed/telco_Customer_Churn_clean.csv'
)

GROUP BY Contract

ORDER BY churn_rate_percentage DESC;
-- BUSINESS INSIGHT:
-- Month-to-month customers have the highest churn rate by a significant margin.
-- Customers on one-year and two-year contracts have substantially lower churn.
-- This suggests that customers with longer contractual commitments are more likely
-- to remain with the company, while month-to-month customers represent a higher
-- retention risk and should be prioritized for targeted retention strategies.

-- =====================================================
-- CHURN RATE BY PAYMENT METHOD
-- =====================================================

SELECT
    PaymentMethod,

    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN Churn = 'Yes' THEN 1
            ELSE 0
        END
    ) AS churned_customers,

    SUM(
        CASE
            WHEN Churn = 'No' THEN 1
            ELSE 0
        END
    ) AS retained_customers,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN Churn = 'Yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS churn_rate_percentage

FROM read_csv_auto(
    'data/processed/telco_Customer_Churn_clean.csv'
)

GROUP BY PaymentMethod

ORDER BY churn_rate_percentage DESC;
-- BUSINESS INSIGHT:
-- Electronic Check customers have the highest churn rate at approximately 45.29%,
-- which is substantially higher than customers using other payment methods.
-- Customers using automatic payment methods, particularly credit card and bank
-- transfer, have significantly lower churn rates.
--
-- This suggests that Electronic Check customers represent an important high-risk
-- segment for customer retention. The company should investigate whether this
-- relationship is associated with other factors such as contract type, tenure,
-- monthly charges, or customer experience.
--
-- The company could also encourage suitable Electronic Check customers to adopt
-- automatic payment methods through convenient payment options or incentives.
-- However, payment method should not be assumed to directly cause churn, as
-- other customer characteristics may contribute to the observed relationship.

-- =====================================================
--  CHURN RATE BY CUSTOMER TENURE
-- =====================================================

SELECT

    CASE
        WHEN tenure <= 12 THEN 'New Customer (0-12 months)'
        WHEN tenure <= 24 THEN 'Early Customer (13-24 months)'
        WHEN tenure <= 48 THEN 'Established Customer (25-48 months)'
        ELSE 'Long-Term Customer (49-72 months)'
    END AS tenure_segment,

    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN Churn = 'Yes' THEN 1
            ELSE 0
        END
    ) AS churned_customers,

    SUM(
        CASE
            WHEN Churn = 'No' THEN 1
            ELSE 0
        END
    ) AS retained_customers,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN Churn = 'Yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS churn_rate_percentage

FROM read_csv_auto(
    'data/processed/telco_Customer_Churn_clean.csv'
)

GROUP BY tenure_segment

ORDER BY churn_rate_percentage DESC;
-- BUSINESS INSIGHT:
-- Customer churn is highest among customers in their first 12 months,
-- with a churn rate of approximately 47.44%.
--
-- Churn declines progressively as customer tenure increases. Early customers
-- have a churn rate of approximately 28.71%, established customers have a rate
-- of 20.39%, while long-term customers have the lowest churn rate at 9.51%.
--
-- This indicates that the early stages of the customer lifecycle represent
-- the greatest retention risk. Customers who remain with the company for
-- longer periods are substantially more likely to stay.
--
-- The company should therefore prioritize onboarding, early engagement,
-- proactive customer support, and targeted retention campaigns during the
-- first 12 months of the customer relationship.
-- =====================================================
--  HIGH-RISK CUSTOMER CHURN ANALYSIS
-- =====================================================

WITH customer_risk AS (

    SELECT
        *,

        CASE
            WHEN Contract = 'Month-to-month'
                 AND tenure <= 12
                 AND MonthlyCharges >= 70
                 AND OnlineSecurity = 'No'
                 AND TechSupport = 'No'
            THEN 'High Risk'

            ELSE 'Other'
        END AS customer_risk_profile

    FROM read_csv_auto(
        'data/processed/telco_Customer_Churn_clean.csv'
    )
)

SELECT

    customer_risk_profile,

    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN Churn = 'Yes' THEN 1
            ELSE 0
        END
    ) AS churned_customers,

    SUM(
        CASE
            WHEN Churn = 'No' THEN 1
            ELSE 0
        END
    ) AS retained_customers,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN Churn = 'Yes' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS churn_rate_percentage

FROM customer_risk

GROUP BY customer_risk_profile

ORDER BY churn_rate_percentage DESC;
-- BUSINESS INSIGHT:
-- The analysis uses multiple customer characteristics to identify a high-risk
-- customer segment. Customers classified as High Risk are identified based on
-- a combination of month-to-month contracts, short tenure, higher monthly
-- charges, lack of Online Security, and lack of Tech Support.
--
-- Comparing the churn rate of High Risk customers with Other customers allows
-- the business to evaluate whether combining multiple risk indicators can
-- identify customers who are more vulnerable to churn.
--
-- If the High Risk segment demonstrates a substantially higher churn rate,
-- the company can use these characteristics to prioritize proactive retention
-- efforts. Potential interventions may include personalized offers, improved
-- technical support, service bundles, and incentives for longer-term contracts.
--
-- This classification is a rule-based business segmentation and should not be
-- interpreted as a validated predictive model. Further testing would be
-- required before using it to predict churn among new customers.