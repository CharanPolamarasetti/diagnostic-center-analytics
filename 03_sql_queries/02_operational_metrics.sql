-- =========================================================================
-- Provide the owner with metrics on workflow efficiency, staff 
-- productivity, and the financial performance of different payment modes.
-- =========================================================================

-- =========================================================================
-- Test result logging time
-- Measures the average time taken (in days, hours and minutes) 
-- from the visit to the final logging of the medical result status
-- =========================================================================
SELECT 
    tr.status,
    t.category,
    ROUND(ABS(AVG(tr.result_date - v.visit_date)), 2) AS avg_result_logging_time_days,
    ROUND(ABS(AVG(tr.result_date - v.visit_date)) * 24, 2) AS avg_result_logging_time_hours,
    ROUND(ABS(AVG(tr.result_date - v.visit_date)) * 24 * 60, 2) AS avg_result_logging_time_minutes
FROM test_results tr
JOIN tests t ON tr.test_id = t.test_id
JOIN visits v ON tr.visit_id = v.visit_id
WHERE tr.result_date IS NOT NULL 
GROUP BY 1, 2
ORDER BY avg_result_logging_time_days DESC;

-- =========================================================
-- Scheduled vs Completed vs Cancelled test status
-- Provides a real-time status of the current workload
-- =========================================================
SELECT
    a.status, 
    COUNT(a.appointment_id) AS total_count,
	ROUND(
    	(COUNT(a.appointment_id) * 100.0) / SUM(COUNT(a.appointment_id)) OVER (), 2
	) AS percentage_of_total
FROM appointments a
GROUP BY 1
ORDER BY 2 DESC;

-- =================================================================================
-- Staff productivity (visit volume contribution)
-- Measures staff contribution based on the number of VISITS they were assigned to
-- =================================================================================
SELECT
    s.name AS staff_name,
    s.role,
    COUNT(v.visit_id) AS total_visits_handled,
    ROUND(AVG(tr_max.latest_result_date - v.visit_date)) AS avg_visit_completion_days
FROM staff s
JOIN visits v ON s.staff_id = v.staff_id
LEFT JOIN (
    SELECT 
        visit_id, 
        MAX(result_date) AS latest_result_date
    FROM test_results 
    GROUP BY visit_id
) AS tr_max ON v.visit_id = tr_max.visit_id
WHERE s.role IN ('Receptionist', 'Doctor', 'Lab Technician', 'Radiologist', 'Pathologist')
    AND tr_max.latest_result_date IS NOT NULL
GROUP BY 1, 2
ORDER BY total_visits_handled DESC, avg_visit_completion_days ASC;

-- =========================================================================
-- Revenue and volume by visit_type and payment_method
-- Analyzes the financial output and popularity of payment mode
-- =========================================================================
SELECT
    v.visit_type,
    b.payment_method,
    COUNT(v.visit_id) AS total_visits,
    SUM(b.amount) AS total_revenue,
    ROUND(
		(SUM(b.amount) * 100.0) / SUM(SUM(b.amount)) OVER (), 4
	) AS percentage_of_total_revenue
FROM visits v
JOIN billing b ON v.visit_id = b.visit_id
GROUP BY 1, 2 
ORDER BY visit_type, total_revenue DESC;
