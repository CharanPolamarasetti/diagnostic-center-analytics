-- =====================================================================
-- Provide the owner with insights on patient behavior, loyalty, and 
-- demographics to to improve retention and run targeted marketing.
-- =====================================================================

-- ==================================================================================
-- New vs Returning Patients
-- Identifies patient loyalty by counting patients with single vs multiple visits
-- ==================================================================================
WITH PatientVisitCount AS (
    SELECT
        patient_id,
        COUNT(visit_id) AS visit_count
    FROM visits
    GROUP BY patient_id
)
SELECT
    CASE
        WHEN pvc.visit_count = 1 THEN 'New Patient (Single Visit)'
        ELSE 'Returning Patient (Multiple Visits)'
    END AS patient_type,
    COUNT(pvc.patient_id) AS total_patients
FROM PatientVisitCount AS pvc
GROUP BY 1
ORDER BY 2 DESC;

-- ====================================================
-- Dominant Patient Demographics (Age, Gender, City)
-- ====================================================

-- Divide patients into common age groups to find out which age group is the main one
SELECT
    CASE
        WHEN p.age < 18 THEN '0-17 (Child/Teen)'
        WHEN p.age BETWEEN 18 AND 35 THEN '18-35 (Young Adult)'
        WHEN p.age BETWEEN 36 AND 55 THEN '36-55 (Middle Age)'
        ELSE '56+ (Senior)'
    END AS age_group,
    COUNT(p.patient_id) AS patient_count
FROM patients p
GROUP BY 1
ORDER BY MIN(p.age);

-- A simple count to understand the gender distribution of the patient base
SELECT
    p.gender,
    COUNT(p.patient_id) AS patient_count
FROM patients p
GROUP BY 1
ORDER BY 2 DESC;

-- Identifies the primary geographical areas served by the diagnostic center
SELECT
    SPLIT_PART(p.address, ',', 2) AS city,
    SPLIT_PART(SPLIT_PART(p.address, ',', 3), ' ', 2) AS state,
    COUNT(p.patient_id) AS patient_count
FROM patients p
GROUP BY city, state
ORDER BY patient_count DESC;

-- ==================================================================================
-- Peak visit day of the week
-- Identifies the busiest days for patient visits to optimize staffing and services
-- ==================================================================================
SELECT
    TO_CHAR(visit_date, 'Day') AS day_of_week,
    EXTRACT(DOW FROM visit_date) AS day_of_week_num, -- Mostly numbering is given insted of actual day name
    COUNT(visit_id) AS total_visits
FROM visits
GROUP BY 1, 2
ORDER BY 2;
