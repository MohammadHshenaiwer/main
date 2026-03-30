import { useEffect, useState } from "react";
import PortalLayout from "./PortalLayout";
import {
  getMyOffers,
  getIncomingRequests,
  getSentRequests,
  acceptRequest,
  rejectRequest,
  cancelOffer,
  cancelRequest,
} from "../api";
import "../styles/my-swaps.css";

function MySwapsPage({ studentId, onNavigate, onLogout }) {
  const [myOffers, setMyOffers] = useState([]);
  const [incoming, setIncoming] = useState([]);
  const [sent, setSent] = useState([]);
  const [loading, setLoading] = useState(true);

  const loadAll = async () => {
    try {
      setLoading(true);
      const [offers, inc, snt] = await Promise.all([
        getMyOffers(studentId),
        getIncomingRequests(studentId),
        getSentRequests(studentId),
      ]);
      setMyOffers(offers || []);
      setIncoming(inc || []);
      setSent(snt || []);
    } catch (error) {
      alert(error.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadAll();
  }, []);

  const handleAccept = async (requestId) => {
    try {
      await acceptRequest(requestId, studentId);
      alert("🎉 Swap completed! Enrollments updated.");
      loadAll();
    } catch (error) {
      alert(error.message);
    }
  };

  const handleReject = async (requestId) => {
    try {
      await rejectRequest(requestId, studentId);
      alert("Request rejected.");
      loadAll();
    } catch (error) {
      alert(error.message);
    }
  };

  const handleCancelOffer = async (offerId) => {
    try {
      await cancelOffer(studentId, offerId);
      alert("Offer cancelled.");
      loadAll();
    } catch (error) {
      alert(error.message);
    }
  };

  const handleCancelRequest = async (requestId) => {
    try {
      await cancelRequest(requestId, studentId);
      alert("Request cancelled.");
      loadAll();
    } catch (error) {
      alert(error.message);
    }
  };

  const badgeClass = (status) => {
    const map = {
      OPEN: "badge-open",
      PENDING: "badge-pending",
      COMPLETED: "badge-completed",
      CANCELLED: "badge-cancelled",
      ACCEPTED: "badge-accepted",
      REJECTED: "badge-rejected",
    };
    return map[status] || "badge-cancelled";
  };

  return (
    <PortalLayout
      studentId={studentId}
      title="My Swaps"
      currentPage="swaps"
      onNavigate={onNavigate}
      onLogout={onLogout}
    >
      <div className="portal-page-card">
        <h2 className="portal-page-heading">My Swaps</h2>

        {loading ? (
          <div className="swaps-empty">Loading...</div>
        ) : (
          <div className="swaps-grid">
            {/* ── My Posted Offers ── */}
            <div className="swaps-section">
              <h3 className="swaps-section-title">📢 My Posted Offers</h3>
              {myOffers.length === 0 ? (
                <div className="swaps-empty">No offers posted yet.</div>
              ) : (
                myOffers.map((o) => (
                  <div className="swap-card" key={o.offerId}>
                    <div className="swap-card-top">
                      <div>
                        <div className="swap-card-title">
                          {o.haveSection?.course?.courseName || "—"}
                        </div>
                        <div className="swap-card-sub">
                          <span className="swap-blue">
                            Sec {o.haveSection?.sectionNumber}
                          </span>
                          <span className="swap-arrow">⇄</span>
                          <span className="swap-purple">
                            {o.wantSection?.course?.courseName || "—"} Sec{" "}
                            {o.wantSection?.sectionNumber || ""}
                          </span>
                        </div>
                        <div className="swap-card-date">
                          {o.createdAt
                            ? new Date(o.createdAt).toLocaleDateString()
                            : ""}
                        </div>
                      </div>
                      <div className="swap-card-actions">
                        <span className={`swap-badge ${badgeClass(o.status)}`}>
                          {o.status}
                        </span>
                        {(o.status === "OPEN" || o.status === "PENDING") && (
                          <button
                            className="swap-btn-cancel"
                            onClick={() => handleCancelOffer(o.offerId)}
                          >
                            Cancel
                          </button>
                        )}
                      </div>
                    </div>
                  </div>
                ))
              )}
            </div>

            {/* ── Incoming Requests ── */}
            <div className="swaps-section">
              <h3 className="swaps-section-title">📥 Incoming Requests</h3>
              {incoming.length === 0 ? (
                <div className="swaps-empty">No incoming requests.</div>
              ) : (
                incoming.map((req) => (
                  <div className="swap-card swap-card-incoming" key={req.requestId}>
                    <div className="swap-card-top">
                      <div>
                        <div className="swap-card-title">
                          From: <strong>{req.sender?.name || "Student " + req.sender?.studentId}</strong>
                        </div>
                        <div className="swap-card-sub">
                          They offer:{" "}
                          <span className="swap-blue">
                            {req.senderSection?.course?.courseName} — Sec{" "}
                            {req.senderSection?.sectionNumber}
                          </span>
                        </div>
                        <div className="swap-card-sub">
                          For your:{" "}
                          <span className="swap-purple">
                            {req.offer?.haveSection?.course?.courseName} — Sec{" "}
                            {req.offer?.haveSection?.sectionNumber}
                          </span>
                        </div>
                        <span className={`swap-badge ${badgeClass(req.status)}`}>
                          {req.status}
                        </span>
                      </div>
                      {req.status === "PENDING" && (
                        <div className="swap-card-actions-col">
                          <button
                            className="swap-btn-accept"
                            onClick={() => handleAccept(req.requestId)}
                          >
                            ✓ Accept
                          </button>
                          <button
                            className="swap-btn-reject"
                            onClick={() => handleReject(req.requestId)}
                          >
                            ✕ Reject
                          </button>
                        </div>
                      )}
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        )}

        {/* ── Sent Requests ── */}
        <div className="swaps-section swaps-section-full">
          <h3 className="swaps-section-title">📤 Requests I Sent</h3>
          {sent.length === 0 ? (
            <div className="swaps-empty">No sent requests.</div>
          ) : (
            <div className="swaps-sent-grid">
              {sent.map((req) => (
                <div className="swap-card" key={req.requestId}>
                  <div className="swap-card-top">
                    <div>
                      <div className="swap-card-title">
                        To: <strong>{req.receiver?.name || "Student " + req.receiver?.studentId}</strong>
                      </div>
                      <div className="swap-card-sub">
                        I offer:{" "}
                        <span className="swap-blue">
                          {req.senderSection?.course?.courseName} — Sec{" "}
                          {req.senderSection?.sectionNumber}
                        </span>
                      </div>
                      <div className="swap-card-sub">
                        For their:{" "}
                        <span className="swap-purple">
                          {req.offer?.haveSection?.course?.courseName} — Sec{" "}
                          {req.offer?.haveSection?.sectionNumber}
                        </span>
                      </div>
                      <span className={`swap-badge ${badgeClass(req.status)}`}>
                        {req.status}
                      </span>
                    </div>
                    {req.status === "PENDING" && (
                      <button
                        className="swap-btn-cancel"
                        onClick={() => handleCancelRequest(req.requestId)}
                      >
                        Cancel
                      </button>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </PortalLayout>
  );
}

export default MySwapsPage;
