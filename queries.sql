-- =================================================================
-- Title: Advanced SQL Queries for Smart Healthcare Management
-- Description: A collection of queries demonstrating various SQL features.
-- =================================================================

-- Query 1: List all scheduled appointments with patient, doctor, hospital, and department names.
-- Demonstrates: INNER JOIN on multiple tables.
SELECT
    a.appointment_datetime,
    p_user.first_name AS patient_first_name,
    p_user.last_name AS patient_last_name,
    d_user.first_name AS doctor_first_name,
    d_user.last_name AS doctor_last_name,
    h.name AS hospital_name,
    dpt.name AS department_name
FROM appointment a
JOIN patient p ON a.patient_id = p.patient_id
JOIN app_user p_user ON p.patient_id = p_user.user_id
JOIN doctor doc ON a.doctor_id = doc.doctor_id
JOIN app_user d_user ON doc.doctor_id = d_user.user_id
JOIN department dpt ON doc.department_id = dpt.department_id
JOIN hospital h ON dpt.hospital_id = h.hospital_id
WHERE a.status = 'scheduled'
ORDER BY a.appointment_datetime;


-- Query 2: Find doctors who have more than 2 appointments (scheduled or completed).
-- Demonstrates: GROUP BY, HAVING, COUNT, and subquery in WHERE IN.
SELECT
    d_user.first_name,
    d_user.last_name,
    COUNT(a.appointment_id) AS appointment_count
FROM doctor doc
JOIN app_user d_user ON doc.doctor_id = d_user.user_id
JOIN appointment a ON doc.doctor_id = a.doctor_id
WHERE a.status IN ('scheduled', 'completed')
GROUP BY doc.doctor_id, d_user.first_name, d_user.last_name
HAVING COUNT(a.appointment_id) > 1
ORDER BY appointment_count DESC;


-- Query 3: List patients who have no appointments at all.
-- Demonstrates: LEFT JOIN and IS NULL to find non-matching records.
SELECT
    p_user.user_id,
    p_user.first_name,
    p_user.last_name
FROM patient p
JOIN app_user p_user ON p.patient_id = p_user.user_id
LEFT JOIN appointment a ON p.patient_id = a.patient_id
WHERE a.appointment_id IS NULL;


-- Query 4: Find the most common diagnosis based on ICD-10 code.
-- Demonstrates: GROUP BY, COUNT, ORDER BY, LIMIT.
SELECT
    icd10_code,
    description,
    COUNT(*) AS diagnosis_count
FROM diagnosis
WHERE icd10_code IS NOT NULL
GROUP BY icd10_code, description
ORDER BY diagnosis_count DESC
LIMIT 5;


-- Query 5: Calculate the total bill amount and total amount paid per patient.
-- Demonstrates: Subqueries in SELECT, LEFT JOIN, COALESCE, SUM, GROUP BY.
SELECT
    p_user.first_name,
    p_user.last_name,
    COALESCE(SUM(b.amount), 0) AS total_billed,
    (SELECT COALESCE(SUM(p.amount), 0)
     FROM payment p
     JOIN bill b2 ON p.bill_id = b2.bill_id
     WHERE b2.patient_id = p_user.user_id) AS total_paid
FROM patient pat
JOIN app_user p_user ON pat.patient_id = p_user.user_id
LEFT JOIN bill b ON pat.patient_id = b.patient_id
GROUP BY p_user.user_id, p_user.first_name, p_user.last_name
ORDER BY total_billed DESC;


-- Query 6: List all unpaid or partially paid bills that are past their due date (overdue).
-- Demonstrates: Filtering by date, multiple conditions in WHERE.
SELECT
    b.bill_id,
    p_user.first_name,
    p_user.last_name,
    b.amount,
    b.due_date,
    b.status
FROM bill b
JOIN app_user p_user ON b.patient_id = p_user.user_id
WHERE b.status IN ('unpaid', 'partially_paid')
  AND b.due_date < CURRENT_DATE
ORDER BY b.due_date;


-- Query 7: Find medications that have been prescribed more than 3 times.
-- Demonstrates: Nested query, GROUP BY, HAVING.
SELECT
    m.name,
    m.description,
    pi_counts.prescription_count
FROM medication m
JOIN (
    SELECT
        medication_id,
        COUNT(*) AS prescription_count
    FROM prescription_item
    GROUP BY medication_id
    HAVING COUNT(*) >= 3
) AS pi_counts ON m.medication_id = pi_counts.medication_id
ORDER BY pi_counts.prescription_count DESC;


-- Query 8: Show all lab results for a specific patient (John Smith, user_id=1).
-- Demonstrates: JOIN, filtering by a specific ID.
SELECT
    lr.result_date,
    lt.name AS test_name,
    lr.result_value,
    lr.status
FROM lab_result lr
JOIN lab_test lt ON lr.test_id = lt.test_id
WHERE lr.patient_id = 1
ORDER BY lr.result_date DESC;


-- Query 9: Find doctors specialized in 'Cardiology' working at 'City General Hospital'.
-- Demonstrates: Multiple JOINs, filtering by text fields.
SELECT
    d_user.first_name,
    d_user.last_name,
    s.name AS specialty_name
FROM doctor doc
JOIN app_user d_user ON doc.doctor_id = d_user.user_id
JOIN department dpt ON doc.department_id = dpt.department_id
JOIN hospital h ON dpt.hospital_id = h.hospital_id
JOIN doctor_specialty ds ON doc.doctor_id = ds.doctor_id
JOIN specialty s ON ds.specialty_id = s.specialty_id
WHERE h.name = 'City General Hospital'
  AND dpt.name = 'Cardiology';


-- Query 10: Find patients who have appointments but have no lab results.
-- Demonstrates: NOT EXISTS, correlated subquery.
SELECT DISTINCT
    p_user.first_name,
    p_user.last_name
FROM patient pat
JOIN app_user p_user ON pat.patient_id = p_user.user_id
JOIN appointment a ON pat.patient_id = a.patient_id
WHERE NOT EXISTS (
    SELECT 1
    FROM lab_result lr
    WHERE lr.patient_id = pat.patient_id
);

-- Query 11: Find the doctor with the highest number of distinct patients.
-- Demonstrates: COUNT(DISTINCT), GROUP BY, ORDER BY, LIMIT.
SELECT
    d_user.first_name,
    d_user.last_name,
    COUNT(DISTINCT a.patient_id) AS distinct_patient_count
FROM appointment a
JOIN doctor doc ON a.doctor_id = doc.doctor_id
JOIN app_user d_user ON doc.doctor_id = d_user.user_id
GROUP BY doc.doctor_id, d_user.first_name, d_user.last_name
ORDER BY distinct_patient_count DESC
LIMIT 1;


-- Query 12: Find the average bill amount by department for completed appointments.
-- Demonstrates: AVG, GROUP BY, JOIN across multiple tables.
SELECT
    dpt.name AS department_name,
    h.name AS hospital_name,
    AVG(b.amount) AS average_bill_amount
FROM bill b
JOIN appointment a ON b.appointment_id = a.appointment_id
JOIN doctor doc ON a.doctor_id = doc.doctor_id
JOIN department dpt ON doc.department_id = dpt.department_id
JOIN hospital h ON dpt.hospital_id = h.hospital_id
WHERE a.status = 'completed'
GROUP BY dpt.name, h.name
ORDER BY average_bill_amount DESC;
