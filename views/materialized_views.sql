-- Materialized Views for Silver Layer (MSSQL)

-- 1. Patient Visit Summary
CREATE VIEW mv_patient_visit_summary AS
SELECT
    p.patient_id,
    COUNT(a.appointment_id) AS total_appointments,
    SUM(CASE WHEN a.status = 'Completed' THEN 1 ELSE 0 END) AS completed_visits,
    AVG(DATEDIFF(DAY, LAG(a.appointment_date) OVER (PARTITION BY a.patient_id ORDER BY a.appointment_date), a.appointment_date)) AS avg_days_between_visits
FROM patients p
LEFT JOIN appointments a ON p.patient_id = a.patient_id
GROUP BY p.patient_id;

-- 2. Prescription Summary
CREATE VIEW mv_prescription_stats AS
SELECT
    medication,
    COUNT(*) AS total_prescriptions,
    COUNT(DISTINCT patient_id) AS unique_patients
FROM prescriptions
GROUP BY medication;

-- 3. Revenue Summary
CREATE VIEW mv_revenue_summary AS
SELECT
    d.department,
    SUM(b.amount) AS total_revenue,
    SUM(CASE WHEN b.payment_status != 'Paid' THEN b.amount ELSE 0 END) AS outstanding_amount
FROM appointments a
JOIN billing b ON a.appointment_id = b.appointment_id
JOIN (
    SELECT DISTINCT appointment_id, department FROM appointments
) d ON a.appointment_id = d.appointment_id
GROUP BY d.department;
