desc debitdata;


select count(*) from debitdata;


UPDATE debitdata
SET Customer_Name = TRIM(REPLACE(REPLACE(Customer_Name, 'Mr.', ''), 'Ms.', ''));


select Customer_Name from debitdata;

select Transaction_Date from debitdata;


ALTER TABLE debitdata
MODIFY COLUMN Transaction_Date DATE;    -- change data type from text to date


ALTER TABLE debitdata 
DROP COLUMN ï»¿Customer_ID;


desc debitdata;
SELECT Customer_Name, Account_Number, Transaction_Date, COUNT(*)
FROM debitdata
GROUP BY Customer_Name, Account_Number, Transaction_Date
HAVING COUNT(*) > 1;


SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN Customer_Name IS NULL OR TRIM(Customer_Name) = '' THEN 1 ELSE 0 END) AS customer_name_missing,
    SUM(CASE WHEN Account_Number IS NULL THEN 1 ELSE 0 END) AS account_number_missing,
    SUM(CASE WHEN Transaction_Date IS NULL THEN 1 ELSE 0 END) AS transaction_date_missing
FROM debitdata;

SELECT DISTINCT Transaction_Type FROM debitdata;
SELECT DISTINCT Transaction_Method FROM debitdata;


SELECT 
    COUNT(*) AS total_transactions,
    MIN(Amount) AS min_amount,
    MAX(Amount) AS max_amount,
    AVG(Amount) AS avg_amount,
    STDDEV(Amount) AS std_dev
FROM debitdata;

SELECT 
    MIN(Balance) AS min_balance,
    MAX(Balance) AS max_balance,
    AVG(Balance) AS avg_balance
FROM debitdata;

SELECT Transaction_Type, COUNT(*) AS total, SUM(Amount) AS total_amount
FROM debitdata
GROUP BY Transaction_Type;

SELECT Transaction_Method, COUNT(*) AS count, SUM(Amount) AS total_amount
FROM debitdata
GROUP BY Transaction_Method;

SELECT Customer_Name, SUM(Amount) AS total_amount
FROM debitdata
GROUP BY Customer_Name
ORDER BY total_amount DESC
LIMIT 10;

SELECT 
    DATE_FORMAT(Transaction_Date, '%Y-%m') AS month,
    COUNT(*) AS num_transactions,
    SUM(Amount) AS total_amount
FROM debitdata
GROUP BY month
ORDER BY month;

SELECT 
    CASE 
        WHEN Amount < 1000 THEN 'Low'
        WHEN Amount BETWEEN 1000 AND 10000 THEN 'Medium'
        WHEN Amount > 10000 THEN 'High'
        ELSE 'Unknown'
    END AS amount_bucket,
    COUNT(*) AS transaction_count
FROM debitdata
GROUP BY amount_bucket;

-- 1 Total Credit Amount:
SELECT SUM(Amount) AS total_credit_amount
FROM debitdata
WHERE Transaction_Type = 'Credit';

-- 2-Total Debit Amount:
SELECT SUM(Amount) AS total_debit_amount
FROM debitdata
WHERE Transaction_Type = 'Debit';

-- credit to debit ratio
SELECT 
    (SUM(CASE WHEN Transaction_Type = 'Credit' THEN Amount ELSE 0 END) / 
     SUM(CASE WHEN Transaction_Type = 'Debit' THEN Amount ELSE 1 END)) AS credit_debit_ratio
FROM debitdata;

-- Net Transcation Amount
SELECT 
    ROUND(
        SUM(CASE WHEN Transaction_Type = 'Credit' THEN Amount ELSE 0 END) -
        SUM(CASE WHEN Transaction_Type = 'Debit' THEN Amount ELSE 0 END), 
    2) AS net_transaction_amount
FROM debitdata;

-- 5 Account Activity Ratio
SELECT 
    Customer_Name,
    Round(COUNT(*) / MAX(Balance), 7) AS account_activity_ratio
FROM debitdata
GROUP BY Customer_Name;

-- 7 Total Transaction Amount by Branch

SELECT Branch, round(SUM(Amount), 2) AS total_transaction_amount
FROM debitdata
GROUP BY Branch
ORDER BY total_transaction_amount DESC;


-- 8. Transaction Volume by Bank

SELECT Bank_Name, Round(SUM(Amount),2) AS total_transaction_amount
FROM debitdata
GROUP BY Bank_Name
ORDER BY total_transaction_amount DESC;

-- 9 Transcation Method Distribution 
SELECT 
    Transaction_Method,
    COUNT(*) AS transaction_count,
    ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM debitdata), 2) AS percentage
FROM debitdata
GROUP BY Transaction_Method;


-- 10. Branch Transaction Growth (Month-over-Month % Change)

SELECT 
    Branch,
    DATE_FORMAT(Transaction_Date, '%Y-%m') AS month,
    SUM(Amount) AS monthly_total,
    LAG(SUM(Amount)) OVER (PARTITION BY Branch ORDER BY DATE_FORMAT(Transaction_Date, '%Y-%m')) AS previous_month_total,
    ROUND(((SUM(Amount) - LAG(SUM(Amount)) OVER (PARTITION BY Branch ORDER BY DATE_FORMAT(Transaction_Date, '%Y-%m'))) / 
          LAG(SUM(Amount)) OVER (PARTITION BY Branch ORDER BY DATE_FORMAT(Transaction_Date, '%Y-%m'))) * 100, 2) AS growth_percentage
FROM debitdata
GROUP BY Branch, month
ORDER BY Branch, month;


-- 11. High-Risk Transaction Flag
-- Assume threshold for high-risk = ₹100,000

SELECT *,
       CASE 
           WHEN Amount > 5000 THEN 'High Risk'
           ELSE 'Normal'
       END AS risk_flag
FROM debitdata;

-- 12. Suspicious Transaction Frequency

SELECT 
    COUNT(*) AS high_risk_transaction_count
FROM debitdata
WHERE Amount > 5000;
