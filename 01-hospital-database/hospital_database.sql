
CREATE DATABASE hospital_team_68;
\connect hospital_team_68

-- Clean schema inside hospital
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

CREATE TABLE DEPARTMENT (
    ID              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Name            TEXT NOT NULL UNIQUE,
    Building_number INT  NOT NULL CHECK (Building_number > 0),
    Room_number     INT  NOT NULL CHECK (Room_number > 0)
);

CREATE TABLE DOCTOR (
    ID              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Full_name       TEXT NOT NULL,
    Specialization  TEXT NOT NULL,
    Phone           TEXT NOT NULL,
    Email           TEXT NOT NULL UNIQUE,
    Hire_date       DATE NOT NULL CHECK (Hire_date <= CURRENT_DATE),
    Licence_number  TEXT NOT NULL UNIQUE,
    Department_ID   BIGINT NOT NULL REFERENCES DEPARTMENT(ID) ON DELETE RESTRICT
);

CREATE TABLE PATIENT (
    ID            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Full_name     TEXT NOT NULL,
    National_ID   TEXT NOT NULL UNIQUE,
    Gender        TEXT NOT NULL CHECK (Gender IN ('M','F','X')),
    Date_of_birth DATE NOT NULL CHECK (Date_of_birth < CURRENT_DATE),
    Phone         TEXT NOT NULL,
    Email         TEXT NOT NULL UNIQUE,
    Address       TEXT NOT NULL
);

-- Appointment has exactly one patient and one doctor
-- "One appointment contains exactly one diagnosis" is enforced via:
-- 1) APPOINTMENT.Diagnosis_ID NOT NULL UNIQUE (so each appointment has one diagnosis)
-- 2) DIAGNOSIS.Appointment_ID NOT NULL UNIQUE (so each diagnosis belongs to exactly one appointment)
-- Both FKs are DEFERRABLE to allow inserting both sides in one transaction.
CREATE TABLE APPOINTMENT (
    ID          BIGINT PRIMARY KEY,  -- we will generate IDs explicitly to pair with DIAGNOSIS insert
    Date        DATE NOT NULL,
    Time        TIME NOT NULL,
    Status      TEXT NOT NULL CHECK (Status IN ('Scheduled','Completed','Cancelled','NoShow')),
    Patient_ID  BIGINT NOT NULL REFERENCES PATIENT(ID) ON DELETE RESTRICT,
    Doctor_ID   BIGINT NOT NULL REFERENCES DOCTOR(ID) ON DELETE RESTRICT,
    Diagnosis_ID BIGINT NOT NULL UNIQUE
        DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE DIAGNOSIS (
    ID          BIGINT PRIMARY KEY, -- generated explicitly
    Title       TEXT NOT NULL,
    Description TEXT,
    Appointment_ID BIGINT NOT NULL UNIQUE
        REFERENCES APPOINTMENT(ID) ON DELETE CASCADE
        DEFERRABLE INITIALLY DEFERRED
);

-- now that DIAGNOSIS exists, add FK from APPOINTMENT to DIAGNOSIS
ALTER TABLE APPOINTMENT
    ADD CONSTRAINT appointment_diagnosis_fk
    FOREIGN KEY (Diagnosis_ID)
    REFERENCES DIAGNOSIS(ID)
    ON DELETE RESTRICT
    DEFERRABLE INITIALLY DEFERRED;

CREATE TABLE PROCEDURE (
    ID    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Name  TEXT NOT NULL UNIQUE,
    Price NUMERIC(10,2) NOT NULL CHECK (Price >= 0)
);

-- Junction table for "appointment may include zero or more procedures"
CREATE TABLE APPOINTMENT_PROCEDURE (
    Appointment_ID BIGINT NOT NULL REFERENCES APPOINTMENT(ID) ON DELETE CASCADE,
    Procedure_ID   BIGINT NOT NULL REFERENCES PROCEDURE(ID)   ON DELETE RESTRICT,
    PRIMARY KEY (Appointment_ID, Procedure_ID)
);

-- -------------------------
-- DATA LOAD (random-ish)
-- Ensure: at least 10 rows in each entity table
-- -------------------------

-- 10 departments
INSERT INTO DEPARTMENT (Name, Building_number, Room_number)
SELECT
    'Department_' || gs,
    (1 + (random()*4)::int),
    (100 + (random()*300)::int)
FROM generate_series(1, 10) AS gs;

-- 15 doctors (each belongs to exactly one department)
INSERT INTO DOCTOR (Full_name, Specialization, Phone, Email, Hire_date, Licence_number, Department_ID)
SELECT
    'Doctor_' || gs || ' Fullname',
    (ARRAY['Cardiology','Neurology','Surgery','Radiology','Pediatrics','Oncology','Dermatology','Orthopedics'])[1 + (random()*7)::int],
    '+7' || lpad(((random()*9999999999)::bigint)::text, 10, '0'),
    'doctor_' || gs || '@hospital.local',
    (CURRENT_DATE - (365 * (1 + (random()*15)::int))),
    'LIC-' || lpad(gs::text, 6, '0'),
    (1 + (random()*9)::int)  -- department 1..10
FROM generate_series(1, 15) AS gs;

-- 20 patients
INSERT INTO PATIENT (Full_name, National_ID, Gender, Date_of_birth, Phone, Email, Address)
SELECT
    'Patient_' || gs || ' Fullname',
    'NID-' || md5(gs::text) || '-' || lpad((random()*9999)::int::text, 4, '0'),
    (ARRAY['M','F','X'])[1 + (random()*2)::int],
    (DATE '1950-01-01' + ((random()*25000)::int)), -- roughly 1950..2018
    '+7' || lpad(((random()*9999999999)::bigint)::text, 10, '0'),
    'patient_' || gs || '@mail.local',
    'Address line ' || gs || ', City'
FROM generate_series(1, 20) AS gs;

-- procedures: 12
INSERT INTO PROCEDURE (Name, Price)
SELECT
    'Procedure_' || gs,
    round((10 + random()*990)::numeric, 2)
FROM generate_series(1, 12) AS gs;

-- Appointments + Diagnoses
-- We generate 30 appointments. Each appointment gets exactly 1 diagnosis (1:1).
BEGIN;
SET CONSTRAINTS ALL DEFERRED;

-- create appointments with explicit IDs = 1..30, and Diagnosis_ID = same number
INSERT INTO APPOINTMENT (ID, Date, Time, Status, Patient_ID, Doctor_ID, Diagnosis_ID)
SELECT
    gs,
    (CURRENT_DATE - (random()*120)::int), -- last ~4 months
    (TIME '08:00' + make_interval(mins => (15 * (random()*32)::int))), -- 08:00..16:00 step 15m-ish
    (ARRAY['Scheduled','Completed','Cancelled','NoShow'])[1 + (random()*3)::int],
    (1 + (random()*19)::int), -- patient 1..20
    (1 + (random()*14)::int), -- doctor 1..15
    gs
FROM generate_series(1, 30) AS gs;

-- create diagnoses with same IDs 1..30 linked to appointment 1..30
INSERT INTO DIAGNOSIS (ID, Title, Description, Appointment_ID)
SELECT
    gs,
    'Diagnosis_' || gs,
    'Auto-generated diagnosis description #' || gs,
    gs
FROM generate_series(1, 30) AS gs;

COMMIT;

-- Appointment procedures: some appointments get 0..3 procedures
-- Insert ~50 links, with dedup via ON CONFLICT DO NOTHING
INSERT INTO APPOINTMENT_PROCEDURE (Appointment_ID, Procedure_ID)
SELECT
    (1 + (random()*29)::int) AS Appointment_ID,
    (1 + (random()*11)::int) AS Procedure_ID
FROM generate_series(1, 50)
ON CONFLICT DO NOTHING;

-- Recheck

-- SELECT count(*) FROM DEPARTMENT;
-- SELECT count(*) FROM DOCTOR;
-- SELECT count(*) FROM PATIENT;
-- SELECT count(*) FROM PROCEDURE;
-- SELECT count(*) FROM APPOINTMENT;
-- SELECT count(*) FROM DIAGNOSIS;
-- SELECT count(*) FROM APPOINTMENT_PROCEDURE;
