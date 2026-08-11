-- ================================================================
-- HR Analytics — Employee Attrition SQL Analysis
-- Author  : Nandan R
-- Dataset : 1,480 employees · 38 features · IBM HR Analytics
-- Engine  : MySQL 8+ / PostgreSQL
--           Zero-setup: run sql_runner.py (uses DuckDB)
-- ================================================================


-- ────────────────────────────────────────────────────────────────
-- SECTION 1: EXECUTIVE KPIs
-- ────────────────────────────────────────────────────────────────

-- Q1. Overall workforce summary
SELECT
    COUNT(*)                                                    AS total_employees,
    SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)           AS employees_left,
    SUM(CASE WHEN Attrition='No'  THEN 1 ELSE 0 END)           AS employees_stayed,
    ROUND(100.0*SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome),0)                                 AS avg_monthly_income,
    ROUND(AVG(Age),1)                                           AS avg_age,
    ROUND(AVG(YearsAtCompany),1)                                AS avg_tenure_years,
    ROUND(100.0*SUM(CASE WHEN OverTime='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) AS overtime_pct
FROM hr_data;


-- Q2. Attrition by the numbers — gain/loss snapshot
SELECT
    SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)           AS headcount_lost,
    ROUND(AVG(CASE WHEN Attrition='Yes' THEN MonthlyIncome END),0) AS avg_income_left,
    ROUND(AVG(CASE WHEN Attrition='No'  THEN MonthlyIncome END),0) AS avg_income_stayed,
    ROUND(AVG(CASE WHEN Attrition='Yes' THEN YearsAtCompany END),1) AS avg_tenure_left,
    ROUND(AVG(CASE WHEN Attrition='No'  THEN YearsAtCompany END),1) AS avg_tenure_stayed
FROM hr_data;


-- ────────────────────────────────────────────────────────────────
-- SECTION 2: DEPARTMENT & ROLE ANALYSIS
-- ────────────────────────────────────────────────────────────────

-- Q3. Attrition rate by department
SELECT
    Department,
    COUNT(*)                                                    AS total,
    SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)           AS attrition_count,
    ROUND(100.0*SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome),0)                                 AS avg_income,
    RANK() OVER (ORDER BY 100.0*SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*) DESC) AS risk_rank
FROM hr_data
GROUP BY Department
ORDER BY attrition_rate_pct DESC;


-- Q4. Attrition by job role — ranked highest to lowest risk
SELECT
    JobRole,
    COUNT(*)                                                    AS total,
    SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)           AS attrition_count,
    ROUND(100.0*SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome),0)                                 AS avg_income,
    RANK() OVER (ORDER BY 100.0*SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*) DESC) AS risk_rank
FROM hr_data
GROUP BY JobRole
ORDER BY attrition_rate_pct DESC;


-- Q5. Department × Job Role cross-tab (where is risk concentrated?)
SELECT
    Department,
    JobRole,
    COUNT(*)                                                    AS total,
    SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)           AS left_count,
    ROUND(100.0*SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) AS attrition_pct,
    ROUND(AVG(MonthlyIncome),0)                                 AS avg_income
FROM hr_data
GROUP BY Department, JobRole
ORDER BY attrition_pct DESC;


-- ────────────────────────────────────────────────────────────────
-- SECTION 3: DEMOGRAPHIC ANALYSIS
-- ────────────────────────────────────────────────────────────────

-- Q6. Attrition by age group
SELECT
    AgeGroup,
    COUNT(*)                                                    AS total,
    SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)           AS attrition_count,
    ROUND(100.0*SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome),0)                                 AS avg_income
FROM hr_data
GROUP BY AgeGroup
ORDER BY attrition_rate_pct DESC;


-- Q7. Attrition by marital status and gender
SELECT
    MaritalStatus,
    Gender,
    COUNT(*)                                                    AS total,
    SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)           AS attrition_count,
    ROUND(100.0*SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) AS attrition_rate_pct
FROM hr_data
GROUP BY MaritalStatus, Gender
ORDER BY attrition_rate_pct DESC;


-- Q8. Attrition by education field
SELECT
    EducationField,
    COUNT(*)                                                    AS total,
    SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)           AS attrition_count,
    ROUND(100.0*SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome),0)                                 AS avg_income
FROM hr_data
GROUP BY EducationField
ORDER BY attrition_rate_pct DESC;


-- ────────────────────────────────────────────────────────────────
-- SECTION 4: COMPENSATION ANALYSIS
-- ────────────────────────────────────────────────────────────────

-- Q9. Attrition by salary slab
SELECT
    SalarySlab,
    COUNT(*)                                                    AS total,
    SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)           AS attrition_count,
    ROUND(100.0*SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome),0)                                 AS avg_income
FROM hr_data
GROUP BY SalarySlab
ORDER BY attrition_rate_pct DESC;


-- Q10. Attrition by job level with income comparison
SELECT
    JobLevel,
    COUNT(*)                                                    AS total,
    SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)           AS attrition_count,
    ROUND(100.0*SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) AS attrition_rate_pct,
    ROUND(AVG(CASE WHEN Attrition='Yes' THEN MonthlyIncome END),0) AS avg_income_left,
    ROUND(AVG(CASE WHEN Attrition='No'  THEN MonthlyIncome END),0) AS avg_income_stayed
FROM hr_data
GROUP BY JobLevel
ORDER BY JobLevel;


-- Q11. Income percentile — where do leavers sit?
WITH income_ranked AS (
    SELECT
        EmpID,
        Attrition,
        MonthlyIncome,
        NTILE(4) OVER (ORDER BY MonthlyIncome)  AS income_quartile
    FROM hr_data
)
SELECT
    income_quartile,
    MIN(MonthlyIncome)                          AS min_income,
    MAX(MonthlyIncome)                          AS max_income,
    COUNT(*)                                    AS total,
    SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END) AS attrition_count,
    ROUND(100.0*SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) AS attrition_pct
FROM income_ranked
GROUP BY income_quartile
ORDER BY income_quartile;


-- ────────────────────────────────────────────────────────────────
-- SECTION 5: WORK PATTERN ANALYSIS
-- ────────────────────────────────────────────────────────────────

-- Q12. Overtime vs attrition — the most powerful single predictor
SELECT
    OverTime,
    COUNT(*)                                                    AS total,
    SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)           AS attrition_count,
    ROUND(100.0*SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome),0)                                 AS avg_income
FROM hr_data
GROUP BY OverTime
ORDER BY attrition_rate_pct DESC;


-- Q13. Business travel frequency vs attrition
SELECT
    BusinessTravel,
    COUNT(*)                                                    AS total,
    SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)           AS attrition_count,
    ROUND(100.0*SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) AS attrition_rate_pct
FROM hr_data
GROUP BY BusinessTravel
ORDER BY attrition_rate_pct DESC;


-- Q14. Overtime × Business Travel combined risk
SELECT
    OverTime,
    BusinessTravel,
    COUNT(*)                                                    AS total,
    SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)           AS attrition_count,
    ROUND(100.0*SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) AS attrition_pct
FROM hr_data
GROUP BY OverTime, BusinessTravel
ORDER BY attrition_pct DESC;


-- ────────────────────────────────────────────────────────────────
-- SECTION 6: SATISFACTION & ENGAGEMENT
-- ────────────────────────────────────────────────────────────────

-- Q15. Avg satisfaction scores — left vs stayed
SELECT
    Attrition,
    ROUND(AVG(JobSatisfaction),2)           AS avg_job_satisfaction,
    ROUND(AVG(EnvironmentSatisfaction),2)   AS avg_env_satisfaction,
    ROUND(AVG(WorkLifeBalance),2)           AS avg_wlb,
    ROUND(AVG(RelationshipSatisfaction),2)  AS avg_relationship_sat,
    ROUND(AVG(JobInvolvement),2)            AS avg_job_involvement
FROM hr_data
GROUP BY Attrition;


-- Q16. Attrition by job satisfaction level (1–4)
SELECT
    JobSatisfaction,
    COUNT(*)                                                    AS total,
    SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)           AS attrition_count,
    ROUND(100.0*SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) AS attrition_pct
FROM hr_data
GROUP BY JobSatisfaction
ORDER BY JobSatisfaction;


-- ────────────────────────────────────────────────────────────────
-- SECTION 7: ADVANCED ANALYTICS
-- ────────────────────────────────────────────────────────────────

-- Q17. Attrition by tenure band using CASE buckets
SELECT
    CASE
        WHEN YearsAtCompany <= 2   THEN '0-2 yrs'
        WHEN YearsAtCompany <= 5   THEN '3-5 yrs'
        WHEN YearsAtCompany <= 10  THEN '6-10 yrs'
        WHEN YearsAtCompany <= 20  THEN '11-20 yrs'
        ELSE '20+ yrs'
    END                                                         AS tenure_band,
    COUNT(*)                                                    AS total,
    SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)           AS attrition_count,
    ROUND(100.0*SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) AS attrition_pct,
    ROUND(AVG(MonthlyIncome),0)                                 AS avg_income
FROM hr_data
GROUP BY tenure_band
ORDER BY MIN(YearsAtCompany);


-- Q18. High-risk employee segment — all risk factors combined
SELECT
    COUNT(*)                                                    AS high_risk_employees,
    SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)           AS actually_left,
    ROUND(100.0*SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)/COUNT(*),1) AS attrition_rate_pct
FROM hr_data
WHERE OverTime      = 'Yes'
  AND JobLevel      = 1
  AND MonthlyIncome < 5000
  AND JobSatisfaction <= 2;


-- Q19. Rolling attrition rate by years at company (window function)
WITH yearly AS (
    SELECT
        YearsAtCompany,
        COUNT(*)                                                AS total,
        SUM(CASE WHEN Attrition='Yes' THEN 1 ELSE 0 END)       AS left_count
    FROM hr_data
    GROUP BY YearsAtCompany
)
SELECT
    YearsAtCompany,
    total,
    left_count,
    ROUND(100.0*left_count/total,1)                             AS attrition_pct,
    ROUND(AVG(100.0*left_count/total) OVER (
        ORDER BY YearsAtCompany
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ),1)                                                        AS smoothed_attrition_pct
FROM yearly
ORDER BY YearsAtCompany;


-- Q20. Employee risk score — rank every employee by combined risk factors
WITH risk_scored AS (
    SELECT
        EmpID,
        JobRole,
        Department,
        MonthlyIncome,
        Attrition,
        (CASE WHEN OverTime='Yes'             THEN 3 ELSE 0 END +
         CASE WHEN JobLevel=1                  THEN 2 ELSE 0 END +
         CASE WHEN MonthlyIncome < 5000        THEN 2 ELSE 0 END +
         CASE WHEN JobSatisfaction <= 2        THEN 2 ELSE 0 END +
         CASE WHEN YearsAtCompany <= 2         THEN 2 ELSE 0 END +
         CASE WHEN BusinessTravel='Travel_Frequently' THEN 1 ELSE 0 END +
         CASE WHEN MaritalStatus='Single'      THEN 1 ELSE 0 END +
         CASE WHEN WorkLifeBalance = 1         THEN 1 ELSE 0 END
        )                                                       AS risk_score
    FROM hr_data
)
SELECT
    EmpID, JobRole, Department, MonthlyIncome, Attrition, risk_score,
    RANK() OVER (ORDER BY risk_score DESC)                      AS risk_rank,
    NTILE(4) OVER (ORDER BY risk_score DESC)                    AS risk_quartile
FROM risk_scored
ORDER BY risk_score DESC
LIMIT 30;
