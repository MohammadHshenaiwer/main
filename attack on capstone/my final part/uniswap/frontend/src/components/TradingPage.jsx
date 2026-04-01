import { useEffect, useMemo, useState } from "react";
import PortalLayout from "./PortalLayout";
import {
  getOpenOffers,
  acceptDirectTrade,
  cancelOffer,
  getStudentSchedule,
  getCompletedCourses,
} from "../api";
import "../styles/trading.css";

const normalizeCode = (value) => String(value ?? "").trim();
const DAY_OPTIONS = ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu"];

const hasDaysOverlap = (days1, days2) => {
  if (!days1 || !days2) return false;

  const left = String(days1)
    .split("/")
    .map((d) => d.trim())
    .filter(Boolean);
  const right = String(days2)
    .split("/")
    .map((d) => d.trim())
    .filter(Boolean);

  return left.some((day) => right.includes(day));
};

const timeToMinutes = (value) => {
  if (!value) return null;
  const [h, m] = String(value).split(":");
  const hours = Number(h);
  const minutes = Number(m);
  if (Number.isNaN(hours) || Number.isNaN(minutes)) return null;
  return hours * 60 + minutes;
};

const hasTimeOverlap = (s1, e1, s2, e2) => {
  const start1 = timeToMinutes(s1);
  const end1 = timeToMinutes(e1);
  const start2 = timeToMinutes(s2);
  const end2 = timeToMinutes(e2);

  if (
    start1 === null ||
    end1 === null ||
    start2 === null ||
    end2 === null
  ) {
    return false;
  }

  return start1 < end2 && start2 < end1;
};

const splitDays = (value) => {
  if (!value) return [];
  return String(value)
    .split("/")
    .map((day) => day.trim())
    .filter(Boolean);
};

function TradingPage({
  studentId,
  studentName,
  studentNumber,
  studentYear,
  onNavigate,
  onLogout,
}) {
  const [trades, setTrades] = useState([]);
  const [loading, setLoading] = useState(true);
  const [acceptingOfferId, setAcceptingOfferId] = useState(null);
  const [cancellingOfferId, setCancellingOfferId] = useState(null);
  const [registeredSections, setRegisteredSections] = useState([]);
  const [completedCodes, setCompletedCodes] = useState([]);
  const [acceptabilityFilter, setAcceptabilityFilter] = useState("all");
  const [wantedSearch, setWantedSearch] = useState("");
  const [selectedDays, setSelectedDays] = useState([]);
  const [timeFrom, setTimeFrom] = useState("");
  const [timeTo, setTimeTo] = useState("");

  useEffect(() => {
    loadTradingData();
  }, [studentId]);

  const loadTradingData = async () => {
    try {
      setLoading(true);
      const [offers, schedule, completed] = await Promise.all([
        getOpenOffers(studentId),
        getStudentSchedule(studentId),
        getCompletedCourses(studentId),
      ]);

      setTrades(offers || []);
      setRegisteredSections(schedule || []);
      setCompletedCodes(Array.isArray(completed) ? completed : []);
    } catch (error) {
      alert(error.message || "Failed to load trading data");
    } finally {
      setLoading(false);
    }
  };

  const enrolledSectionIds = useMemo(() => {
    return new Set(
      (registeredSections || [])
        .map((enr) => enr.section?.sectionId)
        .filter((value) => value != null)
    );
  }, [registeredSections]);

  const completedCodeSet = useMemo(() => {
    return new Set(
      (completedCodes || []).map((value) => normalizeCode(value)).filter(Boolean)
    );
  }, [completedCodes]);

  const eligibilityByOfferId = useMemo(() => {
    const map = new Map();

    for (const offer of trades) {
      const wantedSectionId = offer.wantSection?.sectionId;
      const incomingSection = offer.haveSection;

      if (!wantedSectionId || !incomingSection) {
        map.set(offer.offerId, {
          canAccept: false,
          reason: "Offer data is incomplete.",
        });
        continue;
      }

      if (!enrolledSectionIds.has(wantedSectionId)) {
        map.set(offer.offerId, {
          canAccept: false,
          reason: "You do not own the requested section.",
        });
        continue;
      }

      const incomingCourseCode = normalizeCode(incomingSection.course?.courseCode);
      if (incomingCourseCode && completedCodeSet.has(incomingCourseCode)) {
        map.set(offer.offerId, {
          canAccept: false,
          reason: "You already completed this target course.",
        });
        continue;
      }

      const prereqCode = normalizeCode(
        incomingSection.course?.prerequisiteCourseCode
      );
      if (prereqCode && !completedCodeSet.has(prereqCode)) {
        map.set(offer.offerId, {
          canAccept: false,
          reason: "Missing prerequisite for the target course.",
        });
        continue;
      }

      let hasConflict = false;
      for (const enrollment of registeredSections) {
        const existing = enrollment.section;
        if (!existing || existing.sectionId === wantedSectionId) {
          continue;
        }

        if (
          hasDaysOverlap(existing.dayOfWeek, incomingSection.dayOfWeek) &&
          hasTimeOverlap(
            existing.startTime,
            existing.endTime,
            incomingSection.startTime,
            incomingSection.endTime
          )
        ) {
          hasConflict = true;
          break;
        }
      }

      if (hasConflict) {
        map.set(offer.offerId, {
          canAccept: false,
          reason: "Time conflict after swap.",
        });
        continue;
      }

      map.set(offer.offerId, { canAccept: true, reason: "Eligible" });
    }

    return map;
  }, [trades, enrolledSectionIds, completedCodeSet, registeredSections]);

  const filteredTrades = useMemo(() => {
    const wantedNeedle = wantedSearch.trim().toLowerCase();
    const fromMinutes = timeFrom ? timeToMinutes(timeFrom) : null;
    const toMinutes = timeTo ? timeToMinutes(timeTo) : null;

    return trades.filter((offer) => {
      const eligibility = eligibilityByOfferId.get(offer.offerId);
      const canAccept = eligibility?.canAccept ?? false;

      if (acceptabilityFilter === "can" && !canAccept) return false;
      if (acceptabilityFilter === "cannot" && canAccept) return false;

      const wantedSection = offer.wantSection;

      if (selectedDays.length > 0) {
        const wantedDays = splitDays(wantedSection?.dayOfWeek);
        if (!selectedDays.some((day) => wantedDays.includes(day))) {
          return false;
        }
      }

      if (fromMinutes !== null || toMinutes !== null) {
        const sectionStart = timeToMinutes(wantedSection?.startTime);
        const sectionEnd = timeToMinutes(wantedSection?.endTime);

        if (sectionStart === null || sectionEnd === null) {
          return false;
        }

        const filterStart = fromMinutes ?? 0;
        const filterEnd = toMinutes ?? 24 * 60;

        if (filterStart >= filterEnd) {
          return false;
        }

        const overlaps = sectionStart < filterEnd && filterStart < sectionEnd;
        if (!overlaps) {
          return false;
        }
      }

      if (!wantedNeedle) return true;

      const wanted = wantedSection;
      const haystack = [
        wanted?.course?.courseName,
        wanted?.course?.courseCode,
        wanted?.sectionNumber,
      ]
        .map((value) => String(value ?? "").toLowerCase())
        .join(" ");

      return haystack.includes(wantedNeedle);
    });
  }, [
    trades,
    eligibilityByOfferId,
    acceptabilityFilter,
    wantedSearch,
    selectedDays,
    timeFrom,
    timeTo,
  ]);

  const toggleDay = (day) => {
    setSelectedDays((prev) =>
      prev.includes(day) ? prev.filter((item) => item !== day) : [...prev, day]
    );
  };

  const handleAcceptTrade = async (offer) => {
    const confirmed = window.confirm("Are you sure you want to accept this trade?");
    if (!confirmed) return;

    try {
      setAcceptingOfferId(offer.offerId);
      // The accepter offers the section the poster wants
      await acceptDirectTrade(studentId, offer.offerId, offer.wantSection?.sectionId);
      alert("🎉 Trade Accepted! Your schedule has been updated.");
      await loadTradingData();
    } catch (error) {
      alert(error.message || "Failed to accept trade");
    } finally {
      setAcceptingOfferId(null);
    }
  };

  const handleCancelTrade = async (offerId) => {
    try {
      setCancellingOfferId(offerId);
      await cancelOffer(studentId, offerId);
      alert("Trade cancelled.");
      await loadTradingData();
    } catch (error) {
      alert(error.message || "Failed to cancel trade");
    } finally {
      setCancellingOfferId(null);
    }
  };

  return (
    <PortalLayout
      studentId={studentId}
      studentName={studentName}
      studentNumber={studentNumber}
      studentYear={studentYear}
      title="Trading Page"
      currentPage="trading"
      onNavigate={onNavigate}
      onLogout={onLogout}
    >
      <div className="trading-page-wrapper">
        <h2 className="trading-main-title">Available Trade Offers</h2>
        <p className="trading-subtitle">
          View active offers and accept a suitable section swap.
        </p>

        <div className="trading-filters-box">
          <div className="trading-filter-item">
            <label htmlFor="acceptability-filter">Show offers</label>
            <select
              id="acceptability-filter"
              value={acceptabilityFilter}
              onChange={(event) => setAcceptabilityFilter(event.target.value)}
            >
              <option value="all">All offers</option>
              <option value="can">Only what I can accept</option>
              <option value="cannot">Only not-eligible offers</option>
            </select>
          </div>

          <div className="trading-filter-item trading-filter-grow">
            <label htmlFor="wanted-search">Search wanted course</label>
            <input
              id="wanted-search"
              type="text"
              value={wantedSearch}
              placeholder="Course name, code, or section number"
              onChange={(event) => setWantedSearch(event.target.value)}
            />
          </div>

          <div className="trading-filter-item">
            <label htmlFor="wanted-time-from">Wanted hour (from)</label>
            <input
              id="wanted-time-from"
              type="time"
              value={timeFrom}
              onChange={(event) => setTimeFrom(event.target.value)}
            />
          </div>

          <div className="trading-filter-item">
            <label htmlFor="wanted-time-to">Wanted hour (to)</label>
            <input
              id="wanted-time-to"
              type="time"
              value={timeTo}
              onChange={(event) => setTimeTo(event.target.value)}
            />
          </div>
        </div>

        <div className="trading-days-filter-box">
          <div className="trading-days-label">Wanted days</div>
          <div className="trading-days-list">
            {DAY_OPTIONS.map((day) => {
              const active = selectedDays.includes(day);
              return (
                <button
                  key={day}
                  type="button"
                  className={`trading-day-chip ${active ? "active" : ""}`}
                  onClick={() => toggleDay(day)}
                >
                  {day}
                </button>
              );
            })}
            <button
              type="button"
              className="trading-day-chip clear"
              onClick={() => setSelectedDays([])}
            >
              Clear Days
            </button>
          </div>
        </div>

        {loading ? (
          <div className="trading-empty-box">Loading trades...</div>
        ) : trades.length === 0 ? (
          <div className="trading-empty-box">No active trades found.</div>
        ) : filteredTrades.length === 0 ? (
          <div className="trading-empty-box">
            No offers match your current filters.
          </div>
        ) : (
          <div className="trading-list">
            {filteredTrades.map((offer) => {
              const isOwner = String(offer.student?.studentId) === String(studentId);
              const eligibility = eligibilityByOfferId.get(offer.offerId) || {
                canAccept: false,
                reason: "Not eligible",
              };
              const hSec = offer.haveSection;
              const wSec = offer.wantSection;

              return (
                <div className="trading-card-row" key={offer.offerId}>
                  <div className="trading-side-card">
                    <div className="trading-side-title">Student Offers</div>

                    <div className="trading-student-box">
                      <div className="trading-student-avatar">👤</div>
                      <div>
                        <div className="trading-student-name">{offer.student?.name || "Student"}</div>
                        <div className="trading-student-id">
                          ID: {offer.student?.studentId}
                        </div>
                      </div>
                    </div>

                    <hr className="trading-divider" />

                    <div className="trading-section-label">
                      Course Section Offered
                    </div>

                    <div className="trading-section-box">
                      <div>
                        <strong>Course Name:</strong>{" "}
                        {hSec?.course?.courseName || "-"}
                      </div>
                      <div>
                        <strong>Section:</strong>{" "}
                        {hSec?.sectionNumber ?? "-"}
                      </div>
                      <div>
                        <strong>Course No:</strong>{" "}
                        {hSec?.course?.courseCode || "-"}
                      </div>
                      <div>
                        <strong>Instructor:</strong>{" "}
                        {hSec?.instructor || "-"}
                      </div>
                      <div>
                        <strong>Schedule:</strong> {hSec?.schedule || "-"}
                      </div>
                    </div>
                  </div>

                  <div className="trading-arrow-center">
                    <div className="trading-arrow-icon">⇄</div>
                    <div className="trading-arrow-text">TRADE</div>
                  </div>

                  <div className="trading-side-card">
                    <div className="trading-side-title">Student Wants</div>

                    <div className="trading-section-label">
                      Course Section Wanted
                    </div>

                    <div
                      className={`trading-eligibility-badge ${
                        eligibility.canAccept ? "ok" : "blocked"
                      }`}
                    >
                      {eligibility.canAccept
                        ? "Can accept"
                        : `Not eligible: ${eligibility.reason}`}
                    </div>

                    <div className="trading-section-box">
                      <div>
                        <strong>Course Name:</strong>{" "}
                        {wSec?.course?.courseName || "-"}
                      </div>
                      <div>
                        <strong>Section:</strong>{" "}
                        {wSec?.sectionNumber ?? "-"}
                      </div>
                      <div>
                        <strong>Course No:</strong>{" "}
                        {wSec?.course?.courseCode || "-"}
                      </div>
                      <div>
                        <strong>Instructor:</strong>{" "}
                        {wSec?.instructor || "-"}
                      </div>
                      <div>
                        <strong>Schedule:</strong> {wSec?.schedule || "-"}
                      </div>
                    </div>

                    {isOwner ? (
                      <button
                        className="trading-cancel-btn"
                        onClick={() => handleCancelTrade(offer.offerId)}
                        disabled={cancellingOfferId === offer.offerId}
                      >
                        {cancellingOfferId === offer.offerId
                          ? "Cancelling..."
                          : "Cancel Trade"}
                      </button>
                    ) : (
                      <button
                        className="trading-accept-btn"
                        onClick={() => handleAcceptTrade(offer)}
                        disabled={
                          acceptingOfferId === offer.offerId || !eligibility.canAccept
                        }
                      >
                        {acceptingOfferId === offer.offerId
                          ? "Accepting..."
                          : eligibility.canAccept
                          ? "Accept Trade"
                          : "Cannot Accept"}
                      </button>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </PortalLayout>
  );
}

export default TradingPage;
