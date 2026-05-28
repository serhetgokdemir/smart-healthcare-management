-- =================================================================
-- Title: Sample Data for Smart Healthcare Management Database
-- Description: Inserts realistic sample data into the tables.
-- =================================================================

-- Clear existing data
TRUNCATE
    patient_allergy, user_phone, payment, bill, patient_insurance, insurance_provider,
    lab_result, lab_test, prescription_item, medication, prescription, diagnosis,
    medical_record, appointment, doctor_specialty, specialty, admin, doctor,
    patient, department, hospital, app_user
RESTART IDENTITY CASCADE;

-- -------------------------------------------------
-- Hospitals and Departments
-- -------------------------------------------------
INSERT INTO hospital (name, address) VALUES
('City General Hospital', '123 Health St, Metroville, 10001'),
('Suburb Community Clinic', '456 Wellness Ave, Suburbia, 20002'),
('Mountain View Medical Center', '789 Peak Rd, Highlands, 30003');

INSERT INTO department (hospital_id, name) VALUES
(1, 'Cardiology'), (1, 'Neurology'), (1, 'Pediatrics'),
(2, 'General Medicine'), (2, 'Dermatology'),
(3, 'Orthopedics');

-- -------------------------------------------------
-- Users (Patients, Doctors, Admin)
-- -------------------------------------------------
-- Password hashes are demo placeholders (not real hashes, not for production)

INSERT INTO app_user (first_name, last_name, email, password_hash, date_of_birth, street, district, city, postal_code, country) VALUES
('John', 'Smith', 'john.smith@example.com', 'DEMO_HASH_password123_john', '1985-02-10', '10 Maple Dr', 'Central', 'Metroville', '10001', 'USA'),
('Jane', 'Doe', 'jane.doe@example.com', 'DEMO_HASH_password123_jane', '1990-07-22', '20 Oak Ln', 'North', 'Metroville', '10002', 'USA'),
('Peter', 'Jones', 'peter.jones@example.com', 'DEMO_HASH_password123_peter', '1978-11-30', '30 Pine St', 'West', 'Suburbia', '20002', 'USA'),
('Mary', 'Williams', 'mary.williams@example.com', 'DEMO_HASH_password123_mary', '2018-05-15', '40 Birch Rd', 'East', 'Suburbia', '20003', 'USA'),
('David', 'Brown', 'david.brown@example.com', 'DEMO_HASH_password123_david', '1995-01-01', '50 Elm Ct', 'South', 'Highlands', '30003', 'USA'),
('Emily', 'Davis', 'emily.davis@example.com', 'DEMO_HASH_password123_emily', '1982-03-14', '101 Heartbeat Blvd', 'Medical District', 'Metroville', '10004', 'USA'),
('Michael', 'Miller', 'michael.miller@example.com', 'DEMO_HASH_password123_michael', '1975-09-20', '202 Brainwave Rd', 'Medical District', 'Metroville', '10004', 'USA'),
('Sarah', 'Wilson', 'sarah.wilson@example.com', 'DEMO_HASH_password123_sarah', '1988-12-01', '303 Skincare Ave', 'Downtown', 'Suburbia', '20002', 'USA'),
('Chris', 'Taylor', 'chris.taylor@example.com', 'DEMO_HASH_password123_chris', '1991-06-25', '404 Bonebreak Hill', 'Uptown', 'Highlands', '30004', 'USA'),
('Admin', 'User', 'admin@healthcare.system', 'DEMO_HASH_password123_admin', '1980-01-01', '1 Admin Way', 'System', 'Server City', '99999', 'USA');

-- Patients (IDs 1-5)
INSERT INTO patient (patient_id, emergency_contact_name, emergency_contact_phone) VALUES
(1, 'Alice Smith', '555-0101'),
(2, 'Bob Doe', '555-0102'),
(3, 'Charlie Jones', '555-0103'),
(4, 'Grace Williams', '555-0104'),
(5, 'Frank Brown', '555-0105');

-- Doctors (IDs 6-9)
INSERT INTO doctor (doctor_id, license_number, department_id) VALUES
(6, 'LIC-CARD-1122', 1), -- Dr. Davis, Cardiology
(7, 'LIC-NEUR-3344', 2), -- Dr. Miller, Neurology
(8, 'LIC-DERM-5566', 5), -- Dr. Wilson, Dermatology
(9, 'LIC-ORTH-7788', 6); -- Dr. Taylor, Orthopedics

-- Admin (ID 10)
INSERT INTO admin (admin_id, permissions) VALUES
(10, 'full_access');

-- -------------------------------------------------
-- User Details
-- -------------------------------------------------
INSERT INTO user_phone (user_id, phone_number) VALUES
(1, '555-1111'), (1, '555-1112'),
(2, '555-2222'),
(6, '555-6666'), (7, '555-7777');

INSERT INTO patient_allergy (patient_id, allergy_name) VALUES
(1, 'Pollen'), (1, 'Peanuts'),
(3, 'Aspirin');

-- -------------------------------------------------
-- Specialties and Doctor Specialties
-- -------------------------------------------------
INSERT INTO specialty (name) VALUES
('Invasive Cardiology'), ('Electrophysiology'), ('Neuro-oncology'),
('Epilepsy'), ('Cosmetic Dermatology'), ('Pediatric Orthopedics');

INSERT INTO doctor_specialty (doctor_id, specialty_id) VALUES
(6, 1), (6, 2), -- Dr. Davis has two cardiology specialties
(7, 3), (7, 4), -- Dr. Miller has two neurology specialties
(8, 5),
(9, 6);

-- -------------------------------------------------
-- Appointments
-- -------------------------------------------------
INSERT INTO appointment (patient_id, doctor_id, appointment_datetime, status) VALUES
(1, 6, '2026-06-10 10:00:00', 'completed'),
(2, 7, '2026-06-10 11:00:00', 'completed'),
(3, 8, '2026-06-11 09:30:00', 'completed'),
(1, 6, '2026-06-12 10:00:00', 'scheduled'),
(4, 9, '2026-06-12 14:00:00', 'completed'),
(5, 6, '2026-06-15 11:30:00', 'scheduled'),
(2, 7, '2026-06-18 11:00:00', 'cancelled'),
(3, 6, '2026-06-20 09:00:00', 'scheduled'),
(1, 8, '2026-06-22 15:00:00', 'scheduled'),
(5, 9, '2026-06-25 16:00:00', 'scheduled');

-- -------------------------------------------------
-- Medical Records, Diagnoses, Prescriptions
-- -------------------------------------------------
-- For appointment 1
INSERT INTO medical_record (patient_id, doctor_id, appointment_id, summary) VALUES (1, 6, 1, 'Patient reports chest pain. EKG performed.');
INSERT INTO diagnosis (record_id, icd10_code, description) VALUES (1, 'I25.10', 'Atherosclerotic heart disease');
INSERT INTO prescription (record_id) VALUES (1);
-- For appointment 2
INSERT INTO medical_record (patient_id, doctor_id, appointment_id, summary) VALUES (2, 7, 2, 'Follow-up for recurring headaches. MRI reviewed.');
INSERT INTO diagnosis (record_id, icd10_code, description) VALUES (2, 'G43.909', 'Migraine, unspecified');
INSERT INTO prescription (record_id) VALUES (2);
-- For appointment 3
INSERT INTO medical_record (patient_id, doctor_id, appointment_id, summary) VALUES (3, 8, 3, 'Patient has a skin rash on arm.');
INSERT INTO diagnosis (record_id, icd10_code, description) VALUES (3, 'L23.9', 'Allergic contact dermatitis');
INSERT INTO prescription (record_id) VALUES (3);
-- For appointment 5
INSERT INTO medical_record (patient_id, doctor_id, appointment_id, summary) VALUES (4, 9, 5, 'Child fell, pain in wrist. X-ray taken.');
INSERT INTO diagnosis (record_id, icd10_code, description) VALUES (4, 'S62.60', 'Fracture of wrist');
INSERT INTO prescription (record_id) VALUES (4);

-- Some records not tied to an appointment
INSERT INTO medical_record (patient_id, doctor_id, summary) VALUES (1, 6, 'Routine check-up.');
INSERT INTO diagnosis (record_id, icd10_code, description) VALUES (5, 'Z00.00', 'Encounter for general adult medical examination');
INSERT INTO medical_record (patient_id, doctor_id, summary) VALUES (3, 6, 'Discussed Aspirin allergy implications.');
INSERT INTO medical_record (patient_id, doctor_id, summary) VALUES (5, 6, 'Initial consultation for hypertension.');
INSERT INTO diagnosis (record_id, icd10_code, description) VALUES (7, 'I10', 'Essential (primary) hypertension');
INSERT INTO prescription (record_id) VALUES (7);
INSERT INTO medical_record (patient_id, doctor_id, summary) VALUES (2, 7, 'Review of medication effectiveness.');
INSERT INTO diagnosis (record_id, icd10_code, description) VALUES (8, 'G43.909', 'Migraine, unspecified');
INSERT INTO prescription (record_id) VALUES (8);


-- -------------------------------------------------
-- Medications and Prescription Items
-- -------------------------------------------------
INSERT INTO medication (name, description) VALUES
('Atorvastatin', 'Lowers cholesterol'),
('Lisinopril', 'Treats high blood pressure'),
('Sumatriptan', 'Treats migraines'),
('Hydrocortisone Cream', 'Reduces skin inflammation'),
('Ibuprofen', 'Pain reliever'),
('Amoxicillin', 'Antibiotic'),
('Metformin', 'Treats type 2 diabetes'),
('Albuterol', 'Asthma inhaler'),
('Omeprazole', 'Reduces stomach acid'),
('Losartan', 'Treats high blood pressure');

-- Items for prescriptions
INSERT INTO prescription_item (prescription_id, item_number, medication_id, dosage, frequency, duration_days) VALUES
(1, 1, 1, '20mg', 'Once daily', 90), -- Atorvastatin for heart disease
(1, 2, 2, '10mg', 'Once daily', 90), -- Lisinopril for heart disease
(2, 1, 3, '50mg', 'As needed for headache', 30), -- Sumatriptan for migraine
(3, 1, 4, '1% topical', 'Twice daily', 14), -- Hydrocortisone for dermatitis
(4, 1, 5, '400mg', 'Every 6 hours as needed for pain', 7), -- Ibuprofen for fracture pain
(5, 1, 2, '5mg', 'Once daily', 30), -- Lisinopril for hypertension
(6, 1, 3, '100mg', 'As needed, max 2 per day', 30), -- Stronger Sumatriptan
(5, 2, 10, '50mg', 'Once daily', 30), -- Losartan for hypertension
(2, 2, 5, '200mg', 'With migraine onset', 30),
(1, 3, 5, '200mg', 'For minor pains', 30),
(3, 2, 9, '20mg', 'Once daily', 28),
(6, 2, 7, '500mg', 'Twice daily', 90);


-- -------------------------------------------------
-- Lab Tests and Results
-- -------------------------------------------------
INSERT INTO lab_test (name, description) VALUES
('Complete Blood Count (CBC)', 'Measures different components of blood'),
('Lipid Panel', 'Measures cholesterol and triglycerides'),
('Basic Metabolic Panel (BMP)', 'Measures glucose, calcium, and electrolytes'),
('Thyroid Stimulating Hormone (TSH)', 'Checks thyroid function'),
('Hemoglobin A1c', 'Monitors long-term glucose control'),
('Urinalysis', 'General screen of urine');

INSERT INTO lab_result (patient_id, test_id, record_id, result_date, result_value, status) VALUES
(1, 2, 1, '2026-06-10', 'Total Cholesterol: 240 mg/dL', 'abnormal'),
(1, 1, 1, '2026-06-10', 'WBC: 5.5 x10^9/L', 'normal'),
(2, 3, 2, '2026-06-10', 'Glucose: 90 mg/dL', 'normal'),
(3, 1, 3, '2026-06-11', 'Eosinophils: 8%', 'abnormal'),
(4, 1, 4, '2026-06-12', 'Platelets: 300 x10^9/L', 'normal'),
(5, 2, 7, '2026-05-20', 'Triglycerides: 180 mg/dL', 'abnormal'),
(1, 5, 5, '2026-05-15', 'A1c: 5.2%', 'normal'),
(2, 4, 8, '2026-05-18', 'TSH: 2.1 mIU/L', 'normal');

-- -------------------------------------------------
-- Insurance and Billing
-- -------------------------------------------------
INSERT INTO insurance_provider (name) VALUES
('Blue Cross Blue Shield'),
('Aetna'),
('Cigna');

INSERT INTO patient_insurance (patient_id, provider_id, policy_number) VALUES
(1, 1, 'BCBS-11111'),
(2, 2, 'AETNA-22222'),
(3, 1, 'BCBS-33333'),
(4, 3, 'CIGNA-44444'),
(5, 2, 'AETNA-55555');

INSERT INTO bill (patient_id, appointment_id, amount, issue_date, due_date, status) VALUES
(1, 1, 250.00, '2026-06-10', '2026-07-10', 'paid'),
(2, 2, 350.00, '2026-06-10', '2026-07-10', 'unpaid'),
(3, 3, 150.00, '2026-06-11', '2026-07-11', 'partially_paid'),
(4, 5, 450.00, '2026-06-12', '2026-07-12', 'unpaid'),
-- Bill for appointment 4 (future) not generated yet
-- Bill for appointment 7 (cancelled) not generated
-- Some bills not tied to an appointment (e.g., for lab work)
(1, NULL, 75.00, '2026-06-10', '2026-07-10', 'paid'),
(3, NULL, 50.00, '2026-06-11', '2026-07-11', 'unpaid'),
(5, NULL, 120.00, '2026-05-21', '2026-06-21', 'overdue'),
(2, NULL, 90.00, '2026-05-19', '2026-06-19', 'paid');

INSERT INTO payment (bill_id, amount, payment_date, payment_method) VALUES
(1, 250.00, '2026-06-15', 'credit_card'),
(3, 50.00, '2026-06-20', 'insurance'),
(5, 75.00, '2026-06-12', 'credit_card'),
(8, 90.00, '2026-05-25', 'bank_transfer');