-- =================================================================
-- Title: Smart Healthcare Management Database Schema
-- Description: PostgreSQL schema for a multi-user healthcare system.
-- =================================================================

-- Drop existing tables to ensure a clean slate
DROP TABLE IF EXISTS
    patient_allergy, user_phone, payment, bill, patient_insurance, insurance_provider,
    lab_result, lab_test, prescription_item, medication, prescription, diagnosis,
    medical_record, appointment, doctor_specialty, specialty, admin, doctor,
    patient, department, hospital, app_user
CASCADE;

-- Required for exclusion constraints using GiST with scalar equality
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- -------------------------------------------------
-- Hospitals and Departments
-- -------------------------------------------------

CREATE TABLE hospital (
    hospital_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE department (
    department_id SERIAL PRIMARY KEY,
    hospital_id INT NOT NULL REFERENCES hospital(hospital_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    UNIQUE(hospital_id, name)
);

-- -------------------------------------------------
-- User Management (Supertype-Subtype Structure)
-- -------------------------------------------------

CREATE TABLE app_user (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    date_of_birth DATE NOT NULL,
    -- Composite attribute for address
    street VARCHAR(100),
    district VARCHAR(100),
    city VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE patient (
    patient_id INT PRIMARY KEY REFERENCES app_user(user_id) ON DELETE CASCADE,
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20)
);

CREATE TABLE doctor (
    doctor_id INT PRIMARY KEY REFERENCES app_user(user_id) ON DELETE CASCADE,
    license_number VARCHAR(50) NOT NULL UNIQUE,
    department_id INT REFERENCES department(department_id) ON DELETE SET NULL
);

CREATE TABLE admin (
    admin_id INT PRIMARY KEY REFERENCES app_user(user_id) ON DELETE CASCADE,
    permissions TEXT -- e.g., 'user_management,billing_access'
);

-- -------------------------------------------------
-- Multivalued and N:M Relationship Tables
-- -------------------------------------------------

-- Multivalued attribute for user phone numbers
CREATE TABLE user_phone (
    user_id INT NOT NULL REFERENCES app_user(user_id) ON DELETE CASCADE,
    phone_number VARCHAR(20) NOT NULL,
    PRIMARY KEY (user_id, phone_number)
);

-- Multivalued attribute for patient allergies
CREATE TABLE patient_allergy (
    patient_id INT NOT NULL REFERENCES patient(patient_id) ON DELETE CASCADE,
    allergy_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (patient_id, allergy_name)
);

CREATE TABLE specialty (
    specialty_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- N:M relationship between doctors and specialties
CREATE TABLE doctor_specialty (
    doctor_id INT NOT NULL REFERENCES doctor(doctor_id) ON DELETE CASCADE,
    specialty_id INT NOT NULL REFERENCES specialty(specialty_id) ON DELETE CASCADE,
    PRIMARY KEY (doctor_id, specialty_id)
);

-- -------------------------------------------------
-- Core Healthcare Entities
-- -------------------------------------------------

CREATE TABLE appointment (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL REFERENCES patient(patient_id) ON DELETE CASCADE,
    doctor_id INT NOT NULL REFERENCES doctor(doctor_id) ON DELETE CASCADE,
    appointment_datetime TIMESTAMP NOT NULL,
    duration_minutes INT NOT NULL DEFAULT 30 CHECK (duration_minutes > 0),
    status VARCHAR(20) NOT NULL CHECK (status IN ('scheduled', 'completed', 'cancelled', 'no-show')),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (appointment_id, patient_id)
);

-- Prevent a doctor from having overlapping scheduled/completed appointments.
-- Note: This is stricter than enforcing uniqueness only at the exact start time,
-- and it aligns with status logic by applying only to scheduled/completed rows.
ALTER TABLE appointment
ADD CONSTRAINT no_doctor_overlap
EXCLUDE USING gist (
    doctor_id WITH =,
    tsrange(
        appointment_datetime,
        appointment_datetime + duration_minutes * INTERVAL '1 minute'
    ) WITH &&
)
WHERE (status IN ('scheduled', 'completed'));

-- Prevent a patient from having overlapping scheduled/completed appointments.
ALTER TABLE appointment
ADD CONSTRAINT no_patient_overlap
EXCLUDE USING gist (
    patient_id WITH =,
    tsrange(
        appointment_datetime,
        appointment_datetime + duration_minutes * INTERVAL '1 minute'
    ) WITH &&
)
WHERE (status IN ('scheduled', 'completed'));

CREATE TABLE medical_record (
    record_id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL REFERENCES patient(patient_id) ON DELETE CASCADE,
    doctor_id INT NOT NULL REFERENCES doctor(doctor_id) ON DELETE RESTRICT,
    appointment_id INT REFERENCES appointment(appointment_id) ON DELETE SET NULL,
    record_date DATE NOT NULL DEFAULT CURRENT_DATE,
    summary TEXT,
    UNIQUE (record_id, patient_id)
);

CREATE TABLE diagnosis (
    diagnosis_id SERIAL PRIMARY KEY,
    record_id INT NOT NULL REFERENCES medical_record(record_id) ON DELETE CASCADE,
    icd10_code VARCHAR(10),
    description TEXT NOT NULL,
    is_chronic BOOLEAN DEFAULT FALSE
);

CREATE TABLE medication (
    medication_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE prescription (
    prescription_id SERIAL PRIMARY KEY,
    record_id INT NOT NULL REFERENCES medical_record(record_id) ON DELETE CASCADE,
    prescription_date DATE NOT NULL DEFAULT CURRENT_DATE
);

-- Weak entity: prescription_item depends on prescription
CREATE TABLE prescription_item (
    prescription_id INT NOT NULL REFERENCES prescription(prescription_id) ON DELETE CASCADE,
    item_number INT NOT NULL, -- Partial key
    medication_id INT NOT NULL REFERENCES medication(medication_id) ON DELETE RESTRICT,
    dosage VARCHAR(50) NOT NULL,
    frequency VARCHAR(50) NOT NULL,
    duration_days INT,
    PRIMARY KEY (prescription_id, item_number)
);

CREATE TABLE lab_test (
    test_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE lab_result (
    result_id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL REFERENCES patient(patient_id) ON DELETE CASCADE,
    test_id INT NOT NULL REFERENCES lab_test(test_id) ON DELETE RESTRICT,
    record_id INT REFERENCES medical_record(record_id) ON DELETE SET NULL,
    result_date DATE NOT NULL,
    result_value VARCHAR(100) NOT NULL,
    status VARCHAR(20) CHECK (status IN ('normal', 'abnormal', 'pending')),
    FOREIGN KEY (record_id, patient_id) REFERENCES medical_record(record_id, patient_id)
);

-- -------------------------------------------------
-- Billing and Insurance
-- -------------------------------------------------

CREATE TABLE insurance_provider (
    provider_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- N:M relationship between patients and insurance providers
CREATE TABLE patient_insurance (
    patient_id INT NOT NULL REFERENCES patient(patient_id) ON DELETE CASCADE,
    provider_id INT NOT NULL REFERENCES insurance_provider(provider_id) ON DELETE CASCADE,
    policy_number VARCHAR(50) NOT NULL,
    PRIMARY KEY (patient_id, provider_id)
);

CREATE TABLE bill (
    bill_id SERIAL PRIMARY KEY,
    patient_id INT NOT NULL REFERENCES patient(patient_id) ON DELETE CASCADE,
    appointment_id INT UNIQUE REFERENCES appointment(appointment_id) ON DELETE SET NULL,
    amount NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
    issue_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('unpaid', 'paid', 'partially_paid', 'overdue')),
    FOREIGN KEY (appointment_id, patient_id) REFERENCES appointment(appointment_id, patient_id)
);

CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    bill_id INT NOT NULL REFERENCES bill(bill_id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    payment_method VARCHAR(50) CHECK (payment_method IN ('credit_card', 'bank_transfer', 'cash', 'insurance'))
);
