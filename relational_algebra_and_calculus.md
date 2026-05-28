# Relational Algebra and Tuple Relational Calculus Examples

This document provides 5 query examples written in natural language, relational algebra, and tuple relational calculus.

---

### Query 1: Find the names of all patients who have a scheduled appointment.

-   **Relational Algebra:**
    Π<sub>first_name, last_name</sub> (
        (app_user ⨝<sub>app_user.user_id = patient.patient_id</sub> patient) ⨝<sub>patient.patient_id = appointment.patient_id</sub> (σ<sub>status='scheduled'</sub>(appointment))
    )

-   **Tuple Relational Calculus:**
    `{ t | ∃u ∈ app_user, ∃p ∈ patient, ∃a ∈ appointment (`
    `u.user_id = p.patient_id ∧ p.patient_id = a.patient_id ∧ a.status = 'scheduled' ∧`
    `t.first_name = u.first_name ∧ t.last_name = u.last_name) }`

---

### Query 2: Find the names of all doctors working in the 'Cardiology' department.

-   **Relational Algebra:**
    Π<sub>first_name, last_name</sub> (
        (app_user ⨝<sub>app_user.user_id = doctor.doctor_id</sub> doctor) ⨝<sub>doctor.department_id = department.department_id</sub> (σ<sub>name='Cardiology'</sub>(department))
    )

-   **Tuple Relational Calculus:**
    `{ t | ∃u ∈ app_user, ∃d ∈ doctor, ∃dept ∈ department (`
    `u.user_id = d.doctor_id ∧ d.department_id = dept.department_id ∧ dept.name = 'Cardiology' ∧`
    `t.first_name = u.first_name ∧ t.last_name = u.last_name) }`

---

### Query 3: Find the amount and due date of all unpaid bills.

-   **Relational Algebra:**
    Π<sub>amount, due_date</sub> (σ<sub>status='unpaid'</sub>(bill))

-   **Tuple Relational Calculus:**
    `{ t | ∃b ∈ bill (b.status = 'unpaid' ∧ t.amount = b.amount ∧ t.due_date = b.due_date) }`

---

### Query 4: Find the names of patients who have at least one 'abnormal' lab result.

-   **Relational Algebra:**
    Π<sub>first_name, last_name</sub> (
        (app_user ⨝<sub>app_user.user_id = patient.patient_id</sub> patient) ⨝<sub>patient.patient_id = lab_result.patient_id</sub> (σ<sub>status='abnormal'</sub>(lab_result))
    )

-   **Tuple Relational Calculus:**
    `{ t | ∃u ∈ app_user, ∃p ∈ patient, ∃lr ∈ lab_result (`
    `u.user_id = p.patient_id ∧ p.patient_id = lr.patient_id ∧ lr.status = 'abnormal' ∧`
    `t.first_name = u.first_name ∧ t.last_name = u.last_name) }`

---

### Query 5: Find the names of all medications prescribed to the patient with `patient_id = 1`.

-   **Relational Algebra:**
    Π<sub>name</sub> (
        medication ⨝<sub>medication.medication_id = prescription_item.medication_id</sub>
        prescription_item ⨝<sub>prescription_item.prescription_id = prescription.prescription_id</sub>
        prescription ⨝<sub>prescription.record_id = medical_record.record_id</sub>
        (σ<sub>patient_id=1</sub>(medical_record))
    )

-   **Tuple Relational Calculus:**
    `{ t | ∃m ∈ medication, ∃pi ∈ prescription_item, ∃p ∈ prescription, ∃mr ∈ medical_record (`
    `m.medication_id = pi.medication_id ∧ pi.prescription_id = p.prescription_id ∧ p.record_id = mr.record_id ∧ mr.patient_id = 1 ∧`
    `t.name = m.name) }`
