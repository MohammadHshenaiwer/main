import { useEffect, useState } from "react";
import PortalLayout from "./PortalLayout";
import {
  acceptTrade,
  cancelTrade,
  getActiveTrades,
  getPortalSections,
} from "../api";
import "../styles/trading.css";

function TradingPage({ studentId, onNavigate, onLogout }) {
  const [trades, setTrades] = useState([]);
  const [portalSections, setPortalSections] = useState([]);
  const [loading, setLoading] = useState(true);
  const [acceptingOfferId, setAcceptingOfferId] = useState(null);
  const [cancellingOfferId, setCancellingOfferId] = useState(null);

  useEffect(() => {
    loadTradingData();
  }, []);

  const loadTradingData = async () => {
    try {
      setLoading(true);

      const [tradesData, sectionsData] = await Promise.all([
        getActiveTrades(),
        getPortalSections(),
      ]);

      setTrades(tradesData || []);
      setPortalSections(sectionsData || []);
    } catch (error) {
      alert(error.message || "Failed to load trading data");
    } finally {
      setLoading(false);
    }
  };

  const findSectionById = (sectionId) => {
    if (sectionId === null || sectionId === undefined) return null;

    return (
      portalSections.find(
        (section) => String(section.id) === String(sectionId)
      ) || null
    );
  };

  const parseTimeClassroom = (timeClassroom) => {
    if (!timeClassroom) {
      return {
        time: "-",
        classroom: "-",
      };
    }

    const normalized = timeClassroom.replace(/\s+/g, " ").trim();
    const parts = normalized.split("/");

    if (parts.length >= 2) {
      return {
        time: parts[0].trim(),
        classroom: parts.slice(1).join("/").trim(),
      };
    }

    return {
      time: normalized,
      classroom: "-",
    };
  };

  const visibleTrades = trades
    .filter((trade) => trade.active && !trade.completed)
    .map((trade) => {
      const offeredSection = findSectionById(trade.offeredPortalSectionId);
      const desiredSection = findSectionById(trade.desiredPortalSectionId);

      return {
        ...trade,
        offeredSection,
        desiredSection,
        offeredParsed: parseTimeClassroom(offeredSection?.timeClassroom),
        desiredParsed: parseTimeClassroom(desiredSection?.timeClassroom),
      };
    });

  const handleAcceptTrade = async (offerId) => {
    try {
      setAcceptingOfferId(offerId);
      const message = await acceptTrade(studentId, offerId);
      alert(message);
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
      const message = await cancelTrade(studentId, offerId);
      alert(message);
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

        {loading ? (
          <div className="trading-empty-box">Loading trades...</div>
        ) : visibleTrades.length === 0 ? (
          <div className="trading-empty-box">No active trades found.</div>
        ) : (
          <div className="trading-list">
            {visibleTrades.map((trade) => {
              const isOwner = String(trade.ownerStudentId) === String(studentId);

              return (
                <div className="trading-card-row" key={trade.id}>
                  <div className="trading-side-card">
                    <div className="trading-side-title">Student Offers</div>

                    <div className="trading-student-box">
                      <div className="trading-student-avatar">👤</div>
                      <div>
                        <div className="trading-student-name">Student ID</div>
                        <div className="trading-student-id">
                          {trade.ownerStudentId}
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
                        {trade.offeredSection?.courseName || "-"}
                      </div>
                      <div>
                        <strong>Section:</strong>{" "}
                        {trade.offeredSection?.sectionNumber ?? "-"}
                      </div>
                      <div>
                        <strong>Course No:</strong>{" "}
                        {trade.offeredSection?.courseNumber || "-"}
                      </div>
                      <div>
                        <strong>Instructor:</strong>{" "}
                        {trade.offeredSection?.instructorName || "-"}
                      </div>
                      <div>
                        <strong>Time:</strong> {trade.offeredParsed.time}
                      </div>
                      <div>
                        <strong>Classroom:</strong>{" "}
                        {trade.offeredParsed.classroom}
                      </div>
                      <div>
                        <strong>Offer ID:</strong> {trade.offerId}
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

                    <div className="trading-section-box">
                      <div>
                        <strong>Course Name:</strong>{" "}
                        {trade.desiredSection?.courseName || "-"}
                      </div>
                      <div>
                        <strong>Section:</strong>{" "}
                        {trade.desiredSection?.sectionNumber ?? "-"}
                      </div>
                      <div>
                        <strong>Course No:</strong>{" "}
                        {trade.desiredSection?.courseNumber || "-"}
                      </div>
                      <div>
                        <strong>Instructor:</strong>{" "}
                        {trade.desiredSection?.instructorName || "-"}
                      </div>
                      <div>
                        <strong>Time:</strong> {trade.desiredParsed.time}
                      </div>
                      <div>
                        <strong>Classroom:</strong>{" "}
                        {trade.desiredParsed.classroom}
                      </div>
                    </div>

                    {isOwner ? (
                      <button
                        className="trading-cancel-btn"
                        onClick={() => handleCancelTrade(trade.offerId)}
                        disabled={cancellingOfferId === trade.offerId}
                      >
                        {cancellingOfferId === trade.offerId
                          ? "Cancelling..."
                          : "Cancel Trade"}
                      </button>
                    ) : (
                      <button
                        className="trading-accept-btn"
                        onClick={() => handleAcceptTrade(trade.offerId)}
                        disabled={acceptingOfferId === trade.offerId}
                      >
                        {acceptingOfferId === trade.offerId
                          ? "Accepting..."
                          : "Accept Trade"}
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