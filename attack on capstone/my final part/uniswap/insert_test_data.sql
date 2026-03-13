-- Add 3 students
INSERT INTO students (name, email) VALUES
    ('Alice Johnson', 'alice@university.edu'),
    ('Bob Smith', 'bob@university.edu'),
    ('Carol White', 'carol@university.edu')
ON CONFLICT DO NOTHING;

-- Map to some of the courses that already exist in Supabase (assuming IDs 40,41,etc. exist)
INSERT INTO sections (course_id, section_number, instructor, schedule, capacity, enrolled_count) VALUES
    (40, '1', 'Dr. Adams', 'MWF 9:00am', 30, 25),
    (40, '2', 'Dr. Baker', 'TTH 11:00am', 30, 28),
    (41, '1', 'Dr. Clark', 'MWF 10:00am', 25, 24),
    (42, '1', 'Dr. Davis', 'TTH 2:00pm', 25, 20);

-- Enroll students
INSERT INTO enrollments (student_id, section_id, status) VALUES
    (1, 1, 'ACTIVE'), -- Alice in Course 40 Sec 1
    (1, 4, 'ACTIVE'), -- Alice in Course 42 Sec 1
    (2, 2, 'ACTIVE'), -- Bob in Course 40 Sec 2
    (3, 3, 'ACTIVE'); -- Carol in Course 41 Sec 1

-- Create some swap offers on the board
INSERT INTO swap_offers (student_id, swap_type, have_section_id, want_description, status) VALUES
    (1, 'SECTION_SWAP', 1, 'Same course, but Section 2 please, 9am is too early!', 'OPEN'),
    (2, 'COURSE_SWAP', 2, 'Want to drop this for English Upper-Intermediate', 'OPEN');
