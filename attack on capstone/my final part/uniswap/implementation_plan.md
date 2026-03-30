# UniSwap Enhancement Plan

## Proposed Changes

### 1. Fix Performance Bottleneck (The 35-Second Loading Delay)
Currently, `getAllSections` pulls ~380 sections, and for each section, Hibernate independently requests its parent `Course` from Supabase over the network (the N+1 fetching problem). This scales the delay up to 34+ seconds.
- I will enforce a `@EntityGraph(attributePaths = {"course"})` on `SectionRepository`, combining this into a single heavily optimized SQL query that will execute in milliseconds.

### 2. Unified User Architecture (Using `users` Table)
You want to eliminate the duplicate `students` table and rely solely on the `users` table provided in your SQL dumps.
- Update `Student.java` to map to `@Table(name = "users")`, renaming `student_id` to `user_id` to match the exact database columns.
- We will add the `student_number` (String) mapping to the entity.
- The React login will now search for users by their `student_number` rather than scanning by the internal integer ID. I will update `StudentController` and `StudentRepository` to reflect this logic.

### 3. Backend Cascading Schema Updates (Foreign Keys)
Because we are discarding `students`, we must change the schema constraints spanning the entire project:
- Foreign keys in `swap_offers`, `swap_requests`, `enrollments`, and `student_course_completion` must be changed from `student_id -> students(student_id)` to `student_id -> users(user_id)`.
- I will update JPA mappings and `seed.sql` to enforce this.

### 4. Auto-Complete 1st and 2nd Year Courses
You asked to automatically inject 1st and 2nd-year completed prerequisite rows for your seeded students (so they appear as legitimate 3rd-year students in the system).
- I will write a dynamic SQL `INSERT` script in `seed.sql` that grabs all courses where the 6th digit of the `code` is `1` or `2` (e.g., `40201100` = Year 1, `10203210` = Year 2).
- It will blanket-assign these records into `student_course_completion` for your primary test users as "COMPLETED" with a passing grade.

---

> [!IMPORTANT]
> **User Review Required**: Since this requires destructively recreating database constraints in `seed.sql` and changing the core authentication mapping, do you approve this architectural shift? I will need you to wipe your database and re-run `seed.sql` once I'm done applying the script.
