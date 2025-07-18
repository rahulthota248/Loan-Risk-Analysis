desc bankdata;

select count(*) from bankdata;

ALTER TABLE bankdata
DROP COLUMN State_Abbr;

ALTER TABLE bankdata
DROP COLUMN `ï»¿ State_Abbr`;


SELECT * FROM bankdata
WHERE Closed_Date IS NULL
   OR Home_Ownership IS NULL
   OR Grrade IS NULL
   OR Sub_Grade IS NULL
   OR Verification_Status IS NULL;
   
   
   SET SQL_SAFE_UPDATES=0;
   
UPDATE bankdata SET Product_Id = 'Unknown' WHERE Product_Id IS NULL;
UPDATE bankdata SET Region_Name = 'Unknown' WHERE Region_Name IS NULL;
UPDATE bankdata SET Purpose_Category = 'Unknown' WHERE Purpose_Category IS NULL;
UPDATE bankdata SET Gender_ID = 'Unknown' WHERE Gender_ID IS NULL;


-- KPI Queries

-- 1. Total Loan Amount Funded
SELECT SUM(loan_amount) AS Total_Loan_Amount_Funded FROM bankdata;

-- 2. Total Loans
SELECT COUNT(*) AS Total_Loans FROM bankdata;

-- 3. Total Collection
-- Step 1: Add a New Column to Store Total Collection
ALTER TABLE bankdata ADD COLUMN total_collected DECIMAL(15,2);

-- Step 2: Populate It Using This Formula
UPDATE bankdata
SET total_collected = 
    IFNULL(Total_RecPrncp, 0) + 
    IFNULL(Total_Rrec_int, 0) + 
    IFNULL(Total_Rec_Late_fee, 0) + 
    IFNULL(Recoveries, 0) + 
    IFNULL(Collection_Recovery_fee, 0);
    
    SELECT Client_id, total_collected
FROM bankdata
LIMIT 10;

-- 4. Total Interest
SELECT SUM(Total_Rrec_int) AS Total_Interest
FROM bankdata;

-- 5. Branch-Wise Revenue
SELECT 
    Branch_Name,
    ROUND(SUM(Total_Rrec_int), 2) AS Interest_Revenue,
    ROUND(SUM(Total_Fees), 2) AS Fee_Revenue,
    ROUND(SUM(Total_Rrec_int + Total_Fees), 2) AS Total_Revenue
FROM bankdata
GROUP BY Branch_Name
ORDER BY Total_Revenue DESC;

-- 6: State-Wise Loan Distribution
SELECT 
    State_Name,
    ROUND(SUM(Loan_Amount), 2) AS Total_Loan_Amount,
    COUNT(*) AS Number_of_Loans
FROM bankdata
GROUP BY State_Name
ORDER BY Total_Loan_Amount DESC;

--  7: Religion-Wise Loan Distribution
SELECT 
    Religion,
    ROUND(SUM(Loan_Amount), 2) AS Total_Loan_Amount,
    COUNT(*) AS Number_of_Loans
FROM bankdata
GROUP BY Religion
ORDER BY Total_Loan_Amount DESC;

-- KPI 8: Product Group-Wise Loan
SELECT 
    Product_id,
    ROUND(SUM(Loan_Amount), 2) AS Total_Loan_Amount,
    COUNT(*) AS Number_of_Loans
FROM bankdata
GROUP BY Product_id
ORDER BY Total_Loan_Amount DESC;

-- 9. Disbursement Trend
SELECT 
    YEAR(STR_TO_DATE(Disbursement_Date, '%Y-%m-%d')) AS Year,
    MONTH(STR_TO_DATE(Disbursement_Date, '%Y-%m-%d')) AS Month,
    SUM(loan_amount) AS Total_Disbursed
FROM bankdata
GROUP BY Year, Month
ORDER BY Year, Month;

-- 10. Grade-Wise Loan
SELECT Grrade, SUM(loan_amount) AS Total_Loan FROM bankdata GROUP BY Grrade;

-- 11. Count of Default Loans
SELECT COUNT(*) AS default_loan_count
FROM bankdata
WHERE Is_Default_Loan = 'Yes';


-- 12. Count of Delinquent Clients
SELECT COUNT(DISTINCT Client_id) AS delinquent_clients_count
FROM bankdata
WHERE Is_Delinquent_Loan = 'Yes';


-- 13. Delinquent Loans Rate
SELECT 
  ROUND(100.0 * SUM(CASE WHEN Is_Delinquent_Loan = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS delinquent_loan_rate
FROM bankdata;

-- 14. Default Loan Rate
SELECT 
  ROUND(100.0 * SUM(CASE WHEN Is_Default_Loan = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_loan_rate
FROM bankdata;

-- 15. Loan Status-Wise Loan
SELECT Loan_Status, COUNT(*) AS loan_count
FROM bankdata
GROUP BY Loan_Status;

-- 16. Age Group-Wise Loan
SELECT Age, COUNT(*) AS loan_count
FROM bankdata
GROUP BY Age
ORDER BY Age;

-- 17. No Verified Loan
SELECT COUNT(*) AS no_verified_loans
FROM bankdata
WHERE Verification_Status IS NULL OR Verification_Status = 'Not Verified';

-- 8. Loan Maturity
SELECT Term, COUNT(*) AS loan_count
FROM bankdata
GROUP BY Term
ORDER BY Term;
