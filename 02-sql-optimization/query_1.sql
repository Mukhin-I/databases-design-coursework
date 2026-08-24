SELECT
    d.ID AS doctor_id,
    d.Full_name AS doctor_full_name,
    dep.Name AS department_name,
    COUNT(a.ID) AS total_appointments,
    COUNT(*) FILTER (WHERE a.Status = 'Completed') AS completed_appointments,
    COUNT(*) FILTER (WHERE a.Status = 'Cancelled') AS cancelled_appointments
FROM DOCTOR d
JOIN DEPARTMENT dep ON d.Department_ID = dep.ID
JOIN APPOINTMENT a ON a.Doctor_ID = d.ID
GROUP BY d.ID, d.Full_name, dep.Name
HAVING COUNT(a.ID) > 20
ORDER BY total_appointments DESC, doctor_full_name ASC;
