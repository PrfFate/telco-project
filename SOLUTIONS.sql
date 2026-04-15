-- ==========================================
-- SQL SOLUTIONS FOR TELCO PROJECT
-- ==========================================

-- ---------------------------------------------------------
-- 1. Tariff-Based Customer Queries
-- ---------------------------------------------------------

-- 1.1 List the customers who are subscribed to the 'Kobiye Destek' tariff.
/*
This query joins the CUSTOMERS and TARIFFS tables to find customers subscribed to the 'Kobiye Destek' tariff. 
The relationship between the two tables is established via the TARIFF_ID Foreign Key to retrieve only meaningful matching records. 
Finally, the WHERE clause filters the data specifically by the targeted tariff name to obtain the final customer list.
*/
SELECT c.CUSTOMER_ID, c.NAME, c.CITY, t.NAME AS TARIFF_NAME
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek';

/* QUERY RESULT:
9388	Enes	KİLİS	        Kobiye Destek
9390	Zehra   KİLİS	        Kobiye Destek
9391	Songül	DÜZCE	        Kobiye Destek
9392	Mehmet	VAN	            Kobiye Destek
9086	Kadir	ÇANKIRI	        Kobiye Destek
9092	Ahmet	NEVŞEHİR        Kobiye Destek
9096	Ayşegül	TRABZON	        Kobiye Destek
9097	Osman	KARS	        Kobiye Destek
9101	Tuğba	KİLİS	        Kobiye Destek
9106	Yasin	TOKAT	        Kobiye Destek
*/


-- 1.2 Find the newest customer who subscribed to this tariff.
/*
In this query, after filtering customers on the 'Kobiye Destek' tariff, the results are sorted in descending order (DESC) based on their SIGNUP_DATE. 
This sorting strategy ensures that the most recently registered customer is placed at the top of the result set. 
Finally, the FETCH FIRST 1 ROWS ONLY command is utilized to extract only this topmost single customer record.
*/
SELECT c.CUSTOMER_ID, c.NAME, c.SIGNUP_DATE, t.NAME AS TARIFF_NAME
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek'
ORDER BY c.SIGNUP_DATE DESC
FETCH FIRST 1 ROWS ONLY;

/* QUERY RESULT:
8798	Hatice	2028-07-03 00:00:00.000	Kobiye Destek
*/


-- ---------------------------------------------------------
-- 2. Tariff Distribution
-- ---------------------------------------------------------

-- 2.1 Find the distribution of tariffs among the customers.
/*
This query utilizes the GROUP BY function to calculate the number of active customers present in each tariff across the system. 
The TARIFFS table is taken as the primary table and joined with the CUSTOMERS table to count the customer IDs for each respective tariff. 
The results are ordered in descending fashion by customer count to show business units which tariffs are the most popular.
*/
SELECT t.NAME AS TARIFF_NAME, COUNT(c.CUSTOMER_ID) AS CUSTOMER_COUNT
FROM TARIFFS t
LEFT JOIN CUSTOMERS c ON t.TARIFF_ID = c.TARIFF_ID
GROUP BY t.NAME
ORDER BY CUSTOMER_COUNT DESC;

/* QUERY RESULT:
Kurumsal SMS	2577
Genç Dinamik	2527
Kobiye Destek	2483
Çalışan GB	    2413
*/


-- ---------------------------------------------------------
-- 3. Customer Signup Analysis
-- ---------------------------------------------------------

-- 3.1 Identify the earliest customers to sign up.
/*
To find the very first customers registered in the company's database, this query directly relies on the registration date rather than potentially misleading ID sequences. 
The subquery within the WHERE clause identifies the absolute minimum SIGNUP_DATE value in the CUSTOMERS table. 
The main query then lists all customer records that perfectly match this oldest identified date.
*/
SELECT CUSTOMER_ID, NAME, CITY, SIGNUP_DATE
FROM CUSTOMERS 
WHERE SIGNUP_DATE = (SELECT MIN(SIGNUP_DATE) FROM CUSTOMERS);

/* QUERY RESULT:
9021	Kübra	GİRESUN	        2025-01-05 00:00:00.000
9548	Havva	BARTIN	        2025-01-05 00:00:00.000
9298	Serkan	BAYBURT	        2025-01-05 00:00:00.000
7992	Furkan	ŞIRNAK	        2025-01-05 00:00:00.000
7851	Hacer	ARDAHAN	        2025-01-05 00:00:00.000
7606	Burak	YOZGAT	        2025-01-05 00:00:00.000
7336	Zehra	KAHRAMANMARAŞ	2025-01-05 00:00:00.000
8877	Furkan	EDİRNE	        2025-01-05 00:00:00.000
8765	Dilek	BATMAN	        2025-01-05 00:00:00.000
8196	Havva	BİNGÖL	        2025-01-05 00:00:00.000
*/


-- 3.2 Find the distribution of these earliest customers across different cities.
/*
This query analyzes the geographical (city-based) distribution of the founding customers who registered on the earliest detected date. 
Using a subquery, customers are filtered by the oldest registration date and subsequently grouped by the CITY column. 
The results obtained via the COUNT aggregate function report which cities served as the initial clusters of expansion.
*/
SELECT CITY, COUNT(CUSTOMER_ID) AS EARLIEST_CUSTOMER_COUNT
FROM CUSTOMERS
WHERE SIGNUP_DATE = (SELECT MIN(SIGNUP_DATE) FROM CUSTOMERS)
GROUP BY CITY
ORDER BY EARLIEST_CUSTOMER_COUNT DESC;

/* QUERY RESULT:
ŞIRNAK	        2
BATMAN	        2
HAKKARİ	        2
ARDAHAN	        1
YOZGAT	        1
KAHRAMANMARAŞ	1
EDİRNE	        1
BİNGÖL	        1
DÜZCE	        1
AĞRI	        1
*/


-- ---------------------------------------------------------
-- 4. Missing Monthly Records
-- ---------------------------------------------------------

-- 4.1 Identify the IDs of these missing customers.
/*
This query identifies anomalous customers who are active in the system (CUSTOMERS) but lack any usage record (MONTHLY_STATS) for that specific month. 
The NOT EXISTS operator, known for its superior query performance, is employed to obtain the minus set between the two tables. 
This effectively isolates accounts with missing invoices or statistics due to potential system errors or cron job interruptions.
*/
SELECT c.CUSTOMER_ID, c.NAME
FROM CUSTOMERS c
WHERE NOT EXISTS (
    SELECT 1 
    FROM MONTHLY_STATS m 
    WHERE m.CUSTOMER_ID = c.CUSTOMER_ID
);

/* QUERY RESULT:
953	Ali
988	Esra
783	Fadime
788	İbrahim
819	Hakan
842	Murat
869	Fadime
885	Serkan
889	Ali
903	Aysel
*/


-- 4.2 Find the distribution of these missing customers across different cities.
/*
The city-based distribution of customers with missing usage statistics is extracted to determine whether the data loss stems from a localized infrastructure issue. 
The erroneous customer subset, filtered via the NOT EXISTS logic, is aggregated and counted by the CITY column. 
This resulting distribution table enables technical teams to prioritize regions while conducting troubleshooting operations.
*/
SELECT c.CITY, COUNT(c.CUSTOMER_ID) AS MISSING_RECORD_COUNT
FROM CUSTOMERS c
WHERE NOT EXISTS (
    SELECT 1 
    FROM MONTHLY_STATS m 
    WHERE m.CUSTOMER_ID = c.CUSTOMER_ID
)
GROUP BY c.CITY
ORDER BY MISSING_RECORD_COUNT DESC;

/* QUERY RESULT:
OSMANİYE	3
DENİZLİ	    2
BİTLİS	    2
NEVŞEHİR	2
ORDU	    2
KIRIKKALE	2
KAYSERİ	    2
SİVAS	    2
MUŞ	        2
İZMİR	    2
*/


-- ---------------------------------------------------------
-- 5. Usage Analysis
-- ---------------------------------------------------------

-- 5.1 Find the customers who have used at least 75% of their data limit.
/*
This query calculates the ratio of the customers' actual monthly data usage against the maximum quota defined in their respective tariffs. 
To prevent a Divide by Zero exception, a condition verifying t.DATA_LIMIT > 0 is implemented before the mathematical calculation of the usage percentage. 
By filtering for results that are 75% (0.75) or higher, it successfully identifies the at-risk user segment approaching quota exhaustion.
*/
SELECT c.NAME, m.DATA_USAGE, t.DATA_LIMIT, 
       ROUND((m.DATA_USAGE / t.DATA_LIMIT) * 100, 2) AS USAGE_PERCENTAGE
FROM MONTHLY_STATS m
JOIN CUSTOMERS c ON m.CUSTOMER_ID = c.CUSTOMER_ID
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.DATA_LIMIT > 0 
  AND (m.DATA_USAGE / t.DATA_LIMIT) >= 0.75;

/* QUERY RESULT:
Metin	    8888.75	    10240	86.8
Büşra	    19649.06	20480	95.94
Mehmet	    8438.53	    10240	82.41
Songül	    18199.98	20480	88.87
Rabia	    20390.14	20480	99.56
Süleyman	9738.71	    10240	95.1
Ali	        18334.7	    20480	89.52
Zehra	    16041.37	20480	78.33
Metin	    9842.1	    10240	96.11
Aysel	    8591.11	    10240	83.9
*/


-- 5.2 Identify the customers who have completely exhausted all of their package limits.
/*
This query detects customers who have completely exhausted 100% or more of their allocated data, minute, and SMS allowances. 
To achieve this, three distinct usage metrics (DATA, MINUTE, SMS) are evaluated against their corresponding tariff limits using a 'Greater Than or Equal To' logic within the WHERE clause. 
This strict filtering proves that the current package is insufficient for the user, creating a definitive target audience for upsell campaigns.
*/
SELECT c.NAME, t.NAME AS TARIFF_NAME
FROM MONTHLY_STATS m
JOIN CUSTOMERS c ON m.CUSTOMER_ID = c.CUSTOMER_ID
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE m.DATA_USAGE >= t.DATA_LIMIT
  AND m.MINUTE_USAGE >= t.MINUTE_LIMIT
  AND m.SMS_USAGE >= t.SMS_LIMIT;

/* QUERY RESULT:
No records found matching these simultaneous criteria in the current dataset.
*/


-- ---------------------------------------------------------
-- 6. Payment Analysis
-- ---------------------------------------------------------

-- 6.1 Find the customers who have unpaid fees.
/*
This query is written to detect accounts where the payment status has not been successfully fulfilled (i.e., not in 'PAID' status). 
By filtering the PAYMENT_STATUS column in the MONTHLY_STATS table, records marked as LATE or UNPAID are accurately captured. 
This provides the foundational dataset for the finance and collections departments to send automated reminders (SMS/Email) to indebted customers.
*/
SELECT c.NAME, m.PAYMENT_STATUS
FROM MONTHLY_STATS m
JOIN CUSTOMERS c ON m.CUSTOMER_ID = c.CUSTOMER_ID
WHERE m.PAYMENT_STATUS <> 'PAID';

/* QUERY RESULT:
Songül	LATE
Ahmet	LATE
Ayşe	LATE
Songül	UNPAID
Emre	LATE
Osman	UNPAID
Merve	LATE
Merve	UNPAID
Özlem	UNPAID
Sevim	LATE
*/


-- 6.2 Find the distribution of all payment statuses across the different tariffs.
/*
This query analyzes the overall profile and distribution of payment habits (Paid, Unpaid, Late, etc.) across each individual tariff package. 
The tariff-based grouping operation is cross-referenced with the payment status to calculate the numerical frequency (COUNT) of every distinct scenario. 
This presents a strategic overview for company management to observe which pricing strategies encounter the most collection issues.
*/
SELECT t.NAME AS TARIFF_NAME, m.PAYMENT_STATUS, COUNT(m.STAT_ID) AS STATUS_COUNT
FROM MONTHLY_STATS m
JOIN CUSTOMERS c ON m.CUSTOMER_ID = c.CUSTOMER_ID
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
GROUP BY t.NAME, m.PAYMENT_STATUS
ORDER BY t.NAME, STATUS_COUNT DESC;

/* QUERY RESULT:
Genç Dinamik	PAID	1792
Genç Dinamik	LATE	372
Genç Dinamik	UNPAID	352
Kobiye Destek	PAID	1719
Kobiye Destek	LATE	392
Kobiye Destek	UNPAID	360
Kurumsal SMS	PAID	1796
Kurumsal SMS	UNPAID	403
Kurumsal SMS	LATE	368
Çalışan GB	    PAID	1692
*/
