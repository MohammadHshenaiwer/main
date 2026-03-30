import { useEffect, useState } from "react";
import PortalLayout from "./PortalLayout";
import { getAllSections, getCompletedCourses } from "../api";
import "../styles/available-courses.css";

function AvailableCoursesPage({ studentId, onNavigate, onLogout }) {
  const [allSections, setAllSections] = useState([]);
  const [completedCodes, setCompletedCodes] = useState([]);
  const [loading, setLoading] = useState(false);

  const loadData = async () => {
    try {
      setLoading(true);
      const [sections, completed] = await Promise.all([
        getAllSections(),
        getCompletedCourses(studentId),
      ]);
      setAllSections(sections || []);
      setCompletedCodes(completed || []);
    } catch (error) {
      alert(error.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  return (
    <PortalLayout
      studentId={studentId}
      title="Available Courses"
      currentPage="courses"
      onNavigate={onNavigate}
      onLogout={onLogout}
    >
      <div className="portal-page-card">
        <h2 className="portal-page-heading">Student Portal</h2>


        <h2 className="courses-title">View Courses List</h2>

        {loading ? (
          <div className="courses-empty">Loading courses...</div>
        ) : allSections.length === 0 ? (
          <div className="courses-empty">No courses found.</div>
        ) : (
          <div className="courses-table-wrapper">
            <table className="courses-table">
              <thead>
                <tr>
                  <th>#</th>
                  <th>Course Number</th>
                  <th>Section Number</th>
                  <th>Course Name</th>
                  <th>Hours</th>
                  <th>Instructor Name</th>
                  <th>Time / Schedule</th>
                  <th>Prerequisite Course</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                {allSections.map((section, index) => {
                  const code = section.course?.courseCode;
                  const isCompleted = completedCodes.includes(code);
                  const prereq = section.course?.prerequisiteCourseCode;
                  const missingPrereq = prereq && !completedCodes.includes(prereq);

                  return (
                    <tr key={section.sectionId}>
                      <td>{index + 1}</td>
                      <td>{section.course?.courseCode || "-"}</td>
                      <td>{section.sectionNumber}</td>
                      <td>{section.course?.courseName || "-"}</td>
                      <td>{section.course?.credits ?? "-"}</td>
                      <td>{section.instructor || "-"}</td>
                      <td>{section.schedule || "-"}</td>
                      <td>{section.course?.prerequisiteCourseCode || "-"}</td>
                      <td>
                        {isCompleted ? (
                          <span style={{ color: "#16a34a", fontWeight: "bold" }}>✓ Completed</span>
                        ) : missingPrereq ? (
                          <span style={{ color: "#dc2626", fontWeight: "bold" }}>⚠ Missing Prereq</span>
                        ) : (
                          <span style={{ color: "#2563eb", fontWeight: "bold" }}>Available</span>
                        )}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </PortalLayout>
  );
}

export default AvailableCoursesPage;
