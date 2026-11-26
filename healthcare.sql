CREATE DATABASE healthcare_db;
USE healthcare_db;

SELECT COUNT(*)
FROM healthcare_patients;

DESCRIBE healthcare_patients;

select *
from healthcare_patients
where patient_state='CA';

select patient_id,bmi
from healthcare_patients
where bmi > 30;

select count(distinct patient_state) as total_state
from healthcare_patients;

select 
patient_state,
count(*) as  total_patient_records
from healthcare_patients
group by patient_state
order by total_patient_records desc;

select payer_type,
count(*) as total_patient_records
from healthcare_patients
group by payer_type
order by total_patient_records desc;

select region,
Round(avg(bmi), 2) as avg_bmi
from healthcare_patients
group by region
order by avg_bmi ;
 
 #Top 5 States by Average Ozone#

select patient_state,
round(avg(ozone), 2) as avg_ozone
from healthcare_patients
group by patient_state
order by  avg_ozone desc
limit 5;

 # Find States Where Average BMI is Greater Than 30#
 
 select patient_state,
 round(avg(bmi), 2) as avg_bmi
 from healthcare_patients
 group by patient_state
 having avg_bmi > 30
 order by avg_bmi desc;
 
 #States Having More Than 500 Patients#
 
select patient_state,
count(*) as total_patient
from healthcare_patients
group by patient_state
having count(*) > 500
order by total_patient desc;

# Calculate Average BMI for Each Insurance Type#
select payer_type,
count(*) as total_patient,
round(avg(bmi), 2) as avg_bmi
from healthcare_patients
where payer_type != "unknown"
group by payer_type
order by avg_bmi desc;

#Count Patients with BMI Greater Than 30 by Region#
select region,
count(*) as total_patient
from healthcare_patients
where region != "unknown" And bmi >30
group by region
order by total_patient desc;

#Count COMMERCIAL Insurance Patients by State#

select patient_state,payer_type,
count(*) as total_patient
from healthcare_patients
where payer_type ="COMMERCIAL" AND patient_state != "unknown"
group by patient_state
order by total_patient desc 
limit 10;

# Find Top 5 States with Highest Average BMI#
SELECT patient_state,
count(*) as total_patient,
round(avg(bmi), 2) as avg_bmi
from healthcare_patients
where patient_state !="Unknown" and bmi is not null
group by patient_state
order by avg_bmi desc
limit 5;

# Find Insurance Types with Average BMI Greater Than 28#

select payer_type,
count(*) as total_patient,
round(avg(bmi), 2) as avg_bmi
from healthcare_patients
where payer_type !="UNKNOWN" AND bmi is not null
group by payer_type
having avg_bmi > 28
order by avg_bmi desc;

#Top 10 States with Highest High-BMI Patient Percentage#
SELECT
    patient_state,
    COUNT(*) AS total_patients,
    SUM(CASE WHEN bmi > 30 THEN 1 ELSE 0 END) AS high_bmi_patients,
    ROUND(
        SUM(CASE WHEN bmi > 30 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS high_bmi_percentage

FROM healthcare_patients

WHERE patient_state != 'UNKNOWN'
  AND bmi IS NOT NULL

GROUP BY patient_state

HAVING COUNT(*) >= 30

ORDER BY high_bmi_percentage DESC

LIMIT 10;

#State-wise PM2.5 and Average BMI Analysis#
-- Question 17: State-wise PM2.5 and Average BMI Analysis
-- Report Section: Environmental Pollution Analysis

SELECT
    patient_state,
    COUNT(*) AS total_patient,
    ROUND(AVG(PM25), 2) AS avg_PM25,
    ROUND(AVG(bmi), 2) AS avg_bmi
FROM healthcare_patients
WHERE patient_state != 'UNKNOWN'
  AND bmi IS NOT NULL
  AND PM25 IS NOT NULL
GROUP BY patient_state
HAVING COUNT(*) >= 30
ORDER BY avg_PM25 DESC
LIMIT 10;

# Region-wise Air Pollution Comparison#
select region,
count(*) as total_patient,
round(avg(ozone), 2) as avg_ozone,
round(avg(N02), 2) as avg_no2,
round(avg(PM25), 2)as avg_pm25
from healthcare_patients
where region != "UNKNOWN"
and ozone is not null
and N02 is not null
and PM25 is not null
group by region
order by avg_pm25 desc
limit 5;

#Region-wise High-BMI Patient Percentage#
select region,
count(*) as total_patients,
sum(case when bmi >30 then 1 else 0 end) as high_bmi_patient,
round(
sum( case when bmi >30 then 1 else 0 end) 
* 100.0 / count(*)
,2)as high_bmi_percentage
from healthcare_patients
where region != "unknown"
and bmi is not null
group by region 
order by high_bmi_percentage desc;

# Region-wise Insurance Coverage Analysis#

SELECT
    Region,
    payer_type,
    COUNT(*) AS total_patients,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (PARTITION BY Region),
        2
    ) AS insurance_percentage

FROM healthcare_patients

WHERE Region != 'UNKNOWN'
  AND payer_type != 'UNKNOWN'
  AND Region IS NOT NULL
  AND payer_type IS NOT NULL

GROUP BY Region, payer_type

ORDER BY Region ASC, insurance_percentage DESC;

# Insurance-wise High BMI Patient Analysis#
select payer_type,
count(*) as total_patients,
sum(case when bmi >30 then 1 else 0 end) as high_bmi_patients,
round(
sum(case when bmi >30 then 1 else 0 end)
*100 / count(*)
,2) as high_bmi_percentage,
round(avg(bmi), 2) as avg_bmi
from healthcare_patients
where payer_type != "UNKNOWN" 
and payer_type is not null
and bmi is not null
group by payer_type
order by high_bmi_percentage desc;

#Region-wise BMI Category Distribution#
WITH bmi_data AS (
    SELECT
        Region,
        CASE
            WHEN bmi < 18.5 THEN 'Underweight'
            WHEN bmi < 25 THEN 'Normal'
            WHEN bmi < 30 THEN 'Overweight'
            ELSE 'Obese'
        END AS bmi_category
    FROM healthcare_patients
    WHERE bmi IS NOT NULL
      AND Region IS NOT NULL
      AND Region != 'UNKNOWN'
),

category_counts AS (
    SELECT
        Region,
        bmi_category,
        COUNT(*) AS total_patients
    FROM bmi_data
    GROUP BY Region, bmi_category
)

SELECT
    Region,
    bmi_category,
    total_patients,
    ROUND(
        total_patients * 100.0 /
        SUM(total_patients) OVER (PARTITION BY Region),
        2
    ) AS bmi_percentage
FROM category_counts
ORDER BY Region ASC, total_patients DESC;

#State-wise Air Pollution Analysis#

select patient_state,
count(*) as total_patient,
round(avg(PM25),2)as avg_pm25,
round(avg(ozone),2)as avg_ozone
from healthcare_patients
where patient_state!= "Unknown" and patient_state is not null
and ozone is not null
and PM25 is not null
group by patient_state
HAVING COUNT(*) >= 50
order by avg_pm25 desc
limit 10;

# Insurance-wise Air Pollution Analysis#

select payer_type,
count(*) as total_patient,
round(avg(PM25),2)as avg_pm25,
round(avg(ozone),2)as avg_ozone
from healthcare_patients
where payer_type!= "Unknown" and payer_type is not null
and ozone is not null
and PM25 is not null
group by payer_type
HAVING COUNT(*) >= 100
order by avg_pm25 desc;

# Race-wise BMI Analysis#
select patient_race,
count(*) as total_patients,
sum(case when bmi >30 then 1 else 0 end) as high_bmi_patients,
round(
sum(case when bmi >30 then 1 else 0 end)
*100 / count(*)
,2) as high_bmi_percentage,
round(avg(bmi), 2) as avg_bmi
from healthcare_patients
where patient_race != "UNKNOWN" 
and patient_race is not null
and bmi is not null
group by patient_race
having count(*) >=50
order by high_bmi_percentage desc;

#Regional Insurance & High-BMI Analysis#

select region,
payer_type,
count(*) as total_patient,
sum(case when bmi >30 then 1 else 0 end) as high_bmi_patients,
round(
sum(case when bmi >30 then 1 else 0 end)
*100 / count(*)
,2) as high_bmi_percentage
from healthcare_patients
where payer_type != "UNKNOWN" AND region !="UNKNOWN"
and payer_type is not null 
and region is not null
and bmi is not null
group by region,payer_type
having count(*) >= 30
order by region asc,high_bmi_percentage desc;

# State-wise BMI and Pollution Comparison#

select patient_state,
count(*) as total_patient,
round(avg(bmi),2) as avg_bmi,
round(avg(PM25),2)as avg_pm25,
sum(case when bmi >30 then 1 else 0 end) as high_bmi_patients,
round(
sum(case when bmi >30 then 1 else 0 end)
*100 / count(*)
,2) as high_bmi_percentage
from healthcare_patients
where patient_state != "UNKNOWN" AND region !="UNKNOWN"
and payer_type is not null 
and region is not null
and bmi is not null
group by region,payer_type
having count(*) >= 50
order by region asc,payer_type desc;

# State-wise Patient Distribution Analysis#

select patient_state,
count(*) as total_patient,
round (
count(*) *100/
(
select count(*) 
from healthcare_patients
where patient_state != "UNknown"
And patient_state is not null
),2
)as patient_percentage
from healthcare_patients
WHERE patient_state != 'UNKNOWN'
  AND patient_state IS NOT NULL
group by patient_state
order by patient_percentage desc
limit 10 ;

#Regional Insurance Distribution#
SELECT
    h1.Region,
    h1.payer_type,
    COUNT(*) AS total_patients,

    ROUND(
        COUNT(*) * 100.0 / regional.total_patients,
        2
    ) AS insurance_percentage

FROM healthcare_patients AS h1

JOIN (
    SELECT
        Region,
        COUNT(*) AS total_patients
    FROM healthcare_patients
    WHERE Region IS NOT NULL
      AND Region != 'UNKNOWN'
      AND payer_type IS NOT NULL
      AND payer_type != 'UNKNOWN'
    GROUP BY Region
) AS regional
ON h1.Region = regional.Region

WHERE h1.Region IS NOT NULL
  AND h1.Region != 'UNKNOWN'
  AND h1.payer_type IS NOT NULL
  AND h1.payer_type != 'UNKNOWN'

GROUP BY
    h1.Region,
    h1.payer_type,
    regional.total_patients

HAVING COUNT(*) >= 30

ORDER BY
    h1.Region ASC,
    insurance_percentage DESC;
    
    #Insurance-wise BMI Category Analysis#
    
 -- Question 30: Insurance-wise BMI Category Analysis

SELECT
    payer_type,

    CASE
        WHEN bmi < 18.5 THEN 'Underweight'
        WHEN bmi < 25 THEN 'Normal'
        WHEN bmi < 30 THEN 'Overweight'
        ELSE 'Obese'
    END AS bmi_category,

    COUNT(*) AS total_patients,
    ROUND(AVG(bmi), 2) AS avg_bmi

FROM healthcare_patients

WHERE bmi IS NOT NULL
  AND payer_type IS NOT NULL
  AND payer_type != 'UNKNOWN'

GROUP BY payer_type, bmi_category

ORDER BY payer_type ASC,
         total_patients DESC;
   
 #Regional Pollution & High BMI Analysis#
 
 -- Question 31: Regional PM25 & High BMI Analysis

SELECT
    Region,

    CASE
        WHEN PM25 < 10 THEN 'LOW'
        ELSE 'HIGH'
    END AS PM25_category,

    COUNT(*) AS total_patients,

    ROUND(AVG(PM25), 2) AS avg_PM25,

    ROUND(AVG(bmi), 2) AS avg_bmi,

    SUM(
        CASE
            WHEN bmi > 30 THEN 1
            ELSE 0
        END
    ) AS high_bmi_patients,

    ROUND(
        SUM(
            CASE
                WHEN bmi > 30 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS high_bmi_percentage

FROM healthcare_patients

WHERE Region IS NOT NULL
  AND Region != 'UNKNOWN'
  AND PM25 IS NOT NULL
  AND bmi IS NOT NULL

GROUP BY Region, PM25_category

HAVING COUNT(*) >= 30

ORDER BY Region ASC,
         high_bmi_percentage DESC;
         
# State vs Regional Patient Distribution#

SELECT
    s.Region,
    s.patient_state,
    s.state_patients,
    r.region_patients,

    ROUND(
        s.state_patients * 100.0 / r.region_patients,
        2
    ) AS state_percentage

FROM
(
    -- State-wise patient count
    SELECT
        Region,
        patient_state,
        COUNT(*) AS state_patients
    FROM healthcare_patients
    WHERE Region IS NOT NULL
      AND Region != 'UNKNOWN'
      AND patient_state IS NOT NULL
      AND patient_state != 'UNKNOWN'
    GROUP BY Region, patient_state
) AS s

INNER JOIN
(
    -- Region-wise patient count
    SELECT
        Region,
        COUNT(*) AS region_patients
    FROM healthcare_patients
    WHERE Region IS NOT NULL
      AND Region != 'UNKNOWN'
      AND patient_state IS NOT NULL
      AND patient_state != 'UNKNOWN'
    GROUP BY Region
) AS r

ON s.Region = r.Region

ORDER BY
    s.Region ASC,
    s.state_patients DESC;

#Final Healthcare KPI Summary#

SELECT
    COUNT(*) AS total_patients,

    COUNT(DISTINCT
        CASE
            WHEN patient_state != 'UNKNOWN'
            THEN patient_state
        END
    ) AS total_states,

    COUNT(DISTINCT
        CASE
            WHEN Region != 'UNKNOWN'
            THEN Region
        END
    ) AS total_regions,

    COUNT(bmi) AS valid_bmi_records,

    SUM(
        CASE
            WHEN bmi IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_bmi_records,

    ROUND(AVG(bmi), 2) AS avg_bmi,

    SUM(
        CASE
            WHEN bmi > 30 THEN 1
            ELSE 0
        END
    ) AS high_bmi_patients,

    ROUND(
        SUM(
            CASE
                WHEN bmi > 30 THEN 1
                ELSE 0
            END
        ) * 100.0 /
        NULLIF(COUNT(bmi), 0),
        2
    ) AS high_bmi_percentage,

    ROUND(AVG(PM25), 2) AS avg_pm25,

    ROUND(AVG(Ozone), 2) AS avg_ozone,

    ROUND(AVG(N02), 2) AS avg_n02

FROM healthcare_patients;         

#State-wise Healthcare Risk Indicators#

SELECT
    patient_state,

    COUNT(*) AS total_patients,

    ROUND(AVG(bmi), 2) AS avg_bmi,

    ROUND(AVG(PM25), 2) AS avg_pm25,

    ROUND(AVG(Ozone), 2) AS avg_ozone,

    ROUND(AVG(N02), 2) AS avg_n02,

    SUM(
        CASE
            WHEN bmi > 30 THEN 1
            ELSE 0
        END
    ) AS high_bmi_patients,

    ROUND(
        SUM(
            CASE
                WHEN bmi > 30 THEN 1
                ELSE 0
            END
        ) * 100.0 /
        NULLIF(COUNT(bmi), 0),
        2
    ) AS high_bmi_percentage

FROM healthcare_patients

WHERE patient_state IS NOT NULL
  AND patient_state != 'UNKNOWN'

GROUP BY patient_state

HAVING COUNT(*) >= 100

ORDER BY high_bmi_percentage DESC

LIMIT 10;

#Regional BMI Data Availability#

SELECT
    r.Region,
    r.total_patients,

    COALESCE(b.patients_with_bmi, 0)
        AS patients_with_bmi,

    r.total_patients -
    COALESCE(b.patients_with_bmi, 0)
        AS patients_without_bmi,

    ROUND(b.avg_bmi, 2) AS avg_bmi,

    ROUND(
        COALESCE(b.patients_with_bmi, 0)
        * 100.0 / r.total_patients,
        2
    ) AS bmi_availability_percentage

FROM
(
    SELECT
        Region,
        COUNT(*) AS total_patients
    FROM healthcare_patients
    WHERE Region IS NOT NULL
      AND Region != 'UNKNOWN'
    GROUP BY Region
) AS r

LEFT JOIN
(
    SELECT
        Region,
        COUNT(*) AS patients_with_bmi,
        AVG(bmi) AS avg_bmi
    FROM healthcare_patients
    WHERE Region IS NOT NULL
      AND Region != 'UNKNOWN'
      AND bmi IS NOT NULL
    GROUP BY Region
) AS b

ON r.Region = b.Region

ORDER BY bmi_availability_percentage DESC;