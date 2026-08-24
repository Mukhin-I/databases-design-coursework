-- ------------------------
-- DOCTOR / DEPARTMENT
-- ------------------------

-- helps query 2 joins
CREATE INDEX idx_doctor_department_id ON DOCTOR(Department_ID);

-- ------------------------
-- APPOINTMENT
-- ------------------------

-- speeds up query 1 aggregation
CREATE INDEX idx_appointment_doctor_id ON APPOINTMENT(Doctor_ID);
CREATE INDEX idx_appointment_patient_id ON APPOINTMENT(Patient_ID);
CREATE INDEX idx_appointment_patient_date ON APPOINTMENT(Patient_ID, Date);

-- helps filtered counts
CREATE INDEX idx_appointment_status ON APPOINTMENT(Status);

-- ------------------------
-- DIAGNOSIS
-- ------------------------

-- improves join for diagnosis counting
CREATE INDEX idx_diagnosis_appointment_id ON DIAGNOSIS(Appointment_ID);

-- ------------------------
-- APPOINTMENT_PROCEDURE
-- ------------------------

-- speeds spending calculation
CREATE INDEX idx_appt_proc_appt_id ON APPOINTMENT_PROCEDURE(Appointment_ID);
CREATE INDEX idx_appt_proc_proc_id ON APPOINTMENT_PROCEDURE(Procedure_ID);

-- ------------------------
-- PROCEDURE
-- ------------------------

-- speeds spending calculation
CREATE INDEX idx_procedure_id_price ON PROCEDURE(ID, Price);

-- ------------------------
-- PATIENT
-- ------------------------
CREATE INDEX idx_patient_id ON PATIENT(ID);
