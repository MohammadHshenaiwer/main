-- ============================================================
-- UniSwap Database Seed Script
-- Target: Supabase project mkzqzkwjrwusyrqbiqyc
-- WARNING: Review before running! Does NOT drop existing data.
-- ============================================================

-- ═══════════════════════════════════════════════════════════
-- STEP 1: Create tables needed by Spring Boot / Hibernate
-- ═══════════════════════════════════════════════════════════

-- Add prerequisite column to existing courses table
ALTER TABLE courses ADD COLUMN IF NOT EXISTS prerequisite_course_code VARCHAR(255);

-- Students table (separate from existing 'users' table)
CREATE TABLE IF NOT EXISTS students (
    student_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE
);

-- Sections table (separate from existing 'course_sections' table)
CREATE TABLE IF NOT EXISTS sections (
    section_id BIGSERIAL PRIMARY KEY,
    course_id BIGINT REFERENCES courses(course_id),
    section_number VARCHAR(255) NOT NULL,
    instructor VARCHAR(255),
    schedule VARCHAR(255),
    capacity INTEGER,
    enrolled_count INTEGER,
    day_of_week VARCHAR(255),
    start_time TIME,
    end_time TIME,
    course_year INTEGER
);

CREATE TABLE IF NOT EXISTS enrollments (
    enrollment_id BIGSERIAL PRIMARY KEY,
    student_id BIGINT REFERENCES students(student_id),
    section_id BIGINT REFERENCES sections(section_id),
    status VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS swap_offers (
    offer_id BIGSERIAL PRIMARY KEY,
    student_id BIGINT NOT NULL REFERENCES students(student_id),
    swap_type VARCHAR(255) NOT NULL,
    have_section_id BIGINT REFERENCES sections(section_id),
    want_section_id BIGINT REFERENCES sections(section_id),
    target_student_id BIGINT REFERENCES students(student_id),
    status VARCHAR(255) NOT NULL DEFAULT 'OPEN',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS swap_requests (
    request_id BIGSERIAL PRIMARY KEY,
    offer_id BIGINT NOT NULL REFERENCES swap_offers(offer_id),
    sender_id BIGINT NOT NULL REFERENCES students(student_id),
    receiver_id BIGINT NOT NULL REFERENCES students(student_id),
    sender_section_id BIGINT REFERENCES sections(section_id),
    status VARCHAR(255) NOT NULL DEFAULT 'PENDING',
    sent_at TIMESTAMP DEFAULT NOW(),
    resolved_at TIMESTAMP
);

-- ═══════════════════════════════════════════════════════════
-- STEP 2: Update prerequisite course codes on existing courses
-- ═══════════════════════════════════════════════════════════

UPDATE courses SET prerequisite_course_code = '30301120' WHERE course_id = 4;
UPDATE courses SET prerequisite_course_code = '30303110' WHERE course_id = 5;
UPDATE courses SET prerequisite_course_code = '30301110' WHERE course_id = 9;
UPDATE courses SET prerequisite_course_code = '30301121' WHERE course_id = 11;
UPDATE courses SET prerequisite_course_code = '30303111' WHERE course_id = 12;
UPDATE courses SET prerequisite_course_code = '40303130' WHERE course_id = 13;
UPDATE courses SET prerequisite_course_code = '40303130' WHERE course_id = 14;
UPDATE courses SET prerequisite_course_code = '30302111' WHERE course_id = 15;
UPDATE courses SET prerequisite_course_code = '30301122' WHERE course_id = 18;
UPDATE courses SET prerequisite_course_code = '40201100' WHERE course_id = 19;
UPDATE courses SET prerequisite_course_code = '40303130' WHERE course_id = 20;
UPDATE courses SET prerequisite_course_code = '40201100' WHERE course_id = 21;
UPDATE courses SET prerequisite_course_code = '30302112' WHERE course_id = 22;
UPDATE courses SET prerequisite_course_code = '40201100' WHERE course_id = 23;
UPDATE courses SET prerequisite_course_code = '30301123' WHERE course_id = 24;
UPDATE courses SET prerequisite_course_code = '40303121' WHERE course_id = 26;
UPDATE courses SET prerequisite_course_code = '40201220' WHERE course_id = 27;
UPDATE courses SET prerequisite_course_code = '40201100' WHERE course_id = 28;
UPDATE courses SET prerequisite_course_code = '40201100' WHERE course_id = 29;
UPDATE courses SET prerequisite_course_code = '40302211' WHERE course_id = 30;
UPDATE courses SET prerequisite_course_code = '40201100' WHERE course_id = 32;
UPDATE courses SET prerequisite_course_code = '40201261' WHERE course_id = 33;
UPDATE courses SET prerequisite_course_code = '40201220' WHERE course_id = 34;
UPDATE courses SET prerequisite_course_code = '40201290' WHERE course_id = 36;
UPDATE courses SET prerequisite_course_code = '40201360' WHERE course_id = 37;
UPDATE courses SET prerequisite_course_code = '40201201' WHERE course_id = 38;
UPDATE courses SET prerequisite_course_code = '10204282' WHERE course_id = 39;
UPDATE courses SET prerequisite_course_code = '10204282' WHERE course_id = 41;
UPDATE courses SET prerequisite_course_code = '40201341' WHERE course_id = 42;
UPDATE courses SET prerequisite_course_code = '40201491' WHERE course_id = 43;
UPDATE courses SET prerequisite_course_code = '10203180' WHERE course_id = 45;
UPDATE courses SET prerequisite_course_code = '10203180' WHERE course_id = 52;
UPDATE courses SET prerequisite_course_code = '40201260' WHERE course_id = 53;
UPDATE courses SET prerequisite_course_code = '40201360' WHERE course_id = 54;
UPDATE courses SET prerequisite_course_code = '40201362' WHERE course_id = 55;
UPDATE courses SET prerequisite_course_code = '40201341' WHERE course_id = 56;
UPDATE courses SET prerequisite_course_code = '30302231' WHERE course_id = 57;
UPDATE courses SET prerequisite_course_code = '30301124' WHERE course_id = 58;

-- ═══════════════════════════════════════════════════════════
-- STEP 3: Insert new courses from CSV (not in existing data)
-- ═══════════════════════════════════════════════════════════

INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (59, '10203210', 'Network Security', 3, '203280') ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (60, '10203280', 'Security', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (61, '10203300', 'Information Security Management', 3, '10203210') ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (62, '10203340', 'Cryptography', 3, '40303221') ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (63, '10203360', 'Penetration Testing', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (64, '10203361', 'Forensics', 3, '10203380') ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (65, '10203362', 'Ethical Hacking', 3, '10203210') ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (66, '10203470', 'Special Topics', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (67, '10203491', 'Capstone Project I', 1, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (68, '10203492', 'Capstone Project II', 2, '10203491') ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (69, '10204210', 'Data Analytics', 3, '30201100') ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (70, '10204310', 'Data Mining', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (71, '10204330', 'Modeling and Simulation', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (72, '10204350', 'Machine Learning', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (73, '10204351', 'Natural Language Processing', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (74, '10204412', 'Applied Analytical Models', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (75, '10204450', 'Deep Learning', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (76, '10204454', 'Optimization theory', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (77, '10204470', 'Special Topics', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (78, '10204491', 'Capstone project I', 1, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (79, '10204492', 'Capstone project II', 2, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (80, '201160', 'Creative Games Development', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (81, '201263', 'Advanced Scripting for Games', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (82, '201264', 'Immersive Technology Development', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (83, '201270', 'Special Topics in Game Development', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (84, '201290', 'Apprenticeship 1 for Game Design and Development', 6, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (85, '201293', 'Apprenticeship 2 for Game Design and Development', 6, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (86, '202291', 'Apprenticeship for Information Science 1', 6, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (87, '202292', 'Apprenticeship for Information Science 2', 6, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (88, '202392', 'Apprenticeship for Information Science 3', 6, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (89, '203290', 'Apprenticeship for Cybersecurity 1', 6, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (90, '203291', 'Apprenticeship for Cybersecurity 2', 6, '203290') ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (91, '203360', 'Penetration Testing', 3, '10203362') ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (92, '203391', 'Apprenticeship for Cybersecurity 3', 6, '203291') ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (93, '203400', 'Risk Analysis & Systems Testing', 3, '203280') ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (94, '203420', 'Secure Coding', 3, '10204282') ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (95, '203472', 'Special Topics in Cybersecurity 2', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (96, '204251', 'Fundamentals of Artificial Intelligence (AI) & Intelligent Systems', 3, '40303121') ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (97, '204280', 'Principles of Data Science and Computing Systems', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (98, '204290', 'Apprenticeship for DS & AI 1', 6, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (99, '204291', 'Apprenticeship for DS & AI 2', 6, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (100, '204311', 'Big Data Analytics and Visualization', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (101, '204391', 'Apprenticeship for DS & AI 3', 6, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (102, '204412', 'Applied Analytical Models', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (103, '204430', 'Data Mining', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (104, '204432', 'Bioinformatics', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (105, '30201392', 'On-Job Training Continuation', 0, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (106, '30201480', 'Advanced Computer Architecture', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (107, '30202432', 'Bioinformatics', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (108, '30202452', 'Internet of Things', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (109, '30301140', 'Foundational German Language', 1, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (110, '30301160', 'Turkish Language', 1, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (111, '30301170', 'Foundations of Italian ITAL', 1, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (112, '30301180', 'Chinese language', 1, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (113, '30301221', 'Development Academic Writing', 1, '30301124') ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (114, '30301224', 'Arabic Calligraphy', 1, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (115, '30302123', 'Art Appreciation and Techniques', 1, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (116, '30302125', 'Rights and Responsibilities: Understanding Human Rights', 1, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (117, '30302126', 'Introduction to Cultural Anthropology - Focus on Urban Anthropology', 1, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (118, '30302127', 'Jerusalem, History and Civilization', 1, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (119, '30302133', 'Principles of Management', 1, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (120, '30302134', 'Strategies for Industry Competitiveness: Tools & Techniques', 1, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (121, '30303112', 'Functional Physics', 3, NULL) ON CONFLICT (course_id) DO NOTHING;
INSERT INTO courses (course_id, code, name, credit_hours, prerequisite_course_code) OVERRIDING SYSTEM VALUE VALUES (122, '40201470', 'Special Topics', 3, NULL) ON CONFLICT (course_id) DO NOTHING;

-- ═══════════════════════════════════════════════════════════
-- STEP 4: Insert students
-- ═══════════════════════════════════════════════════════════

INSERT INTO students (student_id, name, email) VALUES (1, 'mohammad shenasiwer', '22110066@htu.edu.jo') ON CONFLICT (student_id) DO NOTHING;
INSERT INTO users (user_id, full_name, email, password_hash, role, student_number) OVERRIDING SYSTEM VALUE VALUES (1, 'mohammad shenasiwer', '22110066@htu.edu.jo', 'dummy', 'student', '22110066') ON CONFLICT (user_id) DO NOTHING;
INSERT INTO students (student_id, name, email) VALUES (2, 'Lina Khader', 'lina.khader@htu.edu.jo') ON CONFLICT (student_id) DO NOTHING;
INSERT INTO users (user_id, full_name, email, password_hash, role, student_number) OVERRIDING SYSTEM VALUE VALUES (2, 'Lina Khader', 'lina.khader@htu.edu.jo', 'dummy', 'student', 'lina.khader') ON CONFLICT (user_id) DO NOTHING;
INSERT INTO students (student_id, name, email) VALUES (3, 'Ahmad Nasser', 'ahmad.nasser@htu.edu.jo') ON CONFLICT (student_id) DO NOTHING;
INSERT INTO users (user_id, full_name, email, password_hash, role, student_number) OVERRIDING SYSTEM VALUE VALUES (3, 'Ahmad Nasser', 'ahmad.nasser@htu.edu.jo', 'dummy', 'student', 'ahmad.nasser') ON CONFLICT (user_id) DO NOTHING;
INSERT INTO students (student_id, name, email) VALUES (6, 'DAWOUD AL-NAJI', '22210019@htu.edu.jo') ON CONFLICT (student_id) DO NOTHING;
INSERT INTO users (user_id, full_name, email, password_hash, role, student_number) OVERRIDING SYSTEM VALUE VALUES (6, 'DAWOUD AL-NAJI', '22210019@htu.edu.jo', 'dummy', 'student', '22210019') ON CONFLICT (user_id) DO NOTHING;
INSERT INTO students (student_id, name, email) VALUES (7, 'MOHAMMED HABBOUB', '22120026@htu.edu.jo') ON CONFLICT (student_id) DO NOTHING;
INSERT INTO users (user_id, full_name, email, password_hash, role, student_number) OVERRIDING SYSTEM VALUE VALUES (7, 'MOHAMMED HABBOUB', '22120026@htu.edu.jo', 'dummy', 'student', '22120026') ON CONFLICT (user_id) DO NOTHING;
INSERT INTO students (student_id, name, email) VALUES (8, 'AYHAM ODEH', '22110260@htu.edu.jo') ON CONFLICT (student_id) DO NOTHING;
INSERT INTO users (user_id, full_name, email, password_hash, role, student_number) OVERRIDING SYSTEM VALUE VALUES (8, 'AYHAM ODEH', '22110260@htu.edu.jo', 'dummy', 'student', '22110260') ON CONFLICT (user_id) DO NOTHING;

-- Reset sequence
SELECT setval('students_student_id_seq', (SELECT COALESCE(MAX(student_id),0) FROM students));

-- ═══════════════════════════════════════════════════════════
-- STEP 5: Insert sections from CSV
-- Total sections: 377
-- ═══════════════════════════════════════════════════════════

INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (1, 14, '1', 'Malak Ziyad Mahmoud Fraihat', 'Sun/Wed 08:30-10:00 S-214', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (2, 14, '2', 'Malak Ziyad Mahmoud Fraihat', 'Sun/Wed 10:00-11:30 S-214', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (3, 14, '3', 'Mohammad Noor-Aldeen Badri Alkhateeb', 'Sun/Wed 13:00-14:30 S-212', 'Sun/Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (4, 14, '4', 'Suhaib Gazi Khattar Al-Obeidallah', 'Sun/Wed 14:30-16:00 S-212', 'Sun/Wed', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (5, 14, '5', 'Hana'' Zaid Abdul Karim Al Rashid', 'Mon/Thu 08:30-10:00 S-214', 'Mon/Thu', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (6, 14, '6', 'Lina Hammad', 'Mon/Thu 10:00-11:30 S-214', 'Mon/Thu', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (7, 14, '7', 'Lina Hammad', 'Mon/Thu 11:30-13:00 S-214', 'Mon/Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (8, 14, '8', 'Huthaifa Abdelhameed Ibrahim  Al Omari', 'Mon/Thu 13:00-14:30 S-214', 'Mon/Thu', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (9, 14, '9', 'Hikmat Yahia Hikmat Ahmad Shehadeh', 'Sat/Tue 08:30-10:00 S-214', 'Sat/Tue', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (10, 14, '10', 'Mo''tasem Khairi Mohammad Sammarah', 'Sat/Tue 10:00-11:30 S-214', 'Sat/Tue', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (11, 14, '11', 'Mo''tasem Khairi Mohammad Sammarah', 'Sat/Tue 11:30-13:00 S-214', 'Sat/Tue', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (12, 14, '12', 'Hikmat Yahia Hikmat Ahmad Shehadeh', 'Sat/Tue 13:00-14:30 S-214', 'Sat/Tue', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (13, 14, '13', 'Malak Ziyad Mahmoud Fraihat', 'Sat/Tue 10:00-11:30 S-212', 'Sat/Tue', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (14, 14, '14', 'Sawsan Al-Odibat', 'Mon/Thu 10:00-11:30 IJC-06', 'Mon/Thu', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (15, 80, '1', 'Nour Khrais', 'Sat 14:30-17:30 ** Blended 1 hours', 'Sat', '14:30:00', '17:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (16, 25, '1', 'Sultan Mahmoud Ahmad Alrushdan', 'Sun/Wed 08:30-10:00 S-210', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (17, 25, '2', 'Sultan Mahmoud Ahmad Alrushdan', 'Sun/Wed 13:00-14:30 S-210', 'Sun/Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (18, 25, '3', 'Malek Adnan Mohammad Al Louzi', 'Mon/Thu 08:30-10:00 S-208', 'Mon/Thu', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (19, 25, '4', 'Malek Adnan Mohammad Al Louzi', 'Mon/Thu 11:30-13:00 S-210', 'Mon/Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (20, 25, '6', 'Sultan Mahmoud Ahmad Alrushdan', 'Sat/Tue 11:30-13:00 S-210', 'Sat/Tue', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (21, 29, '1', 'Balqis Mohammad Khalaf Aldabaibeh', 'Sun/Wed 10:00-11:30 IJC-06', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (22, 29, '2', 'Ashraf Mohammad Saleem Al-Smadi', 'Sun/Wed 16:00-17:30 S-210', 'Sun/Wed', '16:00:00', '17:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (23, 29, '3', 'Balqis Mohammad Khalaf Aldabaibeh', 'Mon/Thu 10:00-11:30 S-210', 'Mon/Thu', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (24, 29, '4', 'Balqis Mohammad Khalaf Aldabaibeh', 'Mon/Thu 11:30-13:00 S-207', 'Mon/Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (25, 29, '5', 'Mo''tasem Khairi Mohammad Sammarah', 'Sat/Tue 08:30-10:00 S-212', 'Sat/Tue', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (26, 29, '7', 'Razan Atallah Mustafa Al Quran', 'Sun/Wed 13:00-14:30 W-B10', 'Sun/Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (27, 29, '8', 'Razan Atallah Mustafa Al Quran', 'Mon/Thu 14:30-16:00 S-214', 'Mon/Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (28, 19, '1', 'Ashwaq Raed Mashal Khalil', 'Sun/Wed 11:30-13:00 IJC-01', 'Sun/Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (29, 19, '2', 'Salem Ayed Hasan Alemaishat', 'Mon/Thu 13:00-14:30 S-208', 'Mon/Thu', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (30, 19, '3', 'Ashwaq Raed Mashal Khalil', 'Sat/Tue 08:30-10:00 S-208', 'Sat/Tue', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (31, 21, '3', 'Orwa Mohammad Khalaf Aladaileh', 'Mon/Thu 10:00-11:30 S-209', 'Mon/Thu', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (32, 21, '4', 'Asma Mohammad Ahmad Sabbah', 'Sat/Tue 13:00-14:30 S-209', 'Sat/Tue', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (33, 27, '1', 'Hana'' Zaid Abdul Karim Al Rashid', 'Sun/Wed 08:30-10:00 W-B07', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (34, 27, '2', 'Razan Atallah Mustafa Al Quran', 'Sun/Wed 14:30-16:00 IJC-02', 'Sun/Wed', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (35, 27, '3', 'Hana'' Zaid Abdul Karim Al Rashid', 'Mon/Thu 13:00-14:30 W-B07', 'Mon/Thu', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (36, 27, '4', 'Sawsan Al-Odibat', 'Mon/Thu 14:30-16:00 W-B07', 'Mon/Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (37, 27, '6', 'Ashwaq Raed Mashal Khalil', 'Sat/Tue 11:30-13:00 ** Blended 1 hours', 'Sat/Tue', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (38, 81, '1', 'Ali Hani Yasin Al-Shami', 'Thu 11:30-14:30 ** Blended 1 hours', 'Thu', '11:30:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (39, 82, '1', 'Dania Adnan Ismail Alsa`Id', 'Wed 14:30-17:30 ** Blended 1 hours', 'Wed', '14:30:00', '17:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (40, 83, '1', 'Dania Adnan Ismail Alsa`Id', 'Mon 14:30-17:30 ** Blended 1 hours', 'Mon', '14:30:00', '17:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (41, 84, '1', 'Mohammad Husni Najib Yahia', '/ ** Blended 6 hours', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (42, 30, '1', 'Balqis Mohammad Khalaf Aldabaibeh', 'Sun/Wed 11:30-13:00 S-210', 'Sun/Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (43, 30, '2', 'Nayef Mohammad Salameh Abu Aqeel', 'Sun/Wed 14:30-16:00 IJC-06', 'Sun/Wed', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (44, 30, '3', 'Rawaah Qoraan', 'Mon/Thu 08:30-10:00 S-207', 'Mon/Thu', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (45, 30, '4', 'Aseel Mousa Eshtaiwi Abuhaq', 'Mon/Thu 10:00-11:30 S-207', 'Mon/Thu', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (46, 30, '5', 'Nayef Mohammad Salameh Abu Aqeel', 'Sat/Tue 13:00-14:30 S-212', 'Sat/Tue', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (47, 47, '1', 'Mohammad Husni Najib Yahia', '/ ** Blended 6 hours', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (48, 48, '1', 'Mohammad Husni Najib Yahia', '/ ** Blended 6 hours', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (49, 85, '1', 'Mohammad Husni Najib Yahia', '/ ** Blended 6 hours', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (50, 37, '1', 'Mohammad Husni Najib Yahia', 'Sun/Wed 08:30-10:00 IJC-06', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (51, 37, '2', 'Salem Ayed Hasan Alemaishat', 'Sun/Wed 14:30-16:00 S-210', 'Sun/Wed', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (52, 37, '3', 'Salem Ayed Hasan Alemaishat', 'Mon/Thu 14:30-16:00 S-207', 'Mon/Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (53, 37, '4', 'Raghed Faisal Abdel Rahman Shahatit', 'Mon/Thu 13:00-14:30 IJC-01', 'Mon/Thu', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (54, 34, '1', 'Orwa Mohammad Khalaf Aladaileh', 'Sun/Wed 08:30-10:00 IJC-02', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (55, 34, '2', 'Ashaar Abdelwahab Daej Alkhamaiseh', 'Sun/Wed 11:30-13:00 S-209', 'Sun/Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (56, 34, '3', 'Ashaar Abdelwahab Daej Alkhamaiseh', 'Mon/Thu 10:00-11:30 W-B10', 'Mon/Thu', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (57, 34, '4', 'Orwa Mohammad Khalaf Aladaileh', 'Mon/Thu 08:30-10:00 S-210', 'Mon/Thu', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (58, 38, '1', 'Malek Adnan Mohammad Al Louzi', 'Sun/Wed 08:30-10:00 S-207', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (59, 38, '2', 'Elham Mahmoud Awad Derbas', 'Sun/Wed 13:00-14:30 IJC-02', 'Sun/Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (60, 38, '3', 'Elham Mahmoud Awad Derbas', 'Mon/Thu 08:30-10:00 S-209', 'Mon/Thu', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (61, 38, '4', 'Nayef Mohammad Salameh Abu Aqeel', 'Sat/Tue 11:30-13:00 S-212', 'Sat/Tue', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (62, 38, '5', 'Sultan Mahmoud Ahmad Alrushdan', 'Sat/Tue 10:00-11:30 S-208', 'Sat/Tue', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (63, 32, '1', 'Dania Adnan Ismail Alsa`Id', 'Sun 14:30-17:30 ** Blended 1 hours', 'Sun', '14:30:00', '17:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (64, 32, '2', 'Dania Adnan Ismail Alsa`Id', 'Mon 11:30-14:30 ** Blended 1 hours', 'Mon', '11:30:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (65, 32, '3', 'Dania Adnan Ismail Alsa`Id', 'Tue 14:30-17:30 ** Blended 1 hours', 'Tue', '14:30:00', '17:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (66, 36, '1', 'Islam Yaser Abelqader Alomari', 'Wed 13:00-14:30 ONLINE ONLINE', 'Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (67, 36, '2', 'Nayef Mohammad Salameh Abu Aqeel', 'Sun 13:00-14:30 ONLINE ONLINE', 'Sun', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (68, 36, '3', 'Samir Yacoub Mufid Tartir', 'Thu 10:00-11:30 ONLINE ONLINE', 'Thu', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (69, 36, '4', 'Islam Yaser Abelqader Alomari', 'Mon 10:00-11:30 ONLINE ONLINE', 'Mon', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (70, 36, '5', 'Fadia Sami Nu`man Ala`eddin', 'Tue 10:00-11:30 IJC-01', 'Tue', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (71, 36, '6', 'Fadia Sami Nu`man Ala`eddin', 'Sat 13:00-14:30 ONLINE ONLINE', 'Sat', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (72, 36, '7', 'Rawaah Qoraan', 'Thu 14:30-16:00 ONLINE ONLINE', 'Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (73, 36, '8', 'Asmaa Shukry Yousef Lafi', 'Mon 14:30-16:00 ONLINE ONLINE', 'Mon', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (74, 49, '1', 'Mohammad Husni Najib Yahia', '/ ** Blended 6 hours', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (75, 105, '1', 'Ala''a Saqer Ahmad Al-Habashna', '/', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (76, 41, '1', 'Samir Yacoub Mufid Tartir', 'Sun/Wed 14:30-16:00 S-214', 'Sun/Wed', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (77, 41, '2', 'Samir Yacoub Mufid Tartir', 'Mon/Thu 14:30-16:00 S-210', 'Mon/Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (78, 42, '1', 'Sultan Mahmoud Ahmad Alrushdan', 'Sun/Wed 10:00-11:30 S-207', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (79, 42, '2', 'Samer Adnan Abdullah Suleiman', 'Sat/Tue 10:00-11:30 S-207', 'Sat/Tue', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (80, 42, '3', 'Samer Adnan Abdullah Suleiman', 'Sun/Wed 11:30-13:00 IJC-06', 'Sun/Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (81, 45, '1', NULL, 'Sun/Wed 16:00-17:30 S-212', 'Sun/Wed', '16:00:00', '17:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (82, 45, '2', 'Ibrahim Abed Alfattah Mohammad Ghanem', 'Sat/Tue 14:30-16:00 S-212', 'Sat/Tue', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (83, 52, '1', 'Yazan Abdelrazzak Mohammad Alshannik', 'Sun/Wed 14:30-16:00 W-B07', 'Sun/Wed', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (84, 52, '2', 'Yazan Abdelrazzak Mohammad Alshannik', 'Mon/Thu 14:30-16:00 IJC-02', 'Mon/Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (85, 122, '1', 'Elham Mahmoud Awad Derbas', 'Sun/Wed 10:00-11:30 S-210', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (86, 122, '2', 'Dania Adnan Ismail Alsa`Id', 'Wed 14:30-17:30 ** Blended 1 hours', 'Wed', '14:30:00', '17:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (87, 35, '1', 'Razan Atallah Mustafa Al Quran', 'Mon/Thu 13:00-14:30 IJC-02', 'Mon/Thu', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (88, 50, '1', 'Orwa Mohammad Khalaf Aladaileh', 'Sun/Wed 11:30-13:00 W-B10', 'Sun/Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (89, 106, '1', 'Reem Moshrif Mohammad Bani Hani', 'Sun/Wed 14:30-16:00 S-208', 'Sun/Wed', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (90, 106, '2', 'Huthaifa Abdelhameed Ibrahim  Al Omari', 'Mon/Thu 14:30-16:00 S-212', 'Mon/Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (91, 106, '3', 'Huthaifa Abdelhameed Ibrahim  Al Omari', 'Mon/Thu 16:00-17:30 S-212', 'Mon/Thu', '16:00:00', '17:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (92, 40, '1', 'Mohammad Husni Najib Yahia', '/', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (93, 43, '1', 'Mohammad Husni Najib Yahia', '/', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (94, 86, '1', 'Ala''a Saqer Ahmad Al-Habashna', '/ ** Blended 6 hours', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (95, 87, '1', 'Ala''a Saqer Ahmad Al-Habashna', '/ ** Blended 6 hours', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (96, 88, '1', 'Ala''a Saqer Ahmad Al-Habashna', '/ ** Blended 6 hours', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (97, 107, '1', 'Rami Ratib Musa Al-Ouran', 'Sat/Tue 08:30-10:00 S-210', 'Sat/Tue', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (98, 108, '1', NULL, 'Sun/Wed 16:00-17:30 S-212', 'Sun/Wed', '16:00:00', '17:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (99, 108, '2', NULL, 'Sat/Tue 14:30-16:00 ** Blended 1 hours', 'Sat/Tue', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (100, 13, '1', 'Asmaa Shukry Yousef Lafi', 'Sun/Wed 08:30-10:00 W-B10', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (101, 13, '2', 'Asmaa Shukry Yousef Lafi', 'Sun/Wed 10:00-11:30 W-B10', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (102, 13, '3', 'Isra'' Ibrahim Ismael Hasan', 'Sun/Wed 11:30-13:00 S-214', 'Sun/Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (103, 13, '4', 'Isra'' Ibrahim Ismael Hasan', 'Sun/Wed 13:00-14:30 S-214', 'Sun/Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (104, 13, '5', 'Ashaar Abdelwahab Daej Alkhamaiseh', 'Sun/Wed 14:30-16:00 W-B10', 'Sun/Wed', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (105, 13, '6', 'Weaam Akram Soud Alrbeiqi', 'Mon/Thu 08:30-10:00 W-B07', 'Mon/Thu', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (106, 13, '7', 'Weaam Akram Soud Alrbeiqi', 'Mon/Thu 10:00-11:30 W-B07', 'Mon/Thu', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (107, 13, '8', 'Sami Aqeel Murshed Almashaqbeh', 'Mon/Thu 11:30-13:00 W-B10', 'Mon/Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (108, 13, '9', 'Asmaa Shukry Yousef Lafi', 'Mon/Thu 13:00-14:30 W-B10', 'Mon/Thu', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (109, 13, '10', 'Hazem Khaled Radwan Arabiyat', 'Sat/Tue 11:30-13:00 S-208', 'Sat/Tue', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (110, 13, '11', 'Hazem Khaled Radwan Arabiyat', 'Sat/Tue 13:00-14:30 S-208', 'Sat/Tue', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (111, 13, '12', 'Hazem Khaled Radwan Arabiyat', 'Sat/Tue 14:30-16:00 S-208', 'Sat/Tue', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (112, 13, '13', 'Eyad Salah Abdul Hamid Taqieddin', 'Sat/Tue 11:30-13:00 S-209', 'Sat/Tue', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (113, 13, '14', 'Weaam Akram Soud Alrbeiqi', 'Mon/Thu 14:30-16:00 W-B10', 'Mon/Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (114, 13, '15', NULL, 'Sat/Tue 10:00-11:30 W-B07', 'Sat/Tue', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (115, 59, '1', 'Elham Mahmoud Awad Derbas', 'Mon/Thu 10:00-11:30 IJC-02', 'Mon/Thu', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (116, 59, '2', 'Eyad Salah Abdul Hamid Taqieddin', 'Sat/Tue 10:00-11:30 S-209', 'Sat/Tue', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (117, 20, '1', 'Hazem Khaled Radwan Arabiyat', 'Sun/Wed 11:30-13:00 S-212', 'Sun/Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (118, 20, '2', 'Hazem Khaled Radwan Arabiyat', 'Sun/Wed 13:00-14:30 S-208', 'Sun/Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (119, 20, '3', 'Asmaa Shukry Yousef Lafi', 'Mon/Thu 08:30-10:00 W-B10', 'Mon/Thu', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (120, 20, '4', 'Ashaar Abdelwahab Daej Alkhamaiseh', 'Mon/Thu 11:30-13:00 W-B07', 'Mon/Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (121, 20, '5', 'Isra'' Ibrahim Ismael Hasan', 'Sat/Tue 11:30-13:00 IJC-01', 'Sat/Tue', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (122, 20, '6', 'Isra'' Ibrahim Ismael Hasan', 'Sat/Tue 13:00-14:30 IJC-01', 'Sat/Tue', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (123, 60, '1', 'Ashaar Abdelwahab Daej Alkhamaiseh', 'Mon/Thu 11:30-13:00 W-B07', 'Mon/Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (124, 89, '1', 'Safaa Fawzey Mohammad Hriez', '/ ** Blended 6 hours', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (125, 90, '1', 'Safaa Fawzey Mohammad Hriez', '/ ** Blended 6 hours', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (126, 61, '1', 'Qutaiba Salameh Mohmad Al Harfi Albluwi', 'Mon/Thu 08:30-10:00 S-212', 'Mon/Thu', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (127, 62, '1', 'Rawaah Qoraan', 'Mon/Thu 11:30-13:00 IJC-02', 'Mon/Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (128, 91, '1', NULL, 'Sun/Wed 08:30-10:00 S-212', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (129, 91, '3', 'Sami Aqeel Murshed Almashaqbeh', 'Mon/Thu 08:30-10:00 IJC-02', 'Mon/Thu', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (130, 63, '1', 'Weaam Akram Soud Alrbeiqi', 'Sun/Wed 08:30-10:00 S-212', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (131, 64, '1', 'Safaa Fawzey Mohammad Hriez', 'Sun/Wed 11:30-13:00 W-B07', 'Sun/Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (132, 64, '2', 'Safaa Fawzey Mohammad Hriez', 'Mon/Thu 11:30-13:00 S-209', 'Mon/Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (133, 65, '1', 'Sami Aqeel Murshed Almashaqbeh', 'Sun/Wed 13:00-14:30 S-209', 'Sun/Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (134, 28, '1', 'Reem Moshrif Mohammad Bani Hani', 'Sun/Wed 14:30-16:00 S-208', 'Sun/Wed', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (135, 28, '2', 'Huthaifa Abdelhameed Ibrahim  Al Omari', 'Mon/Thu 14:30-16:00 S-212', 'Mon/Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (136, 28, '3', 'Huthaifa Abdelhameed Ibrahim  Al Omari', 'Mon/Thu 16:00-17:30 S-212', 'Mon/Thu', '16:00:00', '17:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (137, 92, '1', 'Safaa Fawzey Mohammad Hriez', '/ ** Blended 6 hours', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (138, 93, '1', 'Ibrahim Abed Alfattah Mohammad Ghanem', 'Sun/Wed 13:00-14:30 W-B07', 'Sun/Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (139, 93, '2', 'Ibrahim Abed Alfattah Mohammad Ghanem', 'Sat/Tue 11:30-13:00 IJC-02', 'Sat/Tue', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (140, 94, '1', 'Safaa Fawzey Mohammad Hriez', 'Mon/Thu 13:00-14:30 S-210', 'Mon/Thu', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (141, 66, '1', 'Murad Almunther Ikrema Yaghi', 'Sun/Wed 16:00-17:30 S-212', 'Sun/Wed', '16:00:00', '17:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (142, 66, '2', NULL, 'Sat/Tue 14:30-16:00 S-212', 'Sat/Tue', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (143, 95, '1', 'Elham Mahmoud Awad Derbas', 'Sun/Wed 10:00-11:30 S-210', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (144, 67, '1', 'Safaa Fawzey Mohammad Hriez', '/', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (145, 68, '1', 'Safaa Fawzey Mohammad Hriez', '/', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (146, 69, '1', 'Yousef Darwish', 'Sun/Wed 13:00-14:30 S-207', 'Sun/Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (147, 69, '2', 'Yara Emad Abdelghafour Alharahsheh', 'Mon/Thu 14:30-16:00 S-209', 'Mon/Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (148, 69, '3', 'Bassam Faris Abdel Hamed Al Kasasbeh', 'Sat/Tue 13:00-14:30 S-210', 'Sat/Tue', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (149, 69, '4', 'Yousef Darwish', 'Sun 16:00-17:30 S-207', 'Sun', '16:00:00', '17:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (150, 44, '1', 'Rami Ratib Musa Al-Ouran', 'Sat/Tue 10:00-11:30 IJC-02', 'Sat/Tue', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (151, 44, '2', 'Mariam Mohammad Yahya Biltawi', 'Sun/Wed 11:30-13:00 S-207', 'Sun/Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (152, 44, '3', 'Mariam Mohammad Yahya Biltawi', 'Sun/Wed 10:00-11:30 S-209', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (153, 44, '4', 'Batool Nayef Mohammad Alarmouti', 'Sat/Tue 08:30-10:00 W-B07', 'Sat/Tue', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (154, 44, '5', NULL, 'Mon/Thu 11:30-13:00 IJC-06', 'Mon/Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (155, 96, '1', 'Mariam Mohammad Yahya Biltawi', 'Sun/Wed 10:00-11:30 S-209', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (156, 96, '2', NULL, 'Sun/Wed 11:30-13:00 S-207', 'Sun/Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (157, 96, '3', 'Batool Nayef Mohammad Alarmouti', 'Mon/Thu 11:30-13:00 IJC-01', 'Mon/Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (158, 96, '4', NULL, 'Sat/Tue 10:00-11:30 IJC-02', 'Sat/Tue', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (159, 96, '5', 'Batool Nayef Mohammad Alarmouti', 'Sat/Tue 08:30-10:00 W-B07', 'Sat/Tue', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (160, 96, '6', 'Mariam Mohammad Yahya Biltawi', 'Mon/Thu 11:30-13:00 IJC-06', 'Mon/Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (161, 97, '1', 'Bushra Soud Ali Al-Zeirah', 'Sun/Wed 10:00-11:30 S-212', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (162, 23, '1', 'Mohammad Husni Najib Yahia', 'Sun/Wed 10:00-11:30 W-B07', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (163, 23, '2', 'Samir Yacoub Mufid Tartir', 'Mon/Thu 13:00-14:30 S-212', 'Mon/Thu', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (164, 23, '3', 'Samer Adnan Abdullah Suleiman', 'Sat/Tue 11:30-13:00 S-207', 'Sat/Tue', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (165, 98, '1', 'Ala''a Saqer Ahmad Al-Habashna', '/ ** Blended 6 hours', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (166, 99, '1', 'Ala''a Saqer Ahmad Al-Habashna', '/ ** Blended 6 hours', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (167, 70, '1', NULL, 'Sat/Tue 10:00-11:30 W-B10', 'Sat/Tue', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (168, 70, '2', 'Bassam Faris Abdel Hamed Al Kasasbeh', 'Sun/Wed 13:00-14:30 IJC-01', 'Sun/Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (169, 100, '1', 'Ayah Basim Ramadan Karajeh', 'Sun/Wed 11:30-13:00 IJC-02', 'Sun/Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (170, 100, '2', 'Ayah Basim Ramadan Karajeh', 'Sat/Tue 13:00-14:30 S-207', 'Sat/Tue', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (171, 100, '3', 'Ayah Basim Ramadan Karajeh', 'Sun/Wed 08:30-10:00 S-209', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (172, 31, '1', 'Asma Mahmoud Mohammad Al-Fakhore', 'Mon/Thu 14:30-16:00 IJC-06', 'Mon/Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (173, 39, '1', 'Yara Emad Abdelghafour Alharahsheh', 'Sun/Wed 08:30-10:00 S-208', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (174, 39, '2', 'Islam Yaser Abelqader Alomari', 'Sun/Wed 11:30-13:00 S-208', 'Sun/Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (175, 39, '3', 'Batool Nayef Mohammad Alarmouti', 'Mon/Thu 10:00-11:30 S-208', 'Mon/Thu', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (176, 39, '4', 'Yara Emad Abdelghafour Alharahsheh', 'Mon/Thu 11:30-13:00 S-208', 'Mon/Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (177, 39, '5', 'Islam Yaser Abelqader Alomari', 'Mon/Thu 13:00-14:30 S-207', 'Mon/Thu', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (178, 39, '6', 'Malak Ziyad Mahmoud Fraihat', 'Sat/Tue 08:30-10:00 S-207', 'Sat/Tue', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (179, 39, '7', 'Batool Nayef Mohammad Alarmouti', 'Sat/Tue 11:30-13:00 W-B07', 'Sat/Tue', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (180, 71, '1', 'Murad Almunther Ikrema Yaghi', 'Sun/Wed 14:30-16:00 S-207', 'Sun/Wed', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (181, 71, '2', 'Murad Almunther Ikrema Yaghi', 'Sat/Tue 13:00-14:30 IJC-06', 'Sat/Tue', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (182, 72, '1', 'Rami Ratib Musa Al-Ouran', 'Sun/Wed 10:00-11:30 IJC-02', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (183, 73, '1', 'Raneem Nadim Mohamed Qaddoura', 'Sun/Wed 14:30-16:00 S-209', 'Sun/Wed', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (184, 73, '2', 'Raneem Nadim Mohamed Qaddoura', 'Mon/Thu 13:00-14:30 S-209', 'Mon/Thu', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (185, 73, '3', 'Yara Emad Abdelghafour Alharahsheh', 'Sun/Wed 13:00-14:30 IJC-06', 'Sun/Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (186, 101, '1', 'Ala''a Saqer Ahmad Al-Habashna', '/ ** Blended 6 hours', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (187, 102, '1', 'Bassam Faris Abdel Hamed Al Kasasbeh', 'Sat/Tue 11:30-13:00 IJC-06', 'Sat/Tue', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (188, 74, '1', 'Bassam Faris Abdel Hamed Al Kasasbeh', 'Sat/Tue 11:30-13:00 IJC-06', 'Sat/Tue', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (189, 103, '1', 'Bassam Faris Abdel Hamed Al Kasasbeh', 'Sun/Wed 13:00-14:30 IJC-01', 'Sun/Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (190, 103, '2', 'Bassam Faris Abdel Hamed Al Kasasbeh', 'Sat/Tue 10:00-11:30 W-B10', 'Sat/Tue', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (191, 104, '1', 'Rami Ratib Musa Al-Ouran', 'Sat/Tue 08:30-10:00 S-210', 'Sat/Tue', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (192, 75, '1', 'Ayah Basim Ramadan Karajeh', 'Sun/Wed 10:00-11:30 S-208', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (193, 75, '2', 'Ala''a Saqer Ahmad Al-Habashna', 'Mon/Thu 10:00-11:30 S-212', 'Mon/Thu', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (194, 75, '3', 'Ala''a Saqer Ahmad Al-Habashna', 'Mon/Thu 11:30-13:00 S-212', 'Mon/Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (195, 75, '4', 'Ayah Basim Ramadan Karajeh', 'Sat/Tue 11:30-13:00 W-B10', 'Sat/Tue', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (196, 76, '1', 'Raneem Nadim Mohamed Qaddoura', 'Mon/Thu 16:00-17:30 S-209', 'Mon/Thu', '16:00:00', '17:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (197, 77, '1', NULL, 'Sun/Wed 16:00-17:30 S-212', 'Sun/Wed', '16:00:00', '17:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (198, 77, '2', NULL, 'Sat/Tue 14:30-16:00 S-212', 'Sat/Tue', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (199, 78, '1', 'Ala''a Saqer Ahmad Al-Habashna', '/', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (200, 79, '1', 'Ala''a Saqer Ahmad Al-Habashna', '/', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (201, 1, '1', 'Nizar Jebril Ibrahim Alseoudi', 'Sun/Wed 14:30-16:00 W105', 'Sun/Wed', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (202, 1, '2', 'Haneen Ibraheem Bajes Maali', 'Mon/Thu 14:30-16:00 W105', 'Mon/Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (203, 9, '1', 'Haneen Ibraheem Bajes Maali', 'Sun 10:00-11:30 W-216', 'Sun', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (204, 9, '2', 'Haneen Ibraheem Bajes Maali', 'Wed 10:00-11:30 W-216', 'Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (205, 9, '5', 'Haneen Ibraheem Bajes Maali', 'Sun 13:00-14:30 W-216', 'Sun', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (206, 9, '6', 'Salah Aldin Ahmad Mousa Darawsheh', 'Wed 13:00-14:30 W-216', 'Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (207, 9, '8', 'Salah Aldin Ahmad Mousa Darawsheh', 'Thu 14:30-16:00 W-108', 'Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (208, 9, '9', 'Haneen Ibraheem Bajes Maali', 'Mon 10:00-11:30 W-216', 'Mon', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (209, 9, '10', 'Haneen Ibraheem Bajes Maali', 'Thu 11:30-13:00 W-216', 'Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (210, 9, '11', 'Nizar Jebril Ibrahim Alseoudi', 'Mon 14:30-16:00 W-216', 'Mon', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (211, 9, '12', 'Nizar Jebril Ibrahim Alseoudi', 'Thu 14:30-16:00 W-216', 'Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (212, 9, '13', 'Haneen Ibraheem Bajes Maali', 'Mon 13:00-14:30 W-216', 'Mon', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (213, 9, '15', 'Salah Aldin Ahmad Mousa Darawsheh', 'Sat 14:30-16:00 W-108', 'Sat', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (214, 9, '16', 'Salah Aldin Ahmad Mousa Darawsheh', 'Tue 14:30-16:00 W-108', 'Tue', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (215, 11, '1', 'Suha Fawzi Dawood Abdo', 'Sun/Wed 10:00-11:30 W-121', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (216, 11, '3', 'Ohood Ali Mohammad Saif Al Nakeeb', 'Sun/Wed 11:30-13:00 W105', 'Sun/Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (217, 11, '6', 'Hala Khaled Atallah Arar', 'Sat/Tue 10:00-11:30 W105', 'Sat/Tue', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (218, 11, '7', 'Laila Abdellilah Mahmoud Alswais', 'Sun/Wed 08:30-10:00 W-203', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (219, 11, '8', 'Iyad Abdel Raouf Khamees Khateeb', 'Mon/Thu 11:30-13:00 W105', 'Mon/Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (220, 11, '9', 'Laila Abdellilah Mahmoud Alswais', 'Mon/Thu 11:30-13:00 W109', 'Mon/Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (221, 18, '1', 'Iyad Abdel Raouf Khamees Khateeb', 'Sun/Wed 08:30-10:00 W-108', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (222, 18, '2', 'Hala Khaled Atallah Arar', 'Sun/Wed 10:00-11:30 W-108', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (223, 18, '3', 'Iyad Abdel Raouf Khamees Khateeb', 'Sun/Wed 11:30-13:00 W-108', 'Sun/Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (224, 18, '4', 'Hala Khaled Atallah Arar', 'Sun/Wed 13:00-14:30 W-108', 'Sun/Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (225, 18, '5', 'Ohood Ali Mohammad Saif Al Nakeeb', 'Sun/Wed 14:30-16:00 W-108', 'Sun/Wed', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (226, 18, '6', 'Iyad Abdel Raouf Khamees Khateeb', 'Mon/Thu 08:30-10:00 W-108', 'Mon/Thu', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (227, 18, '7', 'Iyad Abdel Raouf Khamees Khateeb', 'Mon/Thu 13:00-14:30 W-108', 'Mon/Thu', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (228, 18, '8', 'Ohood Ali Mohammad Saif Al Nakeeb', 'Mon/Thu 11:30-13:00 W-108', 'Mon/Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (229, 18, '10', 'Hala Khaled Atallah Arar', 'Sat/Tue 13:00-14:30 W105', 'Sat/Tue', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (230, 18, '11', 'Ohood Ali Mohammad Saif Al Nakeeb', 'Mon/Thu 13:00-14:30 ** Blended 1 hours', 'Mon/Thu', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (231, 24, '1', 'Christina Abdel Karim Hafez Zawati', 'Sun/Wed 08:30-10:00 W109', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (232, 24, '2', 'Laila Abdellilah Mahmoud Alswais', 'Sun/Wed 10:00-11:30 W109', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (233, 24, '3', 'Rose Richard Henry Al Hawamdeh', 'Sun/Wed 11:30-13:00 W109', 'Sun/Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (234, 24, '4', 'Laila Abdellilah Mahmoud Alswais', 'Sun/Wed 13:00-14:30 W109', 'Sun/Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (235, 24, '5', 'Rose Richard Henry Al Hawamdeh', 'Sun/Wed 14:30-16:00 W-121', 'Sun/Wed', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (236, 24, '6', 'Christina Abdel Karim Hafez Zawati', 'Mon/Thu 08:30-10:00 W109', 'Mon/Thu', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (237, 24, '7', 'Christina Abdel Karim Hafez Zawati', 'Mon/Thu 10:00-11:30 W109', 'Mon/Thu', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (238, 24, '9', 'Christina Abdel Karim Hafez Zawati', 'Mon/Thu 13:00-14:30 W109', 'Mon/Thu', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (239, 24, '10', 'Rose Richard Henry Al Hawamdeh', 'Mon/Thu 14:30-16:00 W-121', 'Mon/Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (240, 24, '13', 'Laila Abdellilah Mahmoud Alswais', 'Mon/Thu 14:30-16:00 W-203', 'Mon/Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (241, 24, '14', 'Christina Abdel Karim Hafez Zawati', 'Sun/Wed 11:30-13:00 W-203', 'Sun/Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (242, 16, '1', 'Rana Nizar Jassim Alameen', 'Sun/Wed 10:00-11:30 W-215', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (243, 16, '2', 'Rana Nizar Jassim Alameen', 'Sun/Wed 13:00-14:30 W105', 'Sun/Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (244, 16, '3', 'Rana Nizar Jassim Alameen', 'Mon/Thu 10:00-11:30 W105', 'Mon/Thu', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (245, 16, '5', 'Rana Nizar Jassim Alameen', 'Mon/Thu 08:30-10:00 W105', 'Mon/Thu', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (246, 109, '1', 'Omar Aldeies', 'Sat/Tue 13:00-14:30 W-108', 'Sat/Tue', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (247, 110, '1', NULL, 'Sat/Tue 10:00-11:30 W-103', 'Sat/Tue', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (248, 110, '2', NULL, 'Sat/Tue 11:30-13:00 W105', 'Sat/Tue', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (249, 111, '1', NULL, 'Sun/Wed 11:30-13:00 W-216', 'Sun/Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (250, 112, '1', NULL, 'Sun/Wed 10:00-11:30 W105', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (251, 113, '1', NULL, 'Sun/Wed 08:30-10:00 W-203', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (252, 113, '2', NULL, 'Sun/Wed 08:30-10:00 W-215', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (253, 113, '3', NULL, 'Sun/Wed 14:30-16:00 W-203', 'Sun/Wed', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (254, 113, '4', NULL, 'Sun/Wed 14:30-16:00 W-103', 'Sun/Wed', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (255, 113, '20', NULL, 'Sun/Wed 08:30-10:00 W-103', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (256, 113, '21', NULL, 'Sun/Wed 08:30-10:00 W-216', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (257, 113, '22', NULL, 'Mon/Thu 08:30-10:00 W-001', 'Mon/Thu', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (258, 113, '23', NULL, 'Mon/Thu 10:00-11:30 W-001', 'Mon/Thu', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (259, 113, '24', NULL, 'Mon/Thu 11:30-13:00 W-001', 'Mon/Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (260, 113, '25', NULL, 'Mon/Thu 14:30-16:00 W-001', 'Mon/Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (261, 113, '26', NULL, 'Mon/Thu 14:30-16:00 W-103', 'Mon/Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (262, 113, '27', NULL, 'Mon/Thu 11:30-13:00 W-203', 'Mon/Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (263, 113, '28', NULL, 'Mon/Thu 14:30-16:00 W-215', 'Mon/Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (264, 113, '29', NULL, 'Mon/Thu 08:30-10:00 W-215', 'Mon/Thu', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (265, 113, '31', NULL, 'Sun/Wed 10:00-11:30 W-202', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (266, 113, '32', NULL, 'Wed 13:00-14:30 W-121', 'Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (267, 113, '33', NULL, 'Sun/Wed 11:30-13:00 W-202', 'Sun/Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (268, 113, '34', NULL, 'Sat/Tue 08:30-10:00 W-203', 'Sat/Tue', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (269, 113, '35', NULL, 'Sat/Tue 10:00-11:30 W-203', 'Sat/Tue', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (270, 113, '36', NULL, 'Sat/Tue 11:30-13:00 W-203', 'Sat/Tue', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (271, 113, '37', NULL, 'Sat/Tue 13:00-14:30 W-203', 'Sat/Tue', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (272, 113, '38', NULL, 'Sat/Tue 14:30-16:00 W-203', 'Sat/Tue', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (273, 113, '39', NULL, 'Sat/Tue 10:00-11:30 W-215', 'Sat/Tue', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (274, 113, '40', NULL, 'Sat/Tue 11:30-13:00 W-215', 'Sat/Tue', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (275, 113, '41', NULL, 'Sat/Tue 13:00-14:30 W-215', 'Sat/Tue', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (276, 113, '42', NULL, 'Sun/Wed 13:00-14:30 W-202', 'Sun/Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (277, 113, '43', NULL, 'Sun 14:30-16:00 W-102', 'Sun', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (278, 113, '44', NULL, 'Sun/Wed 13:00-14:30 W-203', 'Sun/Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (279, 113, '45', NULL, 'Mon/Thu 14:30-16:00 W109', 'Mon/Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (280, 113, '46', NULL, 'Mon/Thu 10:00-11:30 W-108', 'Mon/Thu', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (281, 113, '47', NULL, 'Mon/Thu 13:00-14:30 W105', 'Mon/Thu', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (282, 113, '48', NULL, 'Sun/Wed 14:30-16:00 W-215', 'Sun/Wed', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (283, 113, '49', NULL, 'Mon/Thu 13:00-14:30 W-202', 'Mon/Thu', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (284, 113, '50', NULL, 'Mon 14:30-16:00 W-108', 'Mon', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (285, 58, '1', 'Suha Fawzi Dawood Abdo', 'Sun/Wed 13:00-14:30 W-215', 'Sun/Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (286, 58, '2', 'Suha Fawzi Dawood Abdo', 'Mon/Thu 10:00-11:30 W-215', 'Mon/Thu', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (287, 58, '3', 'Suha Fawzi Dawood Abdo', 'Mon/Thu 13:00-14:30 W-215', 'Mon/Thu', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (288, 114, '1', 'Nizar Jebril Ibrahim Alseoudi', 'Sun 11:30-13:00 W-215', 'Sun', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (289, 114, '2', 'Nizar Jebril Ibrahim Alseoudi', 'Mon 11:30-13:00 W-215', 'Mon', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (290, 114, '3', 'Nizar Jebril Ibrahim Alseoudi', 'Wed 11:30-13:00 W-215', 'Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (291, 114, '4', 'Nizar Jebril Ibrahim Alseoudi', 'Thu 11:30-13:00 W-215', 'Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (292, 8, '1', 'Sawsan Osama Abdel Hamid Sayeh', 'Sun/Wed 08:30-10:00 W-102', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (293, 8, '2', 'Sawsan Osama Abdel Hamid Sayeh', 'Sun/Wed 11:30-13:00 W-102', 'Sun/Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (294, 8, '3', 'Sawsan Osama Abdel Hamid Sayeh', 'Mon/Thu 13:00-14:30 W-102', 'Mon/Thu', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (295, 8, '4', 'Asma''a Abdel-Karim Azmi Al Kayalli', 'Sun/Wed 13:00-14:30 W-001', 'Sun/Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (296, 8, '5', 'Asma''a Abdel-Karim Azmi Al Kayalli', 'Mon/Thu 14:30-16:00 W-102', 'Mon/Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (297, 8, '6', 'Gida Abdelhamid Abdelwahab Hamam', 'Sun/Wed 10:00-11:30 W-102', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (298, 8, '7', 'Gida Abdelhamid Abdelwahab Hamam', 'Sun/Wed 14:30-16:00 W-001', 'Sun/Wed', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (299, 8, '8', 'Gida Abdelhamid Abdelwahab Hamam', 'Mon/Thu 10:00-11:30 W-102', 'Mon/Thu', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (300, 8, '9', 'Fayzeh Zeyad Mohammad Abuhaltam', 'Mon/Thu 11:30-13:00 W-102', 'Mon/Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (301, 8, '10', 'Fayzeh Zeyad Mohammad Abuhaltam', 'Sun/Wed 13:00-14:30 W-102', 'Sun/Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (302, 8, '11', 'Elham Alzyadat', 'Sat/Tue 11:30-13:00 W-102', 'Sat/Tue', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (303, 8, '12', 'Areej Ibrahim Hussein Abuqudairi', 'Sat/Tue 13:00-14:30 W-102', 'Sat/Tue', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (304, 115, '1', 'Gida Abdelhamid Abdelwahab Hamam', 'Mon/Thu 13:00-14:30 W-203', 'Mon/Thu', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (305, 116, '1', 'Areej Ibrahim Hussein Abuqudairi', 'Mon/Thu 13:00-14:30 W-121', 'Mon/Thu', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (306, 117, '1', 'Gida Abdelhamid Abdelwahab Hamam', 'Sun/Wed 11:30-13:00 W-001', 'Sun/Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (307, 118, '1', 'Bassam Abdulsalam Hamideh Butoush', 'Sun/Wed 10:00-11:30 W-203', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (308, 10, '1', 'Military Science 1', '/ ** Blended 1 hours', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (309, 10, '2', 'Military Science 1', '/ ** Blended 1 hours', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (310, 119, '1', 'Noura Tariq Borhan Al-Nashef', 'Mon/Thu 13:00-14:30 W-001', 'Mon/Thu', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (311, 120, '1', 'Tala Sulaiman Mfleh Arabiat', 'Tue 11:30-14:30 W-103', 'Tue', '11:30:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (312, 15, '1', 'Noura Tariq Borhan Al-Nashef', 'Sun/Wed 10:30-12:30 W-103', 'Sun/Wed', '10:30:00', '12:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (313, 15, '2', 'Noura Tariq Borhan Al-Nashef', 'Mon/Thu 08:30-10:30 W-103', 'Mon/Thu', '08:30:00', '10:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (314, 15, '3', 'Reem Ali Hassan Abu Lughod', 'Sun/Wed 12:30-14:30 W-103', 'Sun/Wed', '12:30:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (315, 15, '4', 'Reem Ali Hassan Abu Lughod', 'Sat/Tue 12:30-14:30 W-121', 'Sat/Tue', '12:30:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (316, 15, '5', 'Reem Ali Hassan Abu Lughod', 'Mon/Thu 11:30-13:30 W-103', 'Mon/Thu', '11:30:00', '13:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (317, 15, '7', 'Areej Ibrahim Hussein Abuqudairi', 'Sat/Tue 10:30-12:30 W-121', 'Sat/Tue', '10:30:00', '12:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (318, 15, '8', 'Areej Ibrahim Hussein Abuqudairi', 'Mon/Thu 08:30-10:30 W-202', 'Mon/Thu', '08:30:00', '10:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (319, 22, '1', 'Wedad Khalid Walid Alsaad', 'Tue 10:00-11:30 W-002', 'Tue', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (320, 22, '2', NULL, 'Mon/Thu 08:30-11:30 W-002', 'Mon/Thu', '08:30:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (321, 22, '3', NULL, 'Sun/Wed 08:30-11:30 W-002', 'Sun/Wed', '08:30:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (322, 22, '4', 'Asma''a Abdel-Karim Azmi Al Kayalli', 'Tue 10:00-11:30 W-002', 'Tue', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (323, 22, '5', NULL, 'Tue 10:00-11:30 W-002', 'Tue', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (324, 22, '6', NULL, 'Sun/Wed 08:30-11:30 W-001', 'Sun/Wed', '08:30:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (325, 22, '7', NULL, 'Tue 10:00-11:30 W-002', 'Tue', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (326, 22, '8', NULL, 'Sat/Tue 14:30-17:30 W-002', 'Sat/Tue', '14:30:00', '17:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (327, 57, '3', 'Tala Sulaiman Mfleh Arabiat', 'Mon 08:30-11:30 W-203', 'Mon', '08:30:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (328, 57, '4', 'Emile Samuel Issa Abujaber', 'Wed 14:30-17:30 W-102', 'Wed', '14:30:00', '17:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (329, 57, '6', 'Tala Sulaiman Mfleh Arabiat', 'Sat 08:30-11:30 W-002', 'Sat', '08:30:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (330, 57, '8', 'Tala Sulaiman Mfleh Arabiat', '/ ** Blended 3 hours', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (331, 57, '9', 'Wedad Khalid Walid Alsaad', '/ ** Blended 3 hours', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (332, 57, '10', 'Sawsan Osama Abdel Hamid Sayeh', '/ ** Blended 3 hours', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (333, 17, '1', 'Hala Ali Abdallah Abu Rubeiha', '/', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (334, 17, '2', 'Asma''a Abdel-Karim Azmi Al Kayalli', '/', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (335, 17, '3', NULL, '/', NULL, NULL, NULL) ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (336, 3, '1', 'Shadi Mohmmad Abdel Ra''uof Al-Omari', 'Sun 12:00-13:00 W-121', 'Sun', '12:00:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (337, 3, '2', 'Shadi Mohmmad Abdel Ra''uof Al-Omari', 'Sun 13:00-14:00 W-121', 'Sun', '13:00:00', '14:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (338, 3, '3', 'Shadi Mohmmad Abdel Ra''uof Al-Omari', 'Mon 10:30-11:30 W-202', 'Mon', '10:30:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (339, 5, '1', 'Sajedah Mohammad Abdallah Alameer', 'Wed 08:30-10:30 W-125', 'Wed', '08:30:00', '10:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (340, 5, '2', 'Tareq Mohammad Abdulaziz Dalgmoni', 'Sun 10:30-12:30 W-125', 'Sun', '10:30:00', '12:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (341, 5, '3', 'Aladeen Ahmad Ibrahim Al Basheer', 'Wed 12:30-14:30 W-125', 'Wed', '12:30:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (342, 5, '4', 'Mohammad Hussein Ali Badarneh', 'Sun 14:30-16:30 W-125', 'Sun', '14:30:00', '16:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (343, 5, '5', 'Rula Mufied Elias Musleh', 'Thu 08:30-10:30 W-125', 'Thu', '08:30:00', '10:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (344, 5, '6', 'Tareq Mohammad Abdulaziz Dalgmoni', 'Mon 10:30-12:30 W-125', 'Mon', '10:30:00', '12:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (345, 5, '7', 'Shadi Mohmmad Abdel Ra''uof Al-Omari', 'Mon 12:30-14:30 W-125', 'Mon', '12:30:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (346, 5, '8', 'Ahmad Al-Soudi', 'Mon 14:30-16:30 W-125', 'Mon', '14:30:00', '16:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (347, 5, '10', 'Shatha Suleiman Ahmad Ali Saleh', 'Tue 08:30-10:30 W-125', 'Tue', '08:30:00', '10:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (348, 5, '11', 'Ahmad Al-Soudi', 'Sat 10:30-12:30 W-125', 'Sat', '10:30:00', '12:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (349, 5, '13', 'Tareq Mohammad Abdulaziz Dalgmoni', 'Sat 12:30-14:30 W-125', 'Sat', '12:30:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (350, 5, '14', 'Aladeen Ahmad Ibrahim Al Basheer', 'Tue 12:30-14:30 W-125', 'Tue', '12:30:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (351, 5, '15', 'Mohammad Hussein Ali Badarneh', 'Tue 14:30-16:30 W-125', 'Tue', '14:30:00', '16:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (352, 121, '1', 'Mohammad Hussein Ali Badarneh', 'Wed 14:30-16:30 W-128', 'Wed', '14:30:00', '16:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (353, 121, '2', 'Mohammad Hussein Ali Badarneh', 'Mon 14:30-16:30 W-128', 'Mon', '14:30:00', '16:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (354, 12, '1', 'Radwan Abdallah Ibrahim Alsmadi', 'Sun/Wed 08:30-10:00 W-128', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (355, 12, '2', 'Nemeh Salem Mohammad Altawil', 'Sun/Wed 10:00-11:30 W-128', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (356, 12, '3', 'Radwan Abdallah Ibrahim Alsmadi', 'Sun/Wed 11:30-13:00 W-128', 'Sun/Wed', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (357, 12, '4', 'Bayan Shabaneh', 'Sun/Wed 13:00-14:30 W-128', 'Sun/Wed', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (358, 12, '5', 'Nemeh Salem Mohammad Altawil', 'Mon/Thu 08:30-10:00 W-128', 'Mon/Thu', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (359, 12, '6', 'Radwan Abdallah Ibrahim Alsmadi', 'Mon/Thu 10:00-11:30 W-128', 'Mon/Thu', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (360, 12, '7', 'Nemeh Salem Mohammad Altawil', 'Mon/Thu 11:30-13:00 W-128', 'Mon/Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (361, 12, '8', 'Heba Shashaan', 'Mon/Thu 13:00-14:30 W-128', 'Mon/Thu', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (362, 12, '9', 'Bayan Shabaneh', 'Sat/Tue 08:30-10:00 W-128', 'Sat/Tue', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (363, 12, '10', 'Bayan Shabaneh', 'Sat/Tue 11:30-13:00 W-128', 'Sat/Tue', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (364, 7, '1', 'Shatha Ali Hamed Al Hawawsha', 'Sun/Wed 08:30-10:00 IJC-01', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (365, 7, '2', 'Shatha Ali Hamed Al Hawawsha', 'Sun/Wed 10:00-11:30 IJC-01', 'Sun/Wed', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (366, 7, '3', 'Ashraf Mohammad Saleem Al-Smadi', 'Sun/Wed 14:30-16:00 IJC-01', 'Sun/Wed', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (367, 7, '4', 'Shatha Ali Hamed Al Hawawsha', 'Mon/Thu 08:30-10:00 IJC-01', 'Mon/Thu', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (368, 7, '5', 'Shatha Ali Hamed Al Hawawsha', 'Mon/Thu 10:00-11:30 IJC-01', 'Mon/Thu', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (369, 7, '6', 'Shatha Ali Hamed Al Hawawsha', 'Mon/Thu 14:30-16:00 IJC-01', 'Mon/Thu', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (370, 7, '7', 'Ashraf Mohammad Saleem Al-Smadi', 'Sat/Tue 13:00-14:30 IJC-02', 'Sat/Tue', '13:00:00', '14:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (371, 7, '8', 'Ashraf Mohammad Saleem Al-Smadi', 'Sat/Tue 14:30-16:00 IJC-01', 'Sat/Tue', '14:30:00', '16:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (372, 7, '9', 'Ghosoun AlHindi', 'Mon/Thu 16:00-17:30 IJC-01', 'Mon/Thu', '16:00:00', '17:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (373, 7, '10', 'Ghosoun AlHindi', 'Sat/Tue 16:00-17:30 IJC-02', 'Sat/Tue', '16:00:00', '17:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (374, 26, '1', 'Rula Mufied Elias Musleh', 'Sun/Wed 08:30-10:00 W-121', 'Sun/Wed', '08:30:00', '10:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (375, 26, '3', 'Aladeen Ahmad Ibrahim Al Basheer', 'Mon/Thu 10:00-11:30 W-121', 'Mon/Thu', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (376, 26, '4', 'Rula Mufied Elias Musleh', 'Mon/Thu 11:30-13:00 W-121', 'Mon/Thu', '11:30:00', '13:00:00') ON CONFLICT (section_id) DO NOTHING;
INSERT INTO sections (section_id, course_id, section_number, instructor, schedule, day_of_week, start_time, end_time) VALUES (377, 26, '5', 'Tareq Mohammad Abdulaziz Dalgmoni', 'Sat/Tue 10:00-11:30 W-128', 'Sat/Tue', '10:00:00', '11:30:00') ON CONFLICT (section_id) DO NOTHING;

SELECT setval('sections_section_id_seq', (SELECT COALESCE(MAX(section_id),0) FROM sections));

-- ═══════════════════════════════════════════════════════════
-- STEP 6: Insert enrollments for all students
-- ═══════════════════════════════════════════════════════════

INSERT INTO enrollments (student_id, section_id, status) VALUES (1, 76, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (1, 78, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (1, 93, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (1, 81, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (1, 83, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (2, 58, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (2, 54, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (2, 42, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (2, 50, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (2, 66, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (3, 1, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (3, 100, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (3, 215, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (3, 354, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (3, 292, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (6, 59, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (6, 51, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (6, 55, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (6, 67, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (6, 77, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (7, 60, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (7, 43, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (7, 92, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (7, 173, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (7, 84, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (8, 16, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (8, 101, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (8, 117, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (8, 221, 'ACTIVE');
INSERT INTO enrollments (student_id, section_id, status) VALUES (8, 355, 'ACTIVE');

SELECT setval('enrollments_enrollment_id_seq', (SELECT COALESCE(MAX(enrollment_id),0) FROM enrollments));

-- ═══════════════════════════════════════════════════════════
-- STEP 7: Course completions for new students
-- DAWOUD (6): Year 3, completed Y1+Y2 but NOT Networking (10203180)
-- MOHAMMED (7): Year 3, completed Y1+Y2 + all prereqs
-- AYHAM (8): Year 2, completed Y1 but NOT Programming (40201100)
-- ═══════════════════════════════════════════════════════════

INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 1, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 2, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 3, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 4, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 5, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 6, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 7, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 8, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 9, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 10, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 11, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 12, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 16, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 17, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 14, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 15, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 18, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 24, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 19, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 20, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 21, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 23, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 25, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 26, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 27, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 28, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 29, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 30, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 22, 'passed', 'D', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (6, 34, 'passed', 'D', 'Fall 2024');

-- MOHAMMED (7) - Year 3, all prerequisites complete
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 1, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 2, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 3, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 4, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 5, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 6, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 7, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 8, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 9, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 10, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 11, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 12, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 16, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 17, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 13, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 14, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 15, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 18, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 24, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 19, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 20, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 21, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 23, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 25, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 26, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 27, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 28, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 29, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 30, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 22, 'passed', 'M', 'Fall 2024');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (7, 34, 'passed', 'M', 'Fall 2024');

-- AYHAM (8) - Year 2, completed Y1 but NOT Programming (course_id 14)
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (8, 1, 'passed', 'P', 'Spring 2025');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (8, 2, 'passed', 'P', 'Spring 2025');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (8, 3, 'passed', 'P', 'Spring 2025');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (8, 4, 'passed', 'P', 'Spring 2025');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (8, 5, 'passed', 'P', 'Spring 2025');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (8, 6, 'passed', 'P', 'Spring 2025');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (8, 7, 'passed', 'P', 'Spring 2025');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (8, 8, 'passed', 'P', 'Spring 2025');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (8, 9, 'passed', 'P', 'Spring 2025');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (8, 10, 'passed', 'P', 'Spring 2025');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (8, 11, 'passed', 'P', 'Spring 2025');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (8, 12, 'passed', 'P', 'Spring 2025');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (8, 16, 'passed', 'P', 'Spring 2025');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (8, 17, 'passed', 'P', 'Spring 2025');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (8, 13, 'passed', 'P', 'Spring 2025');
INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (8, 15, 'passed', 'P', 'Spring 2025');

SELECT setval('student_course_completion_completion_id_seq', (SELECT COALESCE(MAX(completion_id),0) FROM student_course_completion));

-- ═══════════════════════════════════════════════════════════
-- DONE! Your database is now seeded for UniSwap.
-- ═══════════════════════════════════════════════════════════