import psycopg2
import pandas as pd
import re
from datetime import datetime

# DB Connection
conn = psycopg2.connect(
    host='db.shwfqfuuhzvbhtpzqdbs.supabase.co',
    user='postgres',
    password='Minbl23!mkbn',
    dbname='postgres',
    port=5432
)
cur = conn.cursor()

# Make sure tables are empty for fresh insert (just to be safe against constraints, though they are currently empty)
cur.execute('TRUNCATE table enrollments, swap_requests, swap_offers, student_course_completion, sections, courses, students CASCADE;')
conn.commit()

# Read CSV
df = pd.read_csv('portal_sections_rows.csv')
# Fill NaNs with empty strings
df.fillna('', inplace=True)

# 1. Insert Courses
courses_dict = {}
for _, row in df.iterrows():
    c_code = str(row['course_number']).strip()
    if c_code not in courses_dict:
        # Some credit hours might be non-int, fallback to 3
        try:
            credits = int(row['hours'])
        except:
            credits = 3
            
        courses_dict[c_code] = {
            'name': row['course_name'],
            'credits': credits,
            'prereq': str(row['prerequisite_course']).strip()
        }

course_id_map = {}
for c_code, data in courses_dict.items():
    cur.execute(
        "INSERT INTO courses (name, code, credit_hours, prerequisite_course_code) VALUES (%s, %s, %s, %s) RETURNING course_id;",
        (data['name'], c_code, data['credits'], data['prereq'])
    )
    course_id_map[c_code] = cur.fetchone()[0]


# 2. Insert Sections
day_map = {
    'ح': 'Sun',
    'ن': 'Mon',
    'ث': 'Tue',
    'ر': 'Wed',
    'خ': 'Thu',
    'س': 'Sat'
}

for _, row in df.iterrows():
    c_code = str(row['course_number']).strip()
    course_id = course_id_map[c_code]
    
    sec_num = str(row['section_number']).strip()
    instructor = str(row['instructor_name']).strip()
    raw_time = str(row['time_classroom']).strip()
    
    # Defaults
    start_time = None
    end_time = None
    days_str = None
    schedule_str = raw_time
    
    # Parse the format: "08,30 - 10,00 ح ر / المبنى ..."
    # Regex to find times like "HH,MM - HH,MM"
    time_match = re.search(r'(\d{2},\d{2})\s*-\s*(\d{2},\d{2})', raw_time)
    if time_match:
        try:
            s_t = time_match.group(1).replace(',', ':')
            e_t = time_match.group(2).replace(',', ':')
            start_time = datetime.strptime(s_t, '%H:%M').time()
            end_time = datetime.strptime(e_t, '%H:%M').time()
        except:
            pass
            
    # Parse days
    # Look for the string segment before the slash
    parts = raw_time.split('/')
    if len(parts) > 0:
        before_slash = parts[0]
        extracted_days = []
        for d in day_map.keys():
            if d in before_slash:
                extracted_days.append(day_map[d])
        if extracted_days:
            days_str = '/'.join(extracted_days)
            
        # Cleaned schedule string for display: replace comma with colon, and use English days
        cleaned_str = before_slash.replace(',', ':')
        for arb, eng in day_map.items():
            cleaned_str = cleaned_str.replace(arb, eng)
        if len(parts) > 1:
            cleaned_str += ' / ' + '/'.join(parts[1:])
        schedule_str = cleaned_str

    cur.execute('''
        INSERT INTO sections (course_id, section_number, instructor, schedule, capacity, enrolled_count, day_of_week, start_time, end_time, course_year)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
    ''', (course_id, sec_num, instructor, schedule_str, 50, 0, days_str, start_time, end_time, 2))  # Just defaulting course_year to 2 for now, we remove year logic soon

# 3. Insert Students
students = [
    (22210019, 'DAWOUD AL-NAJI', '22210019@htu.edu.jo'),
    (22120026, 'MOHAMMED HABBOUB', '22120026@htu.edu.jo'),
    (22110260, 'AYHAM ODEH', '22110260@htu.edu.jo')
]

for s in students:
    # also add to users table if not exists
    cur.execute("SELECT 1 FROM users WHERE user_id = %s", (s[0],))
    if not cur.fetchone():
        cur.execute("INSERT INTO users (user_id, full_name, email, password_hash, role) VALUES (%s, %s, %s, 'pass', 'student');", s)
    
    cur.execute("SELECT 1 FROM students WHERE student_id = %s", (s[0],))
    if not cur.fetchone():
        cur.execute("INSERT INTO students (student_id, name, email) VALUES (%s, %s, %s);", s)

# Connect completion logic for Dawoud (Year 2) => Finished basic courses
# Let's say he finished Programming (40303130 is prereq for 40201100). Wait, 40303130 is "Fundamentals of Computing"
# Ayham (Year 2), Mohammed (Year 3). So we can assign diverse courses to them later, let's just insert one or two.
def add_completion(s_id, c_code):
    if c_code in course_id_map:
        c_id = course_id_map[c_code]
        cur.execute("INSERT INTO student_course_completion (student_id, course_id, status, grade, term) VALUES (%s, %s, 'passed', 'A', 'Fall');", (s_id, c_id))

# 40303130 = Fundamentals of Computing
# 40201100 = Programming
# Give them basic prereqs
for s in students:
    add_completion(s[0], '40303130')

# For Mohammed Habboub (Year 3), give him 'Programming' too
add_completion(22120026, '40201100')

conn.commit()
cur.close()
conn.close()

print("Supabase Data Seeding Complete!")
