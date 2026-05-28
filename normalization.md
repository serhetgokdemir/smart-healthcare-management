# Normalization of Healthcare Data

This document explains the process of normalizing a complex, unnormalized table into a set of tables in Boyce-Codd Normal Form (BCNF).

## Unnormalized Form (UNF)

Let's start with an intentionally unnormalized table, `appointment_full_info`. This single table contains repeating groups and transitive dependencies, making it inefficient and prone to anomalies.

**`appointment_full_info`**

| appointment_id | appointment_datetime | patient_id | patient_first_name | patient_last_name | patient_dob | doctor_id | doctor_first_name | doctor_last_name | doctor_license | department_id | department_name | hospital_id | hospital_name | diagnosis_codes | prescription_meds |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 101 | 2026-06-10 10:00 | 1 | John | Smith | 1985-02-10 | 6 | Emily | Davis | LIC-CARD-1122 | 1 | Cardiology | 1 | City General | "I25.10, Z00.00" | "Atorvastatin 20mg, Lisinopril 10mg" |
| 102 | 2026-06-10 11:00 | 2 | Jane | Doe | 1990-07-22 | 7 | Michael | Miller | LIC-NEUR-3344 | 2 | Neurology | 1 | City General | "G43.909" | "Sumatriptan 50mg" |

**Problems with UNF:**
- **Repeating Groups:** `diagnosis_codes` and `prescription_meds` contain multiple values in a single string. This violates 1NF.
- **Redundancy:** Patient details (name, DOB), doctor details, and department/hospital info are repeated for every appointment.
- **Anomalies:**
    - **Update Anomaly:** If Dr. Davis changes departments, we must update every record for her.
    - **Insertion Anomaly:** We can't add a new doctor until they have an appointment. We can't add a new hospital unless it has a department with a doctor who has an appointment.
    - **Deletion Anomaly:** If we delete John Smith's only appointment, we lose all information about him.

---

## First Normal Form (1NF)

**Rule:** Ensure all attributes are atomic and there are no repeating groups. Each cell should hold a single value.

We eliminate the repeating groups by creating separate tables for diagnoses and prescriptions related to a visit. In the implemented schema, diagnoses and prescriptions attach to a patient's 
medical record (and prescriptions further decompose into line items).

**Decomposition:**
1.  Create a diagnosis table to hold diagnoses for each visit/record.
2.  Create a prescription table (and line items) to hold medications for each visit/record.

The main table now looks like this:

**`appointment_info_1nf`**

| appointment_id (PK) | appointment_datetime | patient_id | patient_first_name | ... | hospital_name |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 101 | 2026-06-10 10:00 | 1 | John | ... | City General |
| 102 | 2026-06-10 11:00 | 2 | Jane | ... | City General |

**(Conceptual) Diagnosis table**

| appointment_id (FK) | diagnosis_code |
| :--- | :--- |
| 101 | I25.10 |
| 101 | Z00.00 |
| 102 | G43.909 |

**(Conceptual) Prescription table**

| appointment_id (FK) | medication_name | dosage |
| :--- | :--- | :--- |
| 101 | Atorvastatin | 20mg |
| 101 | Lisinopril | 10mg |
| 102 | Sumatriptan | 50mg |

**Improvement:** The data is now atomic, making it easier to query individual diagnoses or medications. However, massive redundancy still exists.

---

## Second Normal Form (2NF)

**Rule:** Must be in 1NF, and all non-key attributes must be fully functionally dependent on the entire primary key. (This rule is most relevant for tables with composite primary keys).

Our `appointment_info_1nf` table has a single-column primary key (`appointment_id`), so it is trivially in 2NF. However, it suffers from transitive dependencies, which are addressed by 3NF. Let's identify the functional dependencies to prepare for 3NF.

**Functional Dependencies in `appointment_info_1nf`:**
- `appointment_id` -> `appointment_datetime`, `patient_id`, `doctor_id`
- `patient_id` -> `patient_first_name`, `patient_last_name`, `patient_dob` (Partial Dependency if PK was composite)
- `doctor_id` -> `doctor_first_name`, `doctor_last_name`, `doctor_license`, `department_id`
- `department_id` -> `department_name`, `hospital_id`
- `hospital_id` -> `hospital_name`

The dependencies on `patient_id`, `doctor_id`, etc., are **transitive dependencies**.

---

## Third Normal Form (3NF)

**Rule:** Must be in 2NF, and there should be no transitive dependencies. A non-key attribute cannot depend on another non-key attribute.

We decompose the table to eliminate these transitive dependencies.

**Decomposition:**
1.  Create a `patient` table.
2.  Create a `doctor` table.
3.  Create a `department` table.
4.  Create a `hospital` table.
5.  The `appointment` table will only contain attributes directly related to the appointment event itself, with foreign keys to the other tables.

**Final Normalized Tables (in 3NF):**

Note: The final implementation uses a supertype/subtype structure. Common person attributes (name, email, address, etc.) are stored in `app_user`, while `patient`, `doctor`, and `admin` store role-specific attributes and reference `app_user(user_id)`.

**`hospital`**
- `hospital_id` (PK)
- `name`
- FD: `{hospital_id} -> {name}`

**`department`**
- `department_id` (PK)
- `name`
- `hospital_id` (FK)
- FD: `{department_id} -> {name, hospital_id}`

**`doctor`**
- `doctor_id` (PK, also FK to `app_user.user_id`)
- `license_number` (Candidate Key)
- `department_id` (FK)
- FDs: `{doctor_id} -> {license_number, department_id}`, `{license_number} -> {doctor_id, department_id}`

**`patient`**
- `patient_id` (PK, also FK to `app_user.user_id`)
- (Role-specific attributes only; personal attributes live in `app_user`)
- FD: `{patient_id} -> {all patient-specific attributes}`

**`appointment`**
- `appointment_id` (PK)
- `appointment_datetime`
- `patient_id` (FK)
- `doctor_id` (FK)
- FD: `{appointment_id} -> {appointment_datetime, patient_id, doctor_id}`

This structure is now in 3NF. We have eliminated the redundancy and the update/insertion/deletion anomalies.

---

## Boyce-Codd Normal Form (BCNF)

**Rule:** For every non-trivial functional dependency `X -> Y`, `X` must be a superkey.

BCNF is a stricter version of 3NF. A table is in BCNF if and only if every determinant is a candidate key.

Let's analyze our 3NF tables:
- **`hospital`**: The only determinant is `hospital_id`, which is the primary key (and thus a superkey). **In BCNF.**
- **`department`**: The only determinant is `department_id`, which is the primary key. **In BCNF.**
- **`patient`**: The only determinant is `patient_id`, which is the primary key. **In BCNF.**
- **`appointment`**: The only determinant is `appointment_id`, which is the primary key. **In BCNF.**
- **`doctor`**: We have two FDs:
    1.  `{doctor_id} -> {first_name, last_name, license_number, department_id}`
    2.  `{license_number} -> {doctor_id, first_name, last_name, department_id}`

    The determinants are `{doctor_id}` and `{license_number}`. Both are candidate keys for the `doctor` table. Since every determinant is a candidate key, the `doctor` table **is in BCNF.**

**Conclusion:** The final decomposed schema (`hospital`, `department`, `doctor`, `patient`, `appointment`, etc.) is in BCNF, providing a robust, scalable, and anomaly-free design. The schema implemented in `schema.sql` follows this normalized structure.
