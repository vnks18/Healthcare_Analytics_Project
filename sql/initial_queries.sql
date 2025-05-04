-- Advanced SQL Queries for Healthcare Analytics (MSSQL)
-- Author: Nirupam Velagapudi

-- SECTION 1: Patient visit behavior
WITH CompletedAppointments AS (
    SELECT *
    FROM appointments
    WHERE status = 'Completed'
),
PatientVisitGap AS (
    SELECT
        patient_id,
        appointment_date,
        LAG(appointment_date) OVER (PARTITION BY patient_id ORDER BY appointment_date) AS prev_appointment,
        DATEDIFF(DAY, LAG(appointment_date) OVER (PARTITION BY patient_id ORDER BY appointment_date), appointment_date) AS days_between
    FROM CompletedAppointments
),
PatientVisitSummary AS (
    SELECT
        patient_id,
        COUNT(*) AS total_visits,
        AVG(days_between) AS avg_days_between_visits,
        MIN(appointment_date) AS first_visit,
        MAX(appointment_date) AS last_visit
    FROM PatientVisitGap
    GROUP BY patient_id
)

-- SECTION 2: No-show and cancellation rate
, AppointmentStats AS (
    SELECT
        a.patient_id,
        COUNT(*) AS total_appointments,
        SUM(CASE WHEN status = 'No-Show' THEN 1 ELSE 0 END) AS no_shows,
        SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancellations
    FROM appointments a
    GROUP BY a.patient_id
)

-- SECTION 3: Prescription analysis
, PrescriptionSummary AS (
    SELECT
        patient_id,
        COUNT(*) AS total_prescriptions,
        COUNT(DISTINCT medication) AS unique_medications,
        MIN(prescribed_date) AS first_prescribed,
        MAX(prescribed_date) AS last_prescribed
    FROM prescriptions
    GROUP BY patient_id
),
TopPrescribed AS (
    SELECT
        medication,
        COUNT(*) AS times_prescribed,
        COUNT(DISTINCT patient_id) AS patient_count
    FROM prescriptions
    GROUP BY medication
)

-- SECTION 4: Billing metrics by patient
, BillingStats AS (
    SELECT
        patient_id,
        COUNT(*) AS billing_entries,
        SUM(amount) AS total_billed,
        SUM(CASE WHEN payment_status = 'Paid' THEN amount ELSE 0 END) AS total_paid,
        SUM(CASE WHEN payment_status <> 'Paid' THEN amount ELSE 0 END) AS total_outstanding,
        AVG(amount) AS avg_billed_per_visit
    FROM billing
    GROUP BY patient_id
)

-- SECTION 5: Doctor productivity
, DoctorAppointmentStats AS (
    SELECT
        doctor_id,
        COUNT(*) AS total_appointments,
        SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) AS completed,
        SUM(CASE WHEN status = 'No-Show' THEN 1 ELSE 0 END) AS no_shows,
        SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled
    FROM appointments
    GROUP BY doctor_id
),
DoctorPrescriptionStats AS (
    SELECT
        doctor_id,
        COUNT(*) AS total_prescriptions,
        COUNT(DISTINCT medication) AS medications_prescribed,
        COUNT(DISTINCT patient_id) AS unique_patients
    FROM prescriptions
    GROUP BY doctor_id
)

-- SECTION 6: Department revenue
, DepartmentRevenue AS (
    SELECT
        a.department,
        SUM(b.amount) AS total_revenue,
        SUM(CASE WHEN b.payment_status <> 'Paid' THEN b.amount ELSE 0 END) AS outstanding
    FROM appointments a
    JOIN billing b ON a.appointment_id = b.appointment_id
    GROUP BY a.department
)

-- FINAL SELECT: Comprehensive patient profile
SELECT
    p.patient_id,
    p.first_name + ' ' + p.last_name AS full_name,
    p.gender,
    p.date_of_birth,
    COALESCE(pv.total_visits, 0) AS total_visits,
    COALESCE(pv.avg_days_between_visits, 0) AS avg_days_between_visits,
    COALESCE(ps.total_prescriptions, 0) AS total_prescriptions,
    COALESCE(b.total_billed, 0) AS total_billed,
    COALESCE(b.total_paid, 0) AS total_paid,
    COALESCE(a.total_appointments, 0) AS total_appointments,
    COALESCE(a.no_shows, 0) AS no_show_count,
    COALESCE(a.cancellations, 0) AS cancellation_count
FROM patients p
LEFT JOIN PatientVisitSummary pv ON p.patient_id = pv.patient_id
LEFT JOIN AppointmentStats a ON p.patient_id = a.patient_id
LEFT JOIN PrescriptionSummary ps ON p.patient_id = ps.patient_id
LEFT JOIN BillingStats b ON p.patient_id = b.patient_id
ORDER BY total_billed DESC;

-- Additional Queries:
-- Top 10 prescribed medications
SELECT TOP 10 *
FROM TopPrescribed
ORDER BY times_prescribed DESC;

-- Doctor productivity joined with prescriptions
SELECT
    d1.doctor_id,
    d1.total_appointments,
    d1.completed,
    d1.no_shows,
    d1.cancelled,
    d2.total_prescriptions,
    d2.medications_prescribed,
    d2.unique_patients
FROM DoctorAppointmentStats d1
JOIN DoctorPrescriptionStats d2 ON d1.doctor_id = d2.doctor_id
ORDER BY d1.total_appointments DESC;

-- Revenue by department
SELECT *
FROM DepartmentRevenue
ORDER BY total_revenue DESC;
