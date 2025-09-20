-- ==================
-- departments table
-- ==================
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);
-- ==============
-- staff table
-- ==============
CREATE TABLE staff (
    staff_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    role VARCHAR(50),
    department_id INT REFERENCES departments(department_id),
    email VARCHAR(100),
    phone VARCHAR(15)
);
-- ====================
-- patients table
-- ====================
CREATE TABLE patients (
    patient_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
	age INT,
    gender VARCHAR(10),
    address VARCHAR(255),
    phone VARCHAR(15),
	email VARCHAR(100)
);
-- ================
-- visits table
-- ================
CREATE TABLE visits (
    visit_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    visit_date DATE,
    visit_type VARCHAR(50),
	staff_id INT REFERENCES staff(staff_id)
);
-- =========================
-- appointments table
-- =========================
CREATE TABLE appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    staff_id INT REFERENCES staff(staff_id),
    appointment_date DATE,
    status VARCHAR(50)
);
-- ====================
-- billing table
-- ====================
CREATE TABLE billing (
    billing_id SERIAL PRIMARY KEY,
    visit_id INT REFERENCES visits(visit_id),
    amount INT,
    payment_method VARCHAR(50),
    billing_date DATE
);
-- ==================
-- tests table
-- ==================
CREATE TABLE tests (
    test_id SERIAL PRIMARY KEY,
    test_name VARCHAR(100),
    category VARCHAR(50),
    cost INT
);
-- =======================
-- test_results table
-- =======================
CREATE TABLE test_results (
    result_id SERIAL PRIMARY KEY,
    test_id INT REFERENCES tests(test_id),
	patient_id INT REFERENCES patients(patient_id),
	visit_id INT REFERENCES visits(visit_id),
    result_value FLOAT,
    result_date DATE,
	status VARCHAR(50)
);
