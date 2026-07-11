-- Databricks notebook source
SELECT * 
FROM `bright_tv_case_study`.`default`.`userprofile` LIMIT 100;

----------------------------------------
--Duplicate Checks
----------------------------------------
SELECT UserID,
    COUNT(*) AS duplicate_count 
FROM bright_tv_case_study.default.userprofile
GROUP BY UserID 
HAVING COUNT(*) > 1; 

---------------------------------------
--Check the size of the data
---------------------------------------
SELECT COUNT(*) AS number_of_rows, 
    COUNT(DISTINCT UserID) AS number_subs 
FROM bright_tv_case_study.default.userprofile;

--------------------------------------
--Check for rows where UserID is NULL
--------------------------------------
SELECT COUNT(*) AS cnt
FROM bright_tv_case_study.default.userprofile
WHERE UserID IS NULL;

-------------------------------------
--Gender Checks
-------------------------------------
SELECT DISTINCT Gender -- To check what is contained in the category
From bright_tv_case_study.default.userprofile;

SELECT DISTINCT
    CASE
        WHEN Gender = 'None' THEN 'unknown'---Replaces the value 'none' with 'unknown'
        WHEN Gender = ' ' THEN 'unknown'---Replaces the blank value with 'unknown'
        WHEN Gender is NULL THEN 'unknown'--- Replaces the value 'null' with 'unknown'
    ELSE Gender-- where it is male/female, it remains as that
    END AS gender_clean
FROM `bright_tv_case_study`.`default`.`userprofile`;

--------------------------------------
--Race Checks
---------------------------------------
SELECT DISTINCT Race -- To check what is contained in the category
FROM `bright_tv_case_study`.`default`.`userprofile`;

SELECT DISTINCT
    CASE 
        WHEN Race = 'None' THEN 'unknown'---Replaces the value 'none' with 'unknown'
        WHEN Race = ' ' THEN 'unknown'--- Replaces the blank value with 'unknown'
        WHEN Race IS NULL THEN 'unknown'---Replaces the value 'null' wih 'unknown'
    ELSE Race
    END AS ethnicity
FROM `bright_tv_case_study`.`default`.`userprofile`; 

-----------------------------------
--Province
-----------------------------------
SELECT DISTINCT Province
FROM `bright_tv_case_study`.`default`.`userprofile`; 

SELECT DISTINCT
    CASE
        WHEN Province = 'none' THEN 'uncategorized'
        WHEN Province = ' ' THEN 'uncategorized'
    ELSE Province
    END AS Region
FROM `bright_tv_case_study`.`default`.`userprofile`; 

--------------------------------------
--Age Check
--------------------------------------
SELECT MIN(Age) AS min_age,-- Finding youngest user = 0
       MAX(Age) AS max_age-- Finding the eldest = 114
FROM `bright_tv_case_study`.`default`.`userprofile`; 

SELECT 
    CASE
       WHEN Age = 0 THEN 'infant'
       WHEN Age BETWEEN 1 AND 12 THEN 'kid'
       WHEN Age BETWEEN 13 AND 19 THEN 'teenager'
       WHEN Age BETWEEN 20 AND 35 THEN 'youth'
       WHEN Age BETWEEN 36 AND 50 THEN 'adult'
       WHEN Age > 50 AND Age <= 60 THEN 'elder'
       WHEN Age > 60 THEN 'pensioner'
    END AS Age_group
FROM `bright_tv_case_study`.`default`.`userprofile`;

SELECT COUNT(*) AS cnt 
FROM `bright_tv_case_study`.`default`.`userprofile`
WHERE age IS NULL;

WITH user_profiles AS (
SELECT UserID,

    CASE
        WHEN Province = 'none' THEN 'uncategorized'
        WHEN Province = ' ' THEN 'uncategorized'
    ELSE Province
    END AS Region,

    Age,
    CASE
       WHEN Age = 0 THEN 'infant'
       WHEN Age BETWEEN 1 AND 12 THEN 'kid'
       WHEN Age BETWEEN 13 AND 19 THEN 'teenager'
       WHEN Age BETWEEN 20 AND 35 THEN 'youth'
       WHEN Age BETWEEN 36 AND 50 THEN 'adult'
       WHEN Age > 50 AND Age <= 60 THEN 'elder'
       WHEN Age > 60 THEN 'pensioner'
    END AS Age_group,

    CASE
        WHEN (Email IS NOT NULL) OR (Email=' ') OR (Email NOT IN ('None')) THEN 1 
    ELSE 0 
    END AS email_flag,

    CASE 
        WHEN (`Social Media Handle` IS NOT NULL) OR (`Social Media Handle`=' ') OR (`Social Media Handle` NOT IN ('None')) THEN 1 
        ELSE 0 
    END AS sm_flag, 
 
    CASE 
        WHEN Race='other' THEN 'None' 
        WHEN Race=' ' THEN 'None' 
    ELSE Race 
    END AS Race, 
 
    CASE 
        WHEN Gender =' ' THEN 'None' 
        ELSE Gender 
    END AS Gender
FROM `bright_tv_case_study`.`default`.`userprofile`
),
viewership AS (
    SELECT
    COALESCE(UserID0,userid4) AS userid,
    TO_CHAR(RecordDate2, 'yyyyMM') AS month_id,
    TO_DATE(RecordDate2) AS watch_date,
    --TIME(RecordDate2) AS watch_time,
    TO_CHAR(RecordDate2, 'DD') AS day_of_week,
    DAYNAME(RecordDate2) AS day_name,

    CASE
        WHEN day_name IN ('Sat', 'Sun') THEN 'weekend'
        ELSE 'weekday'
    END AS day_classification,

    MONTHNAME(RecordDate2) AS month_name,

    CASE 
        WHEN Channel2 IN ('SawSee','Sawsee') THEN 'SawSee'
        WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport', 'Supersport Live Events', 'DStv Events 1') THEN 'Live Events'
    ELSE Channel2
    END AS Tv_channel,

    date_format(RecordDate2, 'HH:mm:ss') AS watch_time,
    CASE
        WHEN watch_time BETWEEN '00:00:00' AND '05:59:59' THEN '01. Midnight'
        WHEN watch_time BETWEEN '06:00:00' AND '11:59:59' THEN '02. Morning'
        WHEN watch_time BETWEEN '12:00:00' AND '16:59:59' THEN '03. Afternoon'
        WHEN watch_time BETWEEN '17:00:00' AND '23:59:59' THEN '04. Evening'
    END AS time_of_day,

    DATE_FORMAT(`Duration 2`, 'HH:mm:ss') AS duration,
    CASE 
        WHEN duration BETWEEN '00:05:00' AND '00:30:00' THEN '01. Low Usage: <30 min'
        WHEN duration BETWEEN '00:30:01' AND '00:59:59' THEN '02. Med Usage: <60 min'
        WHEN duration > '00:59:59' THEN '03. High Usage: >60 min'
        ELSE '04. No Usage'
    END AS screen_time_bucket,

    HOUR(RecordDate2) AS hour_of_day

FROM bright_tv_case_study.default.viewership
)
SELECT Coalesce(A.userid,B.userid) AS sub_id,
       month_id,
       watch_date,
       day_of_week,
       day_name,
       day_classification,
       month_name,
       Tv_channel,
       time_of_day,
       hour_of_day,
       screen_time_bucket,
       --user_flag,
       duration,
       Region,
       Age_group,
       email_flag,
       sm_flag,
       Race,
       Gender
FROM viewership AS A
LEFT JOIN user_profiles AS B
ON A.userid=B.userid;



