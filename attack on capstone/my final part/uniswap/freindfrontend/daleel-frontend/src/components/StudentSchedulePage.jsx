import { useEffect, useState } from "react";
import PortalLayout from "./PortalLayout";
import SectionPickerModal from "./SectionPickerModal";
import { getStudentSchedule, removeStudentSection } from "../api";
import "../styles/student-schedule.css";

function StudentSchedulePage({ studentId, onNavigate, onLogout }) {
  const [schedule, setSchedule] = useState([]);
  const [loading, setLoading] = useState(false);

  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [isTradeModalOpen, setIsTradeModalOpen] = useState(false);
  const [selectedTradeSection, setSelectedTradeSection] = useState(null);

  const loadSchedule = async () => {
    try {
      setLoading(true);
      const data = await getStudentSchedule(studentId);
      setSchedule(data);
    } catch (error) {
      alert(error.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadSchedule();
  }, []);

  const handleDelete = async (portalSectionId) => {
    const confirmed = window.confirm("Are you sure you want to delete this section?");
    if (!confirmed) return;

    try {
      const message = await removeStudentSection(studentId, portalSectionId);
      alert(message);
      loadSchedule();
    } catch (error) {
      alert(error.message);
    }
  };

  const handleTrade = (section) => {
    setSelectedTradeSection(section);
    setIsTradeModalOpen(true);
  };

  return (
    <>
      <PortalLayout
        studentId={studentId}
        title="Student Schedule"
        currentPage="schedule"
        onNavigate={onNavigate}
        onLogout={onLogout}
      >
        <div className="portal-page-card">
          <h2 className="portal-page-heading">Student Portal</h2>

          <div className="portal-alert-box">
            Your Pearson certificate has been claimed
          </div>

          <div className="schedule-toolbar">
            <div className="schedule-filter">
              <label>Year :</label>
              <select defaultValue="2025">
                <option>2025</option>
              </select>
            </div>

            <div className="schedule-filter">
              <label>Semester :</label>
              <select defaultValue="Second">
                <option>First</option>
                <option>Second</option>
                <option>Summer</option>
              </select>
            </div>

            <div className="schedule-actions-top">
              <button
                className="schedule-add-btn"
                onClick={() => setIsAddModalOpen(true)}
              >
                Add Section
              </button>

              <button
                className="schedule-print-btn"
                onClick={() => window.print()}
              >
                Print
              </button>
            </div>
          </div>

          {loading ? (
            <div className="schedule-empty">Loading schedule...</div>
          ) : schedule.length === 0 ? (
            <div className="schedule-empty">No registered sections.</div>
          ) : (
            <div className="schedule-table-wrapper">
              <table className="schedule-table">
                <thead>
                  <tr>
                    <th>Course Number</th>
                    <th>Course Name</th>
                    <th>Theoretical Section</th>
                    <th>Section Number</th>
                    <th>Time / Classroom</th>
                    <th>Instructor Name</th>
                    <th>Number of Hours</th>
                    <th>Course Level</th>
                    <th>Days of absence</th>
                    <th>Actions</th>
                  </tr>
                </thead>

                <tbody>
                  {schedule.map((item) => (
                    <tr key={item.id}>
                      <td>{item.courseNumber}</td>
                      <td>{item.courseName}</td>
                      <td>{item.theoretical}</td>
                      <td>{item.sectionNumber}</td>
                      <td className="time-classroom-cell">
                        {item.timeClassroom || "-"}
                      </td>
                      <td>{item.instructorName || "-"}</td>
                      <td>{item.hours ?? "-"}</td>
                      <td>-</td>
                      <td>0</td>
                      <td>
                        <div className="table-action-buttons">
                          <button
                            className="trade-action-btn"
                            onClick={() => handleTrade(item)}
                          >
                            Trade
                          </button>

                          <button
                            className="delete-action-btn"
                            onClick={() => handleDelete(item.id)}
                          >
                            Delete
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </PortalLayout>

      <SectionPickerModal
        studentId={studentId}
        registeredSections={schedule}
        isOpen={isAddModalOpen}
        onClose={() => setIsAddModalOpen(false)}
        onAdded={loadSchedule}
        mode="add"
      />

      <SectionPickerModal
        studentId={studentId}
        registeredSections={schedule}
        isOpen={isTradeModalOpen}
        onClose={() => {
          setIsTradeModalOpen(false);
          setSelectedTradeSection(null);
        }}
        onAdded={loadSchedule}
        mode="trade"
        offeredSection={selectedTradeSection}
      />
    </>
  );
}

export default StudentSchedulePage;