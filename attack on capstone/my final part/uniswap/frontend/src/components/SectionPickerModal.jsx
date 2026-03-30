import { useEffect, useMemo, useState } from "react";
import { getAllSections, addStudentSection, createOffer, getCompletedCourses } from "../api";
import "../styles/section-picker-modal.css";

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
  const [completedCodes, setCompletedCodes] = useState([]);
  const [loading, setLoading] = useState(false);
  const [submittingId, setSubmittingId] = useState(null);
  const [expandedCourses, setExpandedCourses] = useState({});

  useEffect(() => {
    if (!isOpen) return;

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

    loadData();
  }, [isOpen]);

  // Group sections by course code
  const groupedCourses = useMemo(() => {
    const map = new Map();

    for (const section of allSections) {
      const key = section.course?.courseCode || section.sectionId;

      if (!map.has(key)) {
        map.set(key, {
          courseCode: section.course?.courseCode,
          courseName: section.course?.courseName,
          credits: section.course?.credits,
          prerequisiteCourseCode: section.course?.prerequisiteCourseCode,
          sections: [],
        });
      }

      map.get(key).sections.push(section);
    }

    return Array.from(map.values());
  }, [allSections]);

  // Set of enrolled section IDs
  const registeredSectionIds = useMemo(() => {
    return new Set(registeredSections.map((enr) => enr.section?.sectionId));
  }, [registeredSections]);

  // Set of enrolled course codes
  const registeredCourseCodes = useMemo(() => {
    return new Set(registeredSections.map((enr) => enr.section?.course?.courseCode));
  }, [registeredSections]);

  const isAlreadyRegistered = (section) => {
    return registeredSectionIds.has(section.sectionId);
  };

  const isCompleted = (section) => {
    return completedCodes.includes(section.course?.courseCode);
  };

  const isMissingPrerequisite = (section) => {
    const prereq = section.course?.prerequisiteCourseCode;
    if (!prereq) return false;
    return !completedCodes.includes(prereq);
  };

  const hasTimeConflict = (section) => {
    return registeredSections.some((enr) => {
      // In trade mode, exclude the section being offered (it'll be gone after trade)
      if (offeredSection && enr.section?.sectionId === offeredSection.section?.sectionId) {
        return false;
      }

      // Same course check (already enrolled in another section of same course)
      const sameCourse = enr.section?.course?.courseCode === section.course?.courseCode;

      // Time overlap check using schedule string
      const sameTime =
        enr.section?.schedule &&
        section.schedule &&
        enr.section.schedule.trim() === section.schedule.trim();

      return sameCourse || sameTime;
    });
  };

  const isSameAsOffered = (section) => {
    return offeredSection && section.sectionId === offeredSection.section?.sectionId;
  };

  const getSectionStatus = (section) => {
    if (isSameAsOffered(section)) return { status: "current", text: "Current Section", className: "inner-registered-btn" };
    if (mode === "add" && isAlreadyRegistered(section)) return { status: "registered", text: "Registered", className: "inner-registered-btn" };
    if (isCompleted(section)) return { status: "completed", text: "Completed", className: "inner-registered-btn" };
    if (isMissingPrerequisite(section)) return { status: "prereq", text: "Missing Prereq", className: "inner-conflict-btn" };
    if (hasTimeConflict(section)) return { status: "conflict", text: "Conflict", className: "inner-conflict-btn" };
    return { status: "eligible", text: mode === "add" ? "Add" : "Request Trade", className: "inner-add-btn" };
  };

  const handleSelect = async (sectionId) => {
    try {
      setSubmittingId(sectionId);

      if (mode === "add") {
        await addStudentSection(studentId, sectionId);
        alert("Section added successfully!");
      } else {
        // Trade mode — create swap offer
        const haveSectionId = offeredSection.section?.sectionId;
        await createOffer(studentId, haveSectionId, sectionId, "SECTION_SWAP");
        alert("Trade offer created!");
      }

      onAdded();
      onClose();
    } catch (error) {
      alert(error.message);
    } finally {
      setSubmittingId(null);
    }
  };

  const toggleCourse = (courseCode) => {
    setExpandedCourses((prev) => ({
      ...prev,
      [courseCode]: !prev[courseCode],
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
            <strong>Offering:</strong> {offeredSection.section?.course?.courseCode} -{" "}
            {offeredSection.section?.course?.courseName} (Section {offeredSection.section?.sectionNumber})
          </div>
        )}

        {loading ? (
          <div className="section-modal-empty">Loading sections...</div>
        ) : groupedCourses.length === 0 ? (
          <div className="section-modal-empty">No courses found.</div>
        ) : (
          <div className="course-group-list">
            {groupedCourses.map((course) => {
              const isExpanded = !!expandedCourses[course.courseCode];

              return (
                <div className="course-group-card" key={course.courseCode}>
                  <table className="course-summary-table">
                    <thead>
                      <tr>
                        <th className="action-col">Action</th>
                        <th>Course Number</th>
                        <th>Course Name</th>
                        <th>Number of Hours</th>
                        <th>Prerequisite</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr>
                        <td>
                          <button
                            className="expand-course-btn"
                            onClick={() => toggleCourse(course.courseCode)}
                          >
                            {isExpanded ? "-" : "+"}
                          </button>
                        </td>
                        <td>{course.courseCode}</td>
                        <td>{course.courseName}</td>
                        <td>{course.credits}</td>
                        <td>{course.prerequisiteCourseCode || "-"}</td>
                      </tr>
                    </tbody>
                  </table>

                  {isExpanded && (
                    <div className="expanded-sections-box">
                      <table className="expanded-sections-table">
                        <thead>
                          <tr>
                            <th>Choice</th>
                            <th>Section Number</th>
                            <th>Time / Schedule</th>
                            <th>Instructor Name</th>
                            <th>Number of Hours</th>
                            <th>Capacity</th>
                          </tr>
                        </thead>
                        <tbody>
                          {course.sections.map((section) => {
                            const { status, text, className } = getSectionStatus(section);
                            const isDisabled = status !== "eligible";
                            const isSubmitting = submittingId === section.sectionId;

                            return (
                              <tr key={section.sectionId}>
                                <td>
                                  <button
                                    className={`inner-action-btn ${className}`}
                                    disabled={isDisabled || isSubmitting}
                                    onClick={() => handleSelect(section.sectionId)}
                                  >
                                    {isSubmitting
                                      ? mode === "add" ? "Adding..." : "Sending..."
                                      : text}
                                  </button>
                                </td>
                                <td>{section.sectionNumber}</td>
                                <td className="modal-time-cell">
                                  {section.schedule || "-"}
                                </td>
                                <td>{section.instructor || "-"}</td>
                                <td>{section.course?.credits}</td>
                                <td>{section.capacity ?? "-"}</td>
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
