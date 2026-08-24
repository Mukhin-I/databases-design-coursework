WITH patient_spending AS (
    SELECT
        p.id AS patient_id,
        COALESCE(SUM(pr.price), 0) AS total_spent
    FROM patient p
    LEFT JOIN appointment a ON a.patient_id = p.id
    LEFT JOIN appointment_procedure ap ON ap.appointment_id = a.id
    LEFT JOIN procedure pr ON pr.id = ap.procedure_id
    GROUP BY p.id
),
patient_stats AS (
    SELECT
        p.id AS patient_id,
        p.full_name,
        COUNT(DISTINCT d.id) AS distinct_departments,
        COUNT(DISTINCT a.id) AS total_appointments,
        COUNT(DISTINCT diag.id) AS total_diagnoses
    FROM patient p
    LEFT JOIN appointment a ON a.patient_id = p.id
    LEFT JOIN doctor doc ON a.doctor_id = doc.id
    LEFT JOIN department d ON doc.department_id = d.id
    LEFT JOIN diagnosis diag ON diag.appointment_id = a.id
    GROUP BY p.id, p.full_name
)
SELECT
    ps.patient_id,
    ps.full_name AS patient_full_name,
    ps.distinct_departments,
    ps.total_appointments,
    ps.total_diagnoses,
    sp.total_spent
FROM patient_stats ps
JOIN patient_spending sp ON ps.patient_id = sp.patient_id
WHERE
    ps.distinct_departments >= 3
    AND sp.total_spent > (
        SELECT AVG(total_spent)
        FROM patient_spending
        WHERE total_spent > 0
    )
ORDER BY
    sp.total_spent DESC,
    ps.total_appointments DESC,
    ps.full_name ASC;
