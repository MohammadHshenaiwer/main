-- ================================================
-- database_setup.sql
-- Run this on your PostgreSQL database ONCE
-- ================================================

-- TABLES
CREATE TABLE IF NOT EXISTS students (
    student_id  SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS courses (
    course_id   SERIAL PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    course_code VARCHAR(20),
    credits     INTEGER DEFAULT 3
);

CREATE TABLE IF NOT EXISTS sections (
    section_id      SERIAL PRIMARY KEY,
    course_id       INTEGER NOT NULL REFERENCES courses(course_id),
    section_number  VARCHAR(10) NOT NULL,
    instructor      VARCHAR(100),
    schedule        VARCHAR(100),
    capacity        INTEGER DEFAULT 30,
    enrolled_count  INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS enrollments (
    enrollment_id SERIAL PRIMARY KEY,
    student_id    INTEGER NOT NULL REFERENCES students(student_id),
    section_id    INTEGER NOT NULL REFERENCES sections(section_id),
    status        VARCHAR(20) DEFAULT 'ACTIVE'
);

CREATE TABLE IF NOT EXISTS swap_offers (
    offer_id         SERIAL PRIMARY KEY,
    student_id       INTEGER NOT NULL REFERENCES students(student_id),
    swap_type        VARCHAR(20) NOT NULL,
    have_section_id  INTEGER REFERENCES sections(section_id),
    want_description VARCHAR(255) NOT NULL,
    status           VARCHAR(20) DEFAULT 'OPEN',
    created_at       TIMESTAMP DEFAULT NOW(),
    updated_at       TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS swap_requests (
    request_id        SERIAL PRIMARY KEY,
    offer_id          INTEGER NOT NULL REFERENCES swap_offers(offer_id),
    sender_id         INTEGER NOT NULL REFERENCES students(student_id),
    receiver_id       INTEGER NOT NULL REFERENCES students(student_id),
    sender_section_id INTEGER REFERENCES sections(section_id),
    status            VARCHAR(20) DEFAULT 'PENDING',
    sent_at           TIMESTAMP DEFAULT NOW(),
    resolved_at       TIMESTAMP,
    CONSTRAINT chk_no_self_request CHECK (sender_id != receiver_id)
);

-- ================================================
-- TEST DATA
-- ================================================
INSERT INTO students (name, email) VALUES
    ('Alice Johnson', 'alice@university.edu'),
    ('Bob Smith',     'bob@university.edu'),
    ('Carol White',   'carol@university.edu'),
    ('David Brown',   'david@university.edu');

INSERT INTO courses (course_name, course_code, credits) VALUES
    ('Introduction to Programming', 'PROG1',  3),
    ('Arabic Language 5',           'ARAB5',  3),
    ('English Language 1',          'ENG1',   3),
    ('Calculus I',                  'MATH1',  4),
    ('Focus on Computing 2',        'FOC2',   3);

INSERT INTO sections (course_id, section_number, instructor, schedule, capacity, enrolled_count) VALUES
    (1, '1', 'Dr. Adams',   'MWF 9:00am',  30, 25),   -- section 1: PROG1 Sec1
    (1, '2', 'Dr. Baker',   'TTH 11:00am', 30, 28),   -- section 2: PROG1 Sec2
    (2, '1', 'Dr. Clark',   'MWF 10:00am', 25, 24),   -- section 3: ARAB5 Sec1
    (2, '2', 'Dr. Davis',   'TTH 2:00pm',  25, 20),   -- section 4: ARAB5 Sec2
    (3, '1', 'Prof. Evans', 'MWF 1:00pm',  20, 18),   -- section 5: ENG1 Sec1
    (4, '1', 'Dr. Foster',  'TTH 9:00am',  28, 27),   -- section 6: MATH1 Sec1
    (5, '1', 'Dr. Green',   'MWF 3:00pm',  28, 22),   -- section 7: FOC2 Sec1
    (5, '2', 'Dr. Harris',  'TTH 4:00pm',  28, 15);   -- section 8: FOC2 Sec2

-- Alice: PROG1 Sec1, ARAB5 Sec1, FOC2 Sec1
INSERT INTO enrollments (student_id, section_id, status) VALUES
    (1, 1, 'ACTIVE'),
    (1, 3, 'ACTIVE'),
    (1, 7, 'ACTIVE'),
-- Bob: PROG1 Sec2, ARAB5 Sec2, FOC2 Sec2
    (2, 2, 'ACTIVE'),
    (2, 4, 'ACTIVE'),
    (2, 8, 'ACTIVE'),
-- Carol: ENG1 Sec1, MATH1 Sec1
    (3, 5, 'ACTIVE'),
    (3, 6, 'ACTIVE'),
-- David: FOC2 Sec1, ARAB5 Sec2
    (4, 7, 'ACTIVE'),
    (4, 4, 'ACTIVE');
