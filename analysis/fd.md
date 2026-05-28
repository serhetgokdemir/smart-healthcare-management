# Functional Dependencies (FDs) and Normal Forms

This document outlines the functional dependencies for key tables in the database, determines their candidate keys, and analyzes their normal form.

---

### 1. `app_user` Table

This table stores core information for all users in the system.

**Attributes:** `user_id`, `first_name`, `last_name`, `email`, `password_hash`, `date_of_birth`, `street`, `district`, `city`, `postal_code`, `country`

**Functional Dependencies:**
-   `{user_id} -> {first_name, last_name, email, password_hash, date_of_birth, street, district, city, postal_code, country}`
    -   The primary key `user_id` uniquely determines all other attributes.
-   `{email} -> {user_id, first_name, last_name, password_hash, date_of_birth, street, district, city, postal_code, country}`
    -   The `email` is a unique identifier for a user.

**Candidate Keys:**
-   `{user_id}`
-   `{email}`

**Normalization Analysis:**
-   The table is in **BCNF**.
-   **Reasoning:** The determinants are `{user_id}` and `{email}`. Both are candidate keys. Since all determinants are candidate keys, the table satisfies the BCNF condition.

---

### 2. `doctor` Table

This table is a subtype of `app_user` and stores doctor-specific information.

**Attributes:** `doctor_id`, `license_number`, `department_id`

**Functional Dependencies:**
-   `{doctor_id} -> {license_number, department_id}`
    -   `doctor_id` is the primary key and is also a foreign key to `app_user(user_id)`.
-   `{license_number} -> {doctor_id, department_id}`
    -   The `license_number` is a unique value assigned to each doctor.

**Candidate Keys:**
-   `{doctor_id}`
-   `{license_number}`

**Normalization Analysis:**
-   The table is in **BCNF**.
-   **Reasoning:** The determinants are `{doctor_id}` and `{license_number}`. Both are candidate keys. The table is in BCNF.

---

### 3. `appointment` Table

This table records appointments between patients and doctors.

**Attributes:** `appointment_id`, `patient_id`, `doctor_id`, `appointment_datetime`, `duration_minutes`, `status`, `notes`

**Functional Dependencies:**
-   `{appointment_id} -> {patient_id, doctor_id, appointment_datetime, duration_minutes, status, notes}`
    -   The primary key `appointment_id` determines all other attributes of the appointment.

Note: The implemented schema enforces no overlap for scheduled/completed appointments using exclusion constraints over a time range (based on `appointment_datetime` and `duration_minutes`). This is a business rule constraint rather than a strict functional dependency that yields additional candidate keys.

**Candidate Keys:**
-   `{appointment_id}` (Primary Key)

**Normalization Analysis:**
-   The table is in **BCNF**.
-   **Reasoning:** Assuming `appointment_id` is the sole primary key, it is the only determinant for the main FD. Other potential FDs rely on determinants that are also candidate keys. There are no transitive dependencies (e.g., `patient_id` does not determine `doctor_id`). Therefore, the table is in BCNF.

---

### 4. `prescription_item` Table

This is a weak entity that details the medications within a single prescription.

**Attributes:** `prescription_id`, `item_number`, `medication_id`, `dosage`, `frequency`, `duration_days`

**Functional Dependencies:**
-   `{prescription_id, item_number} -> {medication_id, dosage, frequency, duration_days}`
    -   The composite key, consisting of the foreign key `prescription_id` and the partial key `item_number`, uniquely determines the details of that specific line item in the prescription.

**Candidate Keys:**
-   `{prescription_id, item_number}`

**Normalization Analysis:**
-   The table is in **BCNF**.
-   **Reasoning:** The only determinant is the composite primary key `{prescription_id, item_number}`. Since this is a superkey, the table is in BCNF. All non-key attributes (`medication_id`, `dosage`, etc.) are fully dependent on the entire primary key, satisfying 2NF, and there are no transitive dependencies, satisfying 3NF and BCNF.

---

### 5. `bill` Table

This table stores billing information related to appointments or other services.

**Attributes:** `bill_id`, `patient_id`, `appointment_id`, `amount`, `issue_date`, `due_date`, `status`

**Functional Dependencies:**
-   `{bill_id} -> {patient_id, appointment_id, amount, issue_date, due_date, status}`
    -   The primary key `bill_id` determines all other attributes.

Note: The only full candidate key of the bill table is `{bill_id}`. For non-null appointment-linked bills, `appointment_id` is unique and acts as a conditional determinant, but it is not treated as a full candidate key because it is nullable.

**Candidate Keys:**
-   `{bill_id}`

Note: `appointment_id` is UNIQUE when present, but since it is nullable it is not treated as a full candidate key for the entire table.

**Normalization Analysis:**
-   The table is in **BCNF**.
-   **Reasoning:** The only non-trivial functional dependency is determined by `{bill_id}`, which is a candidate key. Therefore, the table satisfies BCNF.
