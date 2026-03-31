# UniSwap - Complete Project & Handover Guide

This document is a comprehensive guide to understanding the **UniSwap** project. It explains the core concepts, the architecture, what has been built and fixed so far, and clearly outlines the current bugs/tasks that remain.

You can feed this entire document to AI (like Claude or ChatGPT) to give it immediate context on how to jump in and start coding.

---

## 1. Project Overview & Tech Stack

**Project Name:** UniSwap (University Section Swapping Portal)
**Purpose:** A web application where university students can securely swap registered course sections with other students, manage their existing schedules, and enroll in new available sections if they meet the necessary prerequisite requirements.

**Technology Stack:**
- **Backend:** Spring Boot (Java 17+), Spring Data JPA, Hibernate.
- **Frontend:** React + Vite (`frontend/` directory).
- **Database:** PostgreSQL (hosted remotely via Supabase).
- **Setup script:** `src/main/resources/data/seed.sql` handles all table initialization and dummy data seeding.

---

## 2. Core Entities & Database Logic

The system is built on these primary concepts:
1. **Users (`users` table):** Formerly known as `students`. This table houses the student profile (`user_id` as PK, `student_number` as the string ID used to log in, e.g., "22110066").
2. **Courses (`courses`):** Contains master records of university subjects, credits, and their explicit `prerequisite_course_code` (e.g., "30303111" for Functional Math).
3. **Sections (`sections`):** A specific time-slot instance of a course led by an instructor with a fixed capacity.
4. **Enrollments (`enrollments`):** Tracks which sections a user is currently registered in.
5. **Completions (`student_course_completion`):** Critical for validation. Tracks which `Course` a user has explicitly marked as `"passed"`.
6. **Swap Offers & Requests (`swap_offers`, `swap_requests`):** The engine of the portal allowing a user to broadcast a section they want to trade, and receive/accept incoming offers for other sections.

---

## 3. What We Have Accomplished So Far

We have stabilized and fully connected the backend to the frontend with significant optimizations:

### A. Solved the "N+1" Database Cripple
*   **The Issue:** The `/api/sections` endpoint was taking 30–40 seconds to load because Hibernate was generating a unique SQL query to fetch the `Course` master data for *every single Section instance* in the DB.
*   **The Fix:** Added an `@EntityGraph(attributePaths = {"course"})` in `SectionRepository.java`. Now, available sections fetch instantly in milliseconds using a proper SQL JOIN.

### B. Mapped Authentication & Consolidated the Users Table
*   **The Issue:** The application previously split its data between an isolated `students` table and a `users` table shared with another module (eLearning portal).
*   **The Fix:** 
    *   Updated the `Student.java` Java entity to strictly use `@Table(name = "users")` directly. 
    *   Altered login mechanism in `StudentController.java` to search by `studentNumber` (String).
    *   The frontend `LoginPage.jsx` fires `GET /api/students/login?studentNumber=22110066` and grabs the deeply nested numeric `user_id` Primary Key to act as the authentication token for all subsequent components.
    *   Rewrote all dependencies in `seed.sql` to set their foreign keys specifically against `users(user_id)`.

### C. Created Auto-Seeding for 1st & 2nd Year Completeness
*   **The Fix:** To test 3rd and 4th year course additions, I authored a SQL inject block at the bottom of `seed.sql`. This script forcefully inserts "passed" completion records into `student_course_completion` for all courses defined as 1st or 2nd year, enabling target student profiles (like `22110066`) to seamlessly bypass lower-tier prerequisites.

---

## 4. Current Situation & The Bug to Fix

**Our Current State:**
We are functionally sound, but we have hit a wall on **Prerequisite Validation Mapping**.

**The Bug:**
When logging in as user `22110066`, we try to browse "Available Courses" or click "Add Section". A course like **Maths for Computing (40303121)** requires **Functional Math (30303111)** as a prerequisite. 
However, the UI blocks the selection with a red **`⚠ Missing Prereq`** warning.

**How it supposedly works under the hood:**
1. The frontend hits `GET /api/students/{id}/completions` which pulls an array of `course_code` strings that the user has marked as `'passed'`.
2. The frontend code (in `SectionPickerModal.jsx` and `AvailableCoursesPage.jsx`) checks if the selected course's prerequisite exists (`array.includes()`) in the backend's returned completions array.

**Why is it failing? (Hypotheses for the AI to debug):**
1. **The Auto-Seed Script Syntax:** In `seed.sql`, the script I wrote at the bottom says:
   `AND SUBSTRING(c.code FROM 6 FOR 1) IN ('1', '2')`
   However, the `courses` table column might be called `course_code`, not `code`. This might cause the SQL block to quietly fail or insert nothing upon database initialization.
2. **Missing PK Reference:** The script hardcodes specific `user_id` values (e.g., `WHERE u.user_id IN (1, 2, 3, 6, 7, 8)`). If user `22110066` generated an ID outside of this range (like `9`), they naturally wouldn't receive the auto-completions.
3. **Frontend Mismatch:** Is the backend returning `[ "30303111" ]` but the frontend is somehow mapping it differently?

## 5. Instructions for the Next AI (Claude / ChatGPT)

Hello fellow AI assistant! Here are your immediate objectives:

1. **Investigate the SQL Auto-seed constraint:** Open `data/seed.sql`, locate the `STEP 7: Auto-complete 1st and 2nd Year courses` at the very bottom, and ensure the syntax maps to the actual schema (verify `courses` uses `course_code` and adjust the substring logic accordingly). Verify user IDs.
2. **Review the Completions Endpoint:** Check `StudentController.java` to ensure `getCompletions` cleanly returns the string identifiers of completed courses.
3. **Verify the Frontend Checks:** Review `AvailableCoursesPage.jsx` and `SectionPickerModal.jsx` to ensure `rl = L && !U.includes(L)` executes properly without type mismatches.
4. **Coordinate with the User:** Have the user wipe/reset their Supabase Database with the updated `seed.sql`, restart Spring Boot, and login as `22110066`. The user should suddenly see that course `40303121` is **Available** and labeled `Eligible` rather than `Missing Prereq`.
