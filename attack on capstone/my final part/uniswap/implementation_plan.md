# UniSwap - Full Application Scope and Handover Plan

This document is the single onboarding reference for AI-assisted continuation (including long voice sessions).
It describes the current system behavior, architecture, business rules, test setup, and known constraints.

## 1) Product Scope

UniSwap is a university portal where a student can:
- log in using student identifier
- view current schedule
- add/remove sections with prerequisite and conflict checks
- post swap offers (public or directed to a specific student)
- accept direct trades from the trading board
- manage incoming/sent swap requests in My Swaps

Core objective: enforce academic constraints while allowing practical section/course swaps.

## 2) Tech Stack and Runtime

- Backend: Spring Boot 3.x, Java 17, Spring Data JPA, PostgreSQL
- Frontend: React + Vite
- DB host: Supabase Postgres
- Backend port: `8080`
- Frontend dev port: `5173`

Run locally:
- Backend: `mvnw.cmd spring-boot:run`
- Frontend: in `frontend/` run `npm run dev`

## 3) Repository Map

- Backend source: `src/main/java/com/university/swap`
- Backend config: `src/main/resources/application.properties`
- Frontend app: `frontend/src`
- Main planning docs:
  - `implementation_plan.md` (this file)
  - `docs/swap_user_cases.md`
- SQL and test scripts:
  - `data/seed.sql`
  - `data/test cases.sql`
  - `docs/sql/cleanup/test_users_swap_cleanup.sql`

## 4) Data Model (Conceptual)

Primary tables and roles:
- `users`: primary student profile model used by backend `Student` entity
- `students`: legacy table still referenced by FK in some environments
- `courses`: master course catalog, includes `prerequisite_course_code`
- `sections`: specific section instances with schedule metadata
- `enrollments`: active schedule per student
- `student_course_completion`: passed/completed course records
- `swap_offers`: board posts (`have_section`, `want_section`, optional `target_student`)
- `swap_requests`: request/transaction log for swaps

Important note: some DB setups still require entries in both `users` and `students` for FK consistency.

## 5) Frontend Pages and Behavior

### 5.1 Login
- File: `frontend/src/components/LoginPage.jsx`
- Flow: identifier + password UI, then calls `verifyStudent()`
- Identifier supports student id, student number, or email-like input

### 5.2 Student Schedule
- File: `frontend/src/components/StudentSchedulePage.jsx`
- Shows enrolled sections
- Actions:
  - Add section (opens `SectionPickerModal` in add mode)
  - Trade section (opens `SectionPickerModal` in trade mode)
  - Delete section

### 5.3 Section Picker Modal
- File: `frontend/src/components/SectionPickerModal.jsx`
- Used in add and trade modes
- Validates/labels sections with states:
  - Current Section
  - Registered
  - Completed
  - Missing Prereq
  - Conflict
  - Eligible
- Trade mode includes blue direct-request input:
  - Optional target student (student id or student number)
  - If filled, offer is directed via `targetStudentId`

### 5.4 Available Courses
- File: `frontend/src/components/AvailableCoursesPage.jsx`
- Read-only catalog view with status indicators based on completions/prereqs

### 5.5 Trading Page
- File: `frontend/src/components/TradingPage.jsx`
- Shows open offers visible to current student
- Supports direct accept flow
- Added filters:
  - acceptability filter (all/can/cannot accept)
  - wanted-course search
  - day chips filter (Sat..Thu)
  - time range filter (from/to)

### 5.6 My Swaps
- File: `frontend/src/components/MySwapsPage.jsx`
- Three views:
  - My posted offers
  - Incoming requests (accept/reject)
  - Sent requests (cancel)

## 6) Backend API Scope

### Students
- `GET /api/students/login?identifier=...`
- `GET /api/students/{id}`
- `GET /api/students/{id}/completions`

### Enrollments
- `GET /api/enrollments/my?studentId=...`
- `POST /api/enrollments/add?studentId=...&sectionId=...`
- `DELETE /api/enrollments/remove?studentId=...&sectionId=...`

### Sections
- `GET /api/sections`

### Swap Offers
- `GET /api/swaps/offers?studentId=...`
- `GET /api/swaps/offers/my?studentId=...`
- `POST /api/swaps/offers`
- `DELETE /api/swaps/offers/{offerId}?studentId=...`

### Swap Requests
- `POST /api/swaps/requests`
- `POST /api/swaps/requests/accept-direct`
- `GET /api/swaps/requests/incoming?studentId=...`
- `GET /api/swaps/requests/sent?studentId=...`
- `POST /api/swaps/requests/{requestId}/accept?studentId=...`
- `POST /api/swaps/requests/{requestId}/reject?studentId=...`
- `DELETE /api/swaps/requests/{requestId}?studentId=...`

## 7) Business Rules Implemented

Key swap/enrollment rules currently enforced:
- cannot add/swap into a course already completed
- prerequisite must be satisfied for target course
- cannot swap section with itself
- time conflict checks on add/create offer/accept
- student must still own required sections at accept time
- duplicate pending request for same offer+sender blocked
- same offered section can target multiple different wanted sections
- exact duplicate offer pair (same have + same want) blocked
- directed offers can be limited to one target student
- on successful swap, dependent offers/requests using traded-away section are cleaned up/cancelled

## 8) Data Integrity and Reliability Changes

Recent reliability updates:
- deduplicated enrollment read behavior in repository
- startup cleanup of duplicate active enrollments
- safer ACTIVE comparisons with case-insensitive checks

Relevant files:
- `src/main/java/com/university/swap/repository/EnrollmentRepository.java`
- `src/main/java/com/university/swap/service/EnrollmentService.java`

## 9) Test Strategy and Scripts

Primary scenario checklist:
- `docs/swap_user_cases.md`

Seed and cleanup scripts for controlled testing:
- seed: `data/test cases.sql`
- cleanup: `docs/sql/cleanup/test_users_swap_cleanup.sql`

Seed script creates dedicated test users across academic years and configures enrollments/completions for edge cases.

## 10) Known Limitations / Risks (Important)

Current design limitations to be aware of before production hardening:
- authentication is identifier-based and not full credential-based auth
- authorization relies heavily on client-supplied ids in query/body
- CORS currently open (`*`)
- error responses may expose internal exception message text
- DB credentials are currently present in local config file

This project is functionally rich for capstone/demo workflows, but security hardening is still required for production.

## 11) Suggested AI Voice Session Agenda

If this repo + this file are given to another AI, use this order:

1. Read this file fully.
2. Read `docs/swap_user_cases.md` to understand expected behavior.
3. Read core backend services:
   - `SwapOfferService.java`
   - `SwapRequestService.java`
   - `EnrollmentService.java`
4. Read frontend flow files:
   - `App.jsx`
   - `StudentSchedulePage.jsx`
   - `SectionPickerModal.jsx`
   - `TradingPage.jsx`
   - `MySwapsPage.jsx`
5. Validate assumptions against `data/test cases.sql` and run scenario tests.
6. Propose changes in small, reviewable patches.

## 12) Current Goal for Continuation

Continue improving usability and correctness of swap workflows while preserving existing business constraints.
If a change affects rules, update both:
- `docs/swap_user_cases.md`
- SQL seed/cleanup scripts used for reproducible testing.
