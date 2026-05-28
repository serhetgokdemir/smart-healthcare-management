-- =================================================================
-- Title: Indexing and Performance Analysis
-- Description: Demonstrates index creation and performance comparison.
-- =================================================================

-- Clean up any existing indexes to ensure a clean run
DROP INDEX IF EXISTS idx_appointment_patient_id;
DROP INDEX IF EXISTS idx_appointment_doctor_datetime;
DROP INDEX IF EXISTS idx_user_email_hash;
DROP INDEX IF EXISTS idx_bill_patient_status;
DROP INDEX IF EXISTS idx_lab_result_patient_date;

-- -------------------------------------------------
-- Example 1: B+ Tree Index on a Foreign Key
-- -------------------------------------------------
-- Query: Find all appointments for a specific patient.
-- This is a very common operation in a healthcare system.

-- Before index:
EXPLAIN ANALYZE
SELECT * FROM appointment WHERE patient_id = 1;

-- Result (example): Seq Scan on appointment (cost=0.00..45.50 rows=5 width=33) (actual time=...)
-- The database has to scan the entire 'appointment' table.

-- Create a B+ Tree index (the default type in PostgreSQL)
CREATE INDEX idx_appointment_patient_id ON appointment(patient_id);

-- After index:
EXPLAIN ANALYZE
SELECT * FROM appointment WHERE patient_id = 1;

-- Result (example): Index Scan using idx_appointment_patient_id on appointment (cost=0.28..8.29 rows=5 width=33) (actual time=...)
-- The database now uses the index for a much faster lookup.

-- -------------------------------------------------
-- Example 2: Composite B+ Tree Index
-- -------------------------------------------------
-- Query: Find all appointments for a doctor within a specific date range.
-- This is useful for a doctor's calendar view.

-- Before index:
EXPLAIN ANALYZE
SELECT appointment_id, appointment_datetime, status
FROM appointment
WHERE doctor_id = 6 AND appointment_datetime >= '2026-06-01' AND appointment_datetime < '2026-07-01';

-- Result (example): Seq Scan on appointment... (filters on both doctor_id and datetime)

-- Create a composite index on doctor_id and appointment_datetime
CREATE INDEX idx_appointment_doctor_datetime ON appointment(doctor_id, appointment_datetime);

-- After index:
EXPLAIN ANALYZE
SELECT appointment_id, appointment_datetime, status
FROM appointment
WHERE doctor_id = 6 AND appointment_datetime >= '2026-06-01' AND appointment_datetime < '2026-07-01';

-- Result (example): Index Scan using idx_appointment_doctor_datetime...
-- The index allows efficient lookup of the doctor and then scanning the relevant date range within that doctor's appointments.

-- -------------------------------------------------
-- Example 3: Hash Index for Exact Lookups
-- -------------------------------------------------
-- Query: Find a user by their exact email address.
-- This is common during login or user registration checks. Hash indexes are optimized for equality checks.

-- Before index (assuming only the UNIQUE constraint's B-Tree index exists):
EXPLAIN ANALYZE
SELECT user_id, first_name, email FROM app_user WHERE email = 'jane.doe@example.com';

-- Result (example): Index Scan using app_user_email_key... (B-Tree)

-- Create a HASH index. Note: B-Tree is often good enough, but this demonstrates the syntax.
CREATE INDEX idx_user_email_hash ON app_user USING HASH (email);

-- After index:
EXPLAIN ANALYZE
SELECT user_id, first_name, email FROM app_user WHERE email = 'jane.doe@example.com';

-- Result (example): Bitmap Heap Scan on app_user... -> Bitmap Index Scan on idx_user_email_hash...
-- The planner might choose the hash index for this equality-only query, which can be more memory-efficient and faster for very large tables.

-- -------------------------------------------------
-- Example 4: Composite Index for Filtering and Sorting
-- -------------------------------------------------
-- Query: Find unpaid bills for a patient, ordered by due date.
-- This helps in displaying a patient's outstanding bills in a logical order.

-- Before index:
EXPLAIN ANALYZE
SELECT bill_id, amount, due_date
FROM bill
WHERE patient_id = 3 AND status = 'partially_paid'
ORDER BY due_date;

-- Result (example): Seq Scan on bill... followed by a Sort operation. Sorting can be expensive.

-- Create a composite index to cover filtering and ordering
CREATE INDEX idx_bill_patient_status ON bill(patient_id, status, due_date);

-- After index:
EXPLAIN ANALYZE
SELECT bill_id, amount, due_date
FROM bill
WHERE patient_id = 3 AND status = 'partially_paid'
ORDER BY due_date;

-- Result (example): Index Scan using idx_bill_patient_status...
-- The database can use the index to find the matching rows and retrieve them in the pre-sorted order of 'due_date', avoiding a separate Sort step.

-- -------------------------------------------------
-- Example 5: Index on Lab Results
-- -------------------------------------------------
-- Query: Retrieve a patient's lab history, sorted by date.
-- A common query for reviewing a patient's medical history.

-- Before index:
EXPLAIN ANALYZE
SELECT result_id, test_id, result_date, result_value
FROM lab_result
WHERE patient_id = 1
ORDER BY result_date DESC;

-- Result (example): Seq Scan on lab_result... followed by a Sort.

-- Create a composite index
CREATE INDEX idx_lab_result_patient_date ON lab_result(patient_id, result_date DESC);

-- After index:
EXPLAIN ANALYZE
SELECT result_id, test_id, result_date, result_value
FROM lab_result
WHERE patient_id = 1
ORDER BY result_date DESC;

-- Result (example): Index Scan using idx_lab_result_patient_date...
-- The index provides fast access to the patient's results and delivers them in the correct descending order by date.
