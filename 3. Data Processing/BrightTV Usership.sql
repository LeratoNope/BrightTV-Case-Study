-- Databricks notebook source
        -- Check whats in our entire table--
SELECT *
FROM bright_tv_case_study.default.userprofile;

-- Check for duplicates "informal way"--
SELECT COUNT ( DISTINCT UserID) AS Subs
FROM bright_tv_case_study.default.userprofile;

-- Check for duplicates "Formal way"--
SELECT COUNT (*),
        UserID
FROM bright_tv_case_study.default.userprofile
GROUP BY UserID
HAVING COUNT(*) > 1; -- IF THERE A COUNT THAT RETURNS MORE THAN 1, THEN THERE IS A DUPLICATE

-- Inspect Gender--
SELECT DISTINCT Gender
FROM bright_tv_case_study.default.userprofile;

-- Cleaning Gender column--
SELECT DISTINCT
            CASE
                WHEN Gender = 'None' THEN 'Unknown'
                WHEN Gender = ' ' THEN 'Unknown'
                WHEN Gender IS NULL THEN 'Unknown'
            ELSE Gender
            END AS Sex
FROM bright_tv_case_study.default.userprofile;

-- Inspect race column --
SELECT DISTINCT Race
FROM bright_tv_case_study.default.userprofile;

--Cleaning Race Coloumn--
SELECT DISTINCT
            CASE
                WHEN Race = 'None' THEN 'Unknown'
                WHEN Race = 'other ' THEN 'Unknown'
                WHEN Race = ' ' THEN 'Unknown'
                WHEN Gender IS NULL THEN 'Unknown'
            ELSE Gender
            END AS ethnicity
FROM bright_tv_case_study.default.userprofile;



-- i want to understand my data, i want to know how many viwers are from each race as well as the unknowns--

SELECT COUNT(DISTINCT userid) AS Subs,
            CASE 
                WHEN Race = 'None' THEN 'unknown'
                WHEN Race = ' ' THEN 'unknown'
                WHEN Race = 'other' THEN 'unknown'
                WHEN Race IS NULL THEN 'unknown'
            ELSE Race
            END AS Ethnicity
FROM bright_tv_case_study.default.userprofile
GROUP BY Ethnicity;

--Province inspection--
SELECT DISTINCT Province
FROM bright_tv_case_study.default.userprofile;

--Cleaning Province coloumn--
SELECT DISTINCT
            CASE
                WHEN Province = 'None' THEN 'Unknown'
                WHEN Province = ' ' THEN 'Unknown'
                WHEN Gender IS NULL THEN 'Unknown'
            ELSE Province
            END AS Region
FROM bright_tv_case_study.default.userprofile;

--Age Inspection-- 
SELECT MIN(Age) AS min_age,-- Finding youngest user = 0
       MAX(Age) AS max_age,-- Finding the eldest = 114
       AVG(Age) AS average_age-- Finding the "middle" age of the viewers
FROM `bright_tv_case_study`.`default`.`userprofile`; 

SELECT DISTINCT
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

--tEPORARY tBALE--
------
CREATE OR REPLACE TEMPORARY TABLE processed_bright_tv_user_profiles As 
(SELECT 
     UserID,
        Email,
        CASE 
            WHEN 'Email' IS NOT NULL THEN 1
            WHEN 'Email'<> ' ' THEN 1
            ELSE 0
        END AS email_flag,

        CASE 
            WHEN 'Social Media Handle' IS NOT NULL THEN 1
            ELSE 0
        END AS Social_media_handle_flag,

        CASE
            WHEN gender = 'None' THEN 'unknown'
            WHEN gender = ' ' THEN 'unknown'
            WHEN gender IS NULL THEN 'unknown' 
        ELSE gender 
        END AS sex,
    
        CASE
            WHEN race = 'other' THEN 'unknown'
            WHEN race = ' ' THEN 'unknown'
            WHEN race = 'None' THEN 'unknown'
            WHEN race IS NULL THEN 'unknown'
        ELSE race
        END AS Enthnicity, 

        CASE
            WHEN province = 'None' THEN 'unknown'
            WHEN province = ' ' THEN 'unknown'
            WHEN province IS NULL THEN 'unknown'
        ELSE province
        END AS Region,

        AGE,
        CASE 
            WHEN Age = 0 THEN '01.infant: 0'
            WHEN Age BETWEEN 1 AND 12 THEN '02.Kids: 1 - 12'
            WHEN Age BETWEEN 13 AND 17 THEN '03.youth: 13 - 17'
            WHEN Age BETWEEN 18 AND 35 THEN '04.youth Adults: 18 - 35'
            WHEN Age BETWEEN 36 AND 50 THEN '05.Adults: 36 - 50'
            WHEN Age > 50 AND Age<=60 THEN '06.Elder: 51 -60'
            WHEN Age > 60 THEN '07.Pensioner: >60'
        END AS Age_group
        From bright_tv_case_study.default.userprofile);




