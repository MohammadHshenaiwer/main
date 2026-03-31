import { useEffect, useState } from "react";
import PortalLayout from "./PortalLayout";
import { getOpenOffers, acceptDirectTrade, cancelOffer } from "../api";
import "../styles/trading.css";

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

  useEffect(() => {
    loadTradingData();
  }, []);

  const loadTradingData = async () => {
    try {
      setLoading(true);
      const data = await getOpenOffers(studentId);
      setTrades(data || []);
    } catch (error) {
      alert(error.message || "Failed to load trading data");
    } finally {
      setLoading(false);
    }
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

        {loading ? (
          <div className="trading-empty-box">Loading trades...</div>
        ) : trades.length === 0 ? (
          <div className="trading-empty-box">No active trades found.</div>
        ) : (
          <div className="trading-list">
            {trades.map((offer) => {
              const isOwner = String(offer.student?.studentId) === String(studentId);
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
                        disabled={acceptingOfferId === offer.offerId}
                      >
                        {acceptingOfferId === offer.offerId
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
