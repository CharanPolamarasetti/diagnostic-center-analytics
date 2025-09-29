--======================================================================================
-- Diagnostic Center Database: Data Quality & Integrity Checks
-- Purpose: To validate record counts, PK integrity, referential consistency, and indexing
--======================================================================================

--================================================
-- To validate number of records in each table
--================================================
SELECT 'patients' as table, COUNT(*) FROM patients;
SELECT 'staff'    as table, COUNT(*) FROM staff;
SELECT 'tests'    as table, COUNT(*) FROM tests;
SELECT 'visits'   as table, COUNT(*) FROM visits;
SELECT 'appointments' as table, COUNT(*) FROM appointments;
SELECT 'billing'  as table, COUNT(*) FROM billing;
SELECT 'test_results' as table, COUNT(*) FROM test_results;

--======================================
-- To check whether any NULL PKs exists
--======================================
SELECT COUNT(*) AS null_patient_id_count FROM patients WHERE patient_id IS NULL;
SELECT COUNT(*) AS null_staff_id_count FROM staff WHERE staff_id IS NULL;
SELECT COUNT(*) AS null_test_id_count FROM tests WHERE test_id IS NULL;
SELECT COUNT(*) AS null_visit_id_count FROM visits WHERE visit_id IS NULL;
SELECT COUNT(*) AS null_appointment_id_count FROM appointments WHERE appointment_id IS NULL;
SELECT COUNT(*) AS null_billing_id_count FROM billing WHERE billing_id IS NULL;
SELECT COUNT(*) AS null_result_id_count FROM test_results WHERE result_id IS NULL;

--=====================================================
-- To check wheteher any duplicate PKs exists
--=====================================================
SELECT patient_id, COUNT(*) AS duplicate_patient_id_count FROM patients GROUP BY patient_id HAVING COUNT(*) > 1;
SELECT staff_id, COUNT(*) AS duplicate_staff_id_count FROM staff GROUP BY staff_id HAVING COUNT(*) > 1;
SELECT test_id, COUNT(*) AS duplicate_test_id_count FROM tests GROUP BY test_id HAVING COUNT(*) > 1;
SELECT visit_id, COUNT(*) AS duplicate_visit_id_count FROM visits GROUP BY visit_id HAVING COUNT(*) > 1;
SELECT appointment_id, COUNT(*) AS duplicate_appointment_id_count FROM appointments GROUP BY appointment_id HAVING COUNT(*) > 1;
SELECT billing_id, COUNT(*) AS duplicate_billing_id_count FROM billing GROUP BY billing_id HAVING COUNT(*) > 1;
SELECT result_id, COUNT(*) AS duplicate_result_id_count FROM test_results GROUP BY result_id HAVING COUNT(*) > 1;

--================================================
-- To ensure there is no negative or zero amounts
--================================================
SELECT COUNT(*) AS invalid_cost_count FROM tests WHERE cost <= 0;
SELECT COUNT(*) AS invalid_amount_count FROM billing WHERE amount <= 0;

--===============================
-- Referential integrity checks
--===============================
-- staff rows whose department_id doesn't exist in departments
SELECT s.* FROM staff s
LEFT JOIN departments d ON s.department_id = d.department_id
WHERE d.department_id IS NULL;

-- visits rows whose patient_id or staff_id doesn't exist in respective tables
SELECT v.* FROM visits v
LEFT JOIN patients p ON v.patient_id = p.patient_id
LEFT JOIN staff s ON v.staff_id = s.staff_id
WHERE p.patient_id IS NULL OR s.staff_id IS NULL;

-- billing rows whose visit_id doesn't exist in visits
SELECT b.* FROM billing b
LEFT JOIN visits v ON b.visit_id = v.visit_id
WHERE v.visit_id IS NULL;

-- appointments rows whose patient_id or staff_id doesn't exist in respective tables
SELECT a.* FROM appointments a
LEFT JOIN patients p ON a.patient_id = p.patient_id
LEFT JOIN staff s ON a.staff_id = s.staff_id
WHERE p.patient_id IS NULL OR s.staff_id IS NULL;

-- test_results rows whose test_id, patient_id and visit_id doesn't exist in respective tables
SELECT tr.* FROM test_results tr
LEFT JOIN tests t ON tr.test_id = t.test_id
LEFT JOIN patients p ON tr.patient_id = p.patient_id
LEFT JOIN visits v ON tr.visit_id = v.visit_id
WHERE t.test_id IS NULL OR p.patient_id IS NULL OR v.visit_id IS NULL;

--=======================================
-- Foreign Key Indexes (for faster JOINS)
--=======================================
-- staff table FKs
CREATE INDEX idx_staff_department_id ON staff (department_id);

-- visits table FKs
CREATE INDEX idx_visits_patient_id ON visits (patient_id);
CREATE INDEX idx_visits_staff_id ON visits (staff_id);

-- billing table FKs
CREATE INDEX idx_billing_visit_id ON billing (visit_id);

-- appointments table FKs
CREATE INDEX idx_appointments_patient_id ON appointments (patient_id);
CREATE INDEX idx_appointments_staff_id ON appointments (staff_id);

-- test_results table FKs
CREATE INDEX idx_testresults_test_id ON test_results (test_id);
CREATE INDEX idx_testresults_patient_id ON test_results (patient_id);
CREATE INDEX idx_testresults_visit_id ON test_results (visit_id);

-- Operational filtering/grouping Indexes
CREATE INDEX idx_tests_category ON tests (category);
CREATE INDEX idx_visits_visit_type ON visits (visit_type);
CREATE INDEX idx_testresults_status ON test_results (status);
CREATE INDEX idx_staff_role ON staff (role);

VACUUM ANALYZE;