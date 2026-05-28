# Relational Algebra and Tuple Relational Calculus Examples

This document provides 5 query examples written in natural language, relational algebra, and tuple relational calculus.

---

### Query 1: Find the names of all patients who have a scheduled appointment.

-   **Relational Algebra:**
    \Pi_{first_name, last_name}(
        (app_user \bowtie_{app_user.user_id = patient.patient_id} patient)
        \bowtie_{patient.patient_id = appointment.patient_id}
        (\sigma_{status='scheduled'}(appointment))
    )

-   **Tuple Relational Calculus:**
    `{ t | \exists u \in app_user, \exists p \in patient, \exists a \in appointment (`
    `u.user_id = p.patient_id \wedge p.patient_id = a.patient_id \wedge a.status = 'scheduled' \wedge`
    `t.first_name = u.first_name \wedge t.last_name = u.last_name) }`

---

### Query 2: Find the names of all doctors working in the 'Cardiology' department.

-   **Relational Algebra:**
    \Pi_{first_name, last_name}(
        (app_user \bowtie_{app_user.user_id = doctor.doctor_id} doctor)
        \bowtie_{doctor.department_id = department.department_id}
        (\sigma_{name='Cardiology'}(department))
    )

-   **Tuple Relational Calculus:**
    `{ t | \exists u \in app_user, \exists d \in doctor, \exists dept \in department (`
    `u.user_id = d.doctor_id \wedge d.department_id = dept.department_id \wedge dept.name = 'Cardiology' \wedge`
    `t.first_name = u.first_name \wedge t.last_name = u.last_name) }`

---

### Query 3: Find the amount and due date of all unpaid bills.

-   **Relational Algebra:**
    \Pi_{amount, due_date}(\sigma_{status='unpaid'}(bill))

-   **Tuple Relational Calculus:**
    `{ t | \exists b \in bill (b.status = 'unpaid' \wedge t.amount = b.amount \wedge t.due_date = b.due_date) }`

---

### Query 4: Find the names of patients who have at least one 'abnormal' lab result.

-   **Relational Algebra:**
    \Pi_{first_name, last_name}(
        (app_user \bowtie_{app_user.user_id = patient.patient_id} patient)
        \bowtie_{patient.patient_id = lab_result.patient_id}
        (\sigma_{status='abnormal'}(lab_result))
    )

-   **Tuple Relational Calculus:**
    `{ t | \exists u \in app_user, \exists p \in patient, \exists lr \in lab_result (`
    `u.user_id = p.patient_id \wedge p.patient_id = lr.patient_id \wedge lr.status = 'abnormal' \wedge`
    `t.first_name = u.first_name \wedge t.last_name = u.last_name) }`

---

### Query 5: Find the names of all medications prescribed to the patient with `patient_id = 1`.

-   **Relational Algebra:**
    \Pi_{name}(
        medication \bowtie_{medication.medication_id = prescription_item.medication_id}
        prescription_item \bowtie_{prescription_item.prescription_id = prescription.prescription_id}
        prescription \bowtie_{prescription.record_id = medical_record.record_id}
        (\sigma_{patient_id=1}(medical_record))
    )

-   **Tuple Relational Calculus:**
    `{ t | \exists m \in medication, \exists pi \in prescription_item, \exists p \in prescription, \exists mr \in medical_record (`
    `m.medication_id = pi.medication_id \wedge pi.prescription_id = p.prescription_id \wedge p.record_id = mr.record_id \wedge mr.patient_id = 1 \wedge`
    `t.name = m.name) }`
