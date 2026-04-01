-- UniSwap test users seed
-- Fixes identity error by using OVERRIDING SYSTEM VALUE.
-- Safe to rerun.

BEGIN;

-- ------------------------------------------------------------
-- 1) Test users (12 users across all years)
-- ------------------------------------------------------------
WITH test_users(user_id, full_name, email, password_hash, role, student_number, academic_year) AS (
    VALUES
        (900001, 'Test User Y4-A', 'test.y4a@htu.edu.jo', 'dummy', 'student', '22000001', 4),
        (900002, 'Test User Y4-B', 'test.y4b@htu.edu.jo', 'dummy', 'student', '22000002', 4),
        (900003, 'Test User Y4-C', 'test.y4c@htu.edu.jo', 'dummy', 'student', '22000003', 4),
        (900004, 'Test User Y4-D', 'test.y4d@htu.edu.jo', 'dummy', 'student', '22000004', 4),
        (900005, 'Test User Y3-A', 'test.y3a@htu.edu.jo', 'dummy', 'student', '23000001', 3),
        (900006, 'Test User Y3-B', 'test.y3b@htu.edu.jo', 'dummy', 'student', '23000002', 3),
        (900007, 'Test User Y2-A', 'test.y2a@htu.edu.jo', 'dummy', 'student', '24000001', 2),
        (900008, 'Test User Y2-B', 'test.y2b@htu.edu.jo', 'dummy', 'student', '24000002', 2),
        (900009, 'Test User Y1-A', 'test.y1a@htu.edu.jo', 'dummy', 'student', '25000001', 1),
        (900010, 'Test User Y1-B', 'test.y1b@htu.edu.jo', 'dummy', 'student', '25000002', 1),
        (900011, 'Test User Y3-Cases', 'test.y3cases@htu.edu.jo', 'dummy', 'student', '23000011', 3),
        (900012, 'Test User Y4-Target', 'test.y4target@htu.edu.jo', 'dummy', 'student', '22000012', 4)
)
INSERT INTO users (user_id, full_name, email, password_hash, role, student_number)
OVERRIDING SYSTEM VALUE
SELECT user_id, full_name, email, password_hash, role, student_number
FROM test_users
ON CONFLICT (user_id) DO UPDATE
SET full_name = EXCLUDED.full_name,
    email = EXCLUDED.email,
    password_hash = EXCLUDED.password_hash,
    role = EXCLUDED.role,
    student_number = EXCLUDED.student_number;

-- Mirror into legacy students table (enrollments FK points here)
WITH test_students(student_id, name, email) AS (
    VALUES
        (900001, 'Test User Y4-A', 'test.y4a@htu.edu.jo'),
        (900002, 'Test User Y4-B', 'test.y4b@htu.edu.jo'),
        (900003, 'Test User Y4-C', 'test.y4c@htu.edu.jo'),
        (900004, 'Test User Y4-D', 'test.y4d@htu.edu.jo'),
        (900005, 'Test User Y3-A', 'test.y3a@htu.edu.jo'),
        (900006, 'Test User Y3-B', 'test.y3b@htu.edu.jo'),
        (900007, 'Test User Y2-A', 'test.y2a@htu.edu.jo'),
        (900008, 'Test User Y2-B', 'test.y2b@htu.edu.jo'),
        (900009, 'Test User Y1-A', 'test.y1a@htu.edu.jo'),
        (900010, 'Test User Y1-B', 'test.y1b@htu.edu.jo'),
        (900011, 'Test User Y3-Cases', 'test.y3cases@htu.edu.jo'),
        (900012, 'Test User Y4-Target', 'test.y4target@htu.edu.jo')
)
INSERT INTO students (student_id, name, email)
OVERRIDING SYSTEM VALUE
SELECT student_id, name, email
FROM test_students
ON CONFLICT (student_id) DO UPDATE
SET name = EXCLUDED.name,
    email = EXCLUDED.email;

SELECT setval(pg_get_serial_sequence('users', 'user_id'), (SELECT MAX(user_id) FROM users), true);
SELECT setval(pg_get_serial_sequence('students', 'student_id'), (SELECT MAX(student_id) FROM students), true);

-- ------------------------------------------------------------
-- 2) Clean only this test dataset before reseeding
-- ------------------------------------------------------------
DELETE FROM swap_requests
WHERE sender_id BETWEEN 900001 AND 900012
   OR receiver_id BETWEEN 900001 AND 900012
   OR offer_id IN (
        SELECT offer_id
        FROM swap_offers
        WHERE student_id BETWEEN 900001 AND 900012
           OR target_student_id BETWEEN 900001 AND 900012
   );

DELETE FROM swap_offers
WHERE student_id BETWEEN 900001 AND 900012
   OR target_student_id BETWEEN 900001 AND 900012;

DELETE FROM enrollments
WHERE student_id BETWEEN 900001 AND 900012;

DELETE FROM student_course_completion
WHERE student_id BETWEEN 900001 AND 900012;

-- ------------------------------------------------------------
-- 3) Swap-focused enrollments (known sections for edge cases)
-- ------------------------------------------------------------
WITH fixed_enrollments(student_id, section_id, status) AS (
    VALUES
        (900001, 76, 'ACTIVE'),
        (900001, 78, 'ACTIVE'),
        (900001, 81, 'ACTIVE'),
        (900001, 83, 'ACTIVE'),
        (900001, 93, 'ACTIVE'),

        (900002, 77, 'ACTIVE'),
        (900002, 42, 'ACTIVE'),
        (900002, 82, 'ACTIVE'),
        (900002, 84, 'ACTIVE'),
        (900002, 92, 'ACTIVE'),

        (900003, 92, 'ACTIVE'),
        (900003, 43, 'ACTIVE'),
        (900003, 80, 'ACTIVE'),
        (900003, 82, 'ACTIVE'),
        (900003, 84, 'ACTIVE'),

        (900011, 76, 'ACTIVE'),

        (900012, 77, 'ACTIVE'),
        (900012, 78, 'ACTIVE'),
        (900012, 84, 'ACTIVE'),

        (900004, 77, 'ACTIVE'),
        (900004, 84, 'ACTIVE'),
        (900004, 79, 'ACTIVE'),
        (900004, 82, 'ACTIVE'),
        (900004, 93, 'ACTIVE')
)
INSERT INTO enrollments (student_id, section_id, status)
SELECT student_id, section_id, status
FROM fixed_enrollments;

-- ------------------------------------------------------------
-- 4) Year-based enrollments for additional users (Y1/Y2/Y3)
-- ------------------------------------------------------------
WITH user_years(student_id, academic_year) AS (
    VALUES
        (900005, 3),
        (900006, 3),
        (900007, 2),
        (900008, 2),
        (900009, 1),
        (900010, 1)
),
course_sections AS (
    SELECT
        c.course_id,
        s.section_id,
        CAST(SUBSTRING(c.code FROM 6 FOR 1) AS INTEGER) AS course_year,
        ROW_NUMBER() OVER (PARTITION BY c.course_id ORDER BY s.section_id) AS rn_per_course
    FROM courses c
    JOIN sections s ON s.course_id = c.course_id
    WHERE c.code ~ '^[0-9]{6,}$'
      AND SUBSTRING(c.code FROM 6 FOR 1) ~ '^[1-4]$'
),
one_section_per_course AS (
    SELECT course_id, section_id, course_year
    FROM course_sections
    WHERE rn_per_course = 1
),
ranked_by_year AS (
    SELECT
        course_id,
        section_id,
        course_year,
        ROW_NUMBER() OVER (PARTITION BY course_year ORDER BY course_id) AS rn_in_year
    FROM one_section_per_course
)
INSERT INTO enrollments (student_id, section_id, status)
SELECT uy.student_id, r.section_id, 'ACTIVE'
FROM user_years uy
JOIN ranked_by_year r
  ON r.course_year = uy.academic_year
 AND r.rn_in_year <= 5;

-- ------------------------------------------------------------
-- 5) Year-based completions for all test users
-- ------------------------------------------------------------
WITH user_years(student_id, academic_year) AS (
    VALUES
        (900001, 4), (900002, 4), (900003, 4), (900004, 4),
        (900005, 3), (900006, 3),
        (900007, 2), (900008, 2),
        (900009, 1), (900010, 1),
        (900011, 3), (900012, 4)
),
courses_with_year AS (
    SELECT
        c.course_id,
        CAST(SUBSTRING(c.code FROM 6 FOR 1) AS INTEGER) AS course_year
    FROM courses c
    WHERE c.code ~ '^[0-9]{6,}$'
      AND SUBSTRING(c.code FROM 6 FOR 1) ~ '^[1-4]$'
)
INSERT INTO student_course_completion (student_id, course_id, status, grade, term)
SELECT uy.student_id, cwy.course_id, 'passed', 'P', 'Auto-Year Seed'
FROM user_years uy
JOIN courses_with_year cwy
  ON cwy.course_year < uy.academic_year;

-- ------------------------------------------------------------
-- 6) Extra case-specific completions
-- ------------------------------------------------------------
WITH extra_completions(student_id, course_code) AS (
    VALUES
        (900001, '40201491'),
        (900004, '40201430'),
        (900012, '40201491')
)
INSERT INTO student_course_completion (student_id, course_id, status, grade, term)
SELECT ec.student_id, c.course_id, 'passed', 'P', 'Case Override'
FROM extra_completions ec
JOIN courses c ON c.code = ec.course_code
WHERE NOT EXISTS (
    SELECT 1
    FROM student_course_completion scc
    WHERE scc.student_id = ec.student_id
      AND scc.course_id = c.course_id
);

COMMIT;
