-- ==========================================
-- FINAL DATABASE SCHEMA
-- ==========================================

CREATE TABLE public.users (
    user_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('student', 'admin', 'advisor')),
    student_number VARCHAR(20)
    prerequisite_text (dont know what exactly it have number and words like {30302111 OR (40302111 AND 30301122)})
);

CREATE TABLE public.courses (
    course_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(200) NOT NULL,
    credit_hours INT,
    difficulty_level VARCHAR(10) CHECK (difficulty_level IN ('easy','medium','hard')),
    category VARCHAR,
    year INTEGER,
    semester_num INTEGER
);

CREATE TABLE public.course_sections (
    section_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_id INT NOT NULL REFERENCES public.courses(course_id) ON DELETE CASCADE,
    section_number VARCHAR(20) NOT NULL,
    semester VARCHAR(10) NOT NULL CHECK (semester IN ('Fall','Spring','Summer')),
    year INT NOT NULL,
    day_of_week VARCHAR(10) NOT NULL CHECK (day_of_week IN ('Sun','Mon','Tue','Wed','Thu','Fri','Sat')),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room VARCHAR(50),
    instructor_name VARCHAR(150)
);

CREATE TABLE public.student_schedule (
    schedule_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id INT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    semester VARCHAR(10) NOT NULL CHECK (semester IN ('Fall','Spring','Summer')),
    year INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_final BOOLEAN DEFAULT FALSE
);

CREATE TABLE public.student_schedule_sections (
    schedule_section_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    schedule_id INT NOT NULL REFERENCES public.student_schedule(schedule_id) ON DELETE CASCADE,
    section_id INT NOT NULL REFERENCES public.course_sections(section_id) ON DELETE CASCADE
);

CREATE TABLE public.student_course_completion (
    completion_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id INT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    course_id INT NOT NULL REFERENCES public.courses(course_id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('passed','failed','in-progress')),
    grade VARCHAR(5),
    term VARCHAR(20)
);

CREATE TABLE public.online_courses (
    online_course_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    platform VARCHAR(100) NOT NULL,
    title VARCHAR(200) NOT NULL,
    url VARCHAR(500) NOT NULL,
    main_topic VARCHAR(150),
    tag VARCHAR,
    course_id INTEGER REFERENCES public.courses(course_id)
);

CREATE TABLE public.student_online_course_recommendations (
    recommendation_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id INT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    online_course_id INT NOT NULL REFERENCES public.online_courses(online_course_id) ON DELETE CASCADE,
    recommended_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_reason TEXT,
    status VARCHAR(15) DEFAULT 'pending' CHECK (status IN ('pending','accepted','dismissed'))
);

CREATE TABLE public.announcements (
    announcement_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    created_by_user_id INT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    target_audience_type VARCHAR(10) DEFAULT 'all' CHECK (target_audience_type IN ('all','major','level')),
    target_major VARCHAR(50),
    target_level VARCHAR(20)
);

CREATE TABLE public.schedule_rating (
    rating_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    schedule_id INT NOT NULL REFERENCES public.student_schedule(schedule_id) ON DELETE CASCADE,
    workload_score INT,
    difficulty_score INT,
    time_distribution_score INT,
    overall_score INT,
    ai_explanation TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);