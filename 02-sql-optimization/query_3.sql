SELECT
    a2.ID AS appointment_id,
    p.Full_name AS patient_name,
    d.Full_name AS doctor_name,
    a2.Date AS appointment_date,
    a2.Time AS appointment_time,
    COUNT(a1.ID) AS earlier_appointments
FROM APPOINTMENT a2
JOIN PATIENT p ON a2.Patient_ID = p.ID
JOIN DOCTOR d ON a2.Doctor_ID = d.ID
JOIN APPOINTMENT a1
    ON a1.Patient_ID = a2.Patient_ID
   AND a1.Date < a2.Date
GROUP BY a2.ID, p.Full_name, d.Full_name, a2.Date, a2.Time
HAVING COUNT(a1.ID) >= 3
ORDER BY patient_name ASC, appointment_date ASC, appointment_time ASC;
