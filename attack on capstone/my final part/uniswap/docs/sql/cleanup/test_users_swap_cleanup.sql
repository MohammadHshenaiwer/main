-- Remove test users and all dependent swap/schedule data
-- Run this after finishing swap tests.

BEGIN;

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

DELETE FROM users
WHERE user_id BETWEEN 900001 AND 900012;

DELETE FROM students
WHERE student_id BETWEEN 900001 AND 900012;

COMMIT;

-- Optional quick check
-- SELECT user_id FROM users WHERE user_id BETWEEN 900001 AND 900012;
