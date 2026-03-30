import { useEffect, useMemo, useState } from "react";
import { addStudentSection, createTrade, getPortalSections } from "../api";
import "../styles/section-picker-modal.css";

const SCHOOL_OPTIONS = [
  "School of Computing and Informatics",
  "School of Social and Basic Sciences",
];

function SectionPickerModal({
  studentId,
  registeredSections,
  isOpen,
  onClose,
  onAdded,
  mode = "add",
  offeredSection = null,
}) {
  const [allSections, setAllSections] = useState([]);
  const [schoolName, setSchoolName] = useState("");
  const [loading, setLoading] = useState(false);
  const [submittingId, setSubmittingId] = useState(null);
  const [expandedCourses, setExpandedCourses] = useState({});

  useEffect(() => {
    if (!isOpen) return;

    const loadSections = async () => {
      try {
        setLoading(true);
        const data = await getPortalSections();
        setAllSections(data);
      } catch (error) {
        alert(error.message);
      } finally {
        setLoading(false);
      }
    };

    loadSections();
  }, [isOpen]);

  const visibleSections = useMemo(() => {
    if (!schoolName) return allSections;
    return allSections.filter((item) => item.schoolName === schoolName);
  }, [allSections, schoolName]);

  const groupedCourses = useMemo(() => {
    const map = new Map();

    for (const section of visibleSections) {
      const key = section.courseNumber;

      if (!map.has(key)) {
        map.set(key, {
          courseNumber: section.courseNumber,
          courseName: section.courseName,
          hours: section.hours,
          sections: [],
        });
      }

      map.get(key).sections.push(section);
    }

    return Array.from(map.values());
  }, [visibleSections]);

  const registeredPortalSectionIds = useMemo(() => {
    return new Set(registeredSections.map((item) => item.id));
  }, [registeredSections]);

  const isAlreadyRegistered = (section) => {
    return registeredPortalSectionIds.has(section.id);
  };

  const hasBasicConflict = (section) => {
    return registeredSections.some((registered) => {
      if (offeredSection && registered.id === offeredSection.id) {
        return false;
      }

      const sameCourse = registered.courseNumber === section.courseNumber;
      const sameTime =
        registered.timeClassroom &&
        section.timeClassroom &&
        registered.timeClassroom.trim() === section.timeClassroom.trim();

      return sameCourse || sameTime;
    });
  };

  const isSameAsOffered = (section) => {
    return offeredSection && section.id === offeredSection.id;
  };

  const handleSelect = async (portalSectionId) => {
    try {
      setSubmittingId(portalSectionId);

      let message = "";

      if (mode === "add") {
        message = await addStudentSection(studentId, portalSectionId);
      } else {
        message = await createTrade(studentId, offeredSection.id, portalSectionId);
      }

      alert(message);
      onAdded();
      onClose();
    } catch (error) {
      alert(error.message);
    } finally {
      setSubmittingId(null);
    }
  };

  const toggleCourse = (courseNumber) => {
    setExpandedCourses((prev) => ({
      ...prev,
      [courseNumber]: !prev[courseNumber],
    }));
  };

  if (!isOpen) return null;

  return (
    <div className="modal-overlay">
      <div className="section-modal portal-like-modal">
        <div className="section-modal-header">
          <h2>
            {mode === "add" ? "Available Semester Courses" : "Create Trade Request"}
          </h2>
          <button className="modal-close-btn" onClick={onClose}>
            ×
          </button>
        </div>

        {mode === "trade" && offeredSection && (
          <div className="trade-offered-box">
            <strong>Offering:</strong> {offeredSection.courseNumber} -{" "}
            {offeredSection.courseName} (Section {offeredSection.sectionNumber})
          </div>
        )}

        <div className="section-modal-filters">
          <label>College:</label>
          <select
            value={schoolName}
            onChange={(e) => setSchoolName(e.target.value)}
          >
            <option value="">All schools</option>
            {SCHOOL_OPTIONS.map((school) => (
              <option key={school} value={school}>
                {school}
              </option>
            ))}
          </select>
        </div>

        {loading ? (
          <div className="section-modal-empty">Loading sections...</div>
        ) : groupedCourses.length === 0 ? (
          <div className="section-modal-empty">No courses found.</div>
        ) : (
          <div className="course-group-list">
            {groupedCourses.map((course) => {
              const isExpanded = !!expandedCourses[course.courseNumber];

              return (
                <div className="course-group-card" key={course.courseNumber}>
                  <table className="course-summary-table">
                    <thead>
                      <tr>
                        <th className="action-col">Action</th>
                        <th>Course Number</th>
                        <th>Course Name</th>
                        <th>Number of Hours</th>
                        <th>Course Level</th>
                        <th>Price Per Hour</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr>
                        <td>
                          <button
                            className="expand-course-btn"
                            onClick={() => toggleCourse(course.courseNumber)}
                          >
                            {isExpanded ? "-" : "+"}
                          </button>
                        </td>
                        <td>{course.courseNumber}</td>
                        <td>{course.courseName}</td>
                        <td>{course.hours}</td>
                        <td>-</td>
                        <td>75</td>
                      </tr>
                    </tbody>
                  </table>

                  {isExpanded && (
                    <div className="expanded-sections-box">
                      <table className="expanded-sections-table">
                        <thead>
                          <tr>
                            <th>Choice</th>
                            <th>Practical Section</th>
                            <th>Theoretical Section</th>
                            <th>Time / Classroom</th>
                            <th>Instructor Name</th>
                            <th>Number of Hours</th>
                            <th>Section Capacity</th>
                            <th>Course Level</th>
                            <th>Price Per Hour</th>
                          </tr>
                        </thead>
                        <tbody>
                          {course.sections.map((section) => {
                            const alreadyRegistered = isAlreadyRegistered(section);
                            const conflict = hasBasicConflict(section);
                            const sameAsOffered = isSameAsOffered(section);

                            let buttonClass = "inner-add-btn";
                            let buttonText = mode === "add" ? "Add" : "Request Trade";
                            let disabled = false;

                            if (sameAsOffered) {
                              buttonClass = "inner-registered-btn";
                              buttonText = "Current Section";
                              disabled = true;
                            } else if (mode === "add" && alreadyRegistered) {
                              buttonClass = "inner-registered-btn";
                              buttonText = "Registered";
                              disabled = true;
                            } else if (conflict) {
                              buttonClass = "inner-conflict-btn";
                              buttonText = "Conflict";
                              disabled = true;
                            }

                            if (submittingId === section.id) {
                              buttonText =
                                mode === "add" ? "Adding..." : "Sending...";
                              disabled = true;
                            }

                            return (
                              <tr key={section.id}>
                                <td>
                                  <button
                                    className={`inner-action-btn ${buttonClass}`}
                                    disabled={disabled}
                                    onClick={() => handleSelect(section.id)}
                                  >
                                    {buttonText}
                                  </button>
                                </td>
                                <td>{section.sectionNumber}</td>
                                <td>{section.theoretical}</td>
                                <td className="modal-time-cell">
                                  {section.timeClassroom || "-"}
                                </td>
                                <td>{section.instructorName || "-"}</td>
                                <td>{section.hours}</td>
                                <td>15</td>
                                <td>-</td>
                                <td>75</td>
                              </tr>
                            );
                          })}
                        </tbody>
                      </table>
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}

export default SectionPickerModal;