import { useEffect, useState } from "react";
import PortalLayout from "./PortalLayout";
import { getPortalSections } from "../api";
import "../styles/available-courses.css";

const SCHOOL_OPTIONS = [
  "School of Computing and Informatics",
  "School of Social and Basic Sciences",
];

function AvailableCoursesPage({ studentId, onNavigate ,onLogout }) {
  const [schoolName, setSchoolName] = useState("");
  const [allSections, setAllSections] = useState([]);
  const [filteredSections, setFilteredSections] = useState([]);
  const [loading, setLoading] = useState(false);

  const loadSections = async () => {
    try {
      setLoading(true);
      const data = await getPortalSections();
      setAllSections(data);
      setFilteredSections(data);
    } catch (error) {
      alert(error.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadSections();
  }, []);

  const handleSearch = () => {
    if (!schoolName) {
      setFilteredSections(allSections);
      return;
    }

    const filtered = allSections.filter(
      (item) => item.schoolName === schoolName
    );

    setFilteredSections(filtered);
  };

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

        <div className="portal-alert-box">
          Your Pearson certificate has been claimed
        </div>

        <h2 className="courses-title">View Courses List</h2>

        <div className="courses-filters">
          <div className="filter-group">
            <label>College:</label>
            <select
              value={schoolName}
              onChange={(e) => setSchoolName(e.target.value)}
            >
              <option value="">Please select the school</option>
              {SCHOOL_OPTIONS.map((school) => (
                <option key={school} value={school}>
                  {school}
                </option>
              ))}
            </select>
          </div>

          <div className="filter-button-row">
            <button onClick={handleSearch}>Search</button>
          </div>
        </div>

        {loading ? (
          <div className="courses-empty">Loading courses...</div>
        ) : filteredSections.length === 0 ? (
          <div className="courses-empty">No courses found.</div>
        ) : (
          <div className="courses-table-wrapper">
            <table className="courses-table">
              <thead>
                <tr>
                  <th>#</th>
                  <th>Course Number</th>
                  <th>Section Number</th>
                  <th>Theoretical</th>
                  <th>Course Name</th>
                  <th>Hours</th>
                  <th>Instructor Name</th>
                  <th>Time / Classroom</th>
                  <th>Prerequisite Course</th>
                </tr>
              </thead>
              <tbody>
                {filteredSections.map((item, index) => (
                  <tr key={item.id}>
                    <td>{index + 1}</td>
                    <td>{item.courseNumber}</td>
                    <td>{item.sectionNumber}</td>
                    <td>{item.theoretical}</td>
                    <td>{item.courseName}</td>
                    <td>{item.hours}</td>
                    <td>{item.instructorName || "-"}</td>
                    <td>{item.timeClassroom || "-"}</td>
                    <td>{item.prerequisiteCourse || "-"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </PortalLayout>
  );
}

export default AvailableCoursesPage;