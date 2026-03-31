import "../styles/portal.css";

function PortalLayout({
  studentId,
  studentName,
  studentNumber,
  studentYear,
  title,
  currentPage,
  onNavigate,
  onLogout,
  children,
}) {
  const displayName = studentName || "Student";
  const displayStudentNumber = studentNumber || studentId || "-";
  const displayYear = studentYear ? `Year ${studentYear}` : "Year -";
  const topbarIdentity = [displayName, displayStudentNumber].filter(Boolean).join(" ");

  return (
    <div className="portal-layout">
      <aside className="portal-sidebar">
        <div className="sidebar-brand">HTU's Portal</div>

        <div className="sidebar-user">
          <div className="user-avatar">👤</div>
          <div>
            <div className="user-name">{displayName}</div>
            <div className="user-id">{displayStudentNumber}</div>
            <div className="user-year">{displayYear}</div>
          </div>
        </div>

        <ul className="sidebar-menu">
          <li
            className={currentPage === "schedule" ? "active" : ""}
            onClick={() => onNavigate("schedule")}
          >
            Student Schedule
          </li>

          <li
            className={currentPage === "courses" ? "active" : ""}
            onClick={() => onNavigate("courses")}
          >
            Available Courses
          </li>

          <li
            className={currentPage === "trading" ? "active" : ""}
            onClick={() => onNavigate("trading")}
          >
            Trading Page
          </li>

          <li
            className={currentPage === "swaps" ? "active" : ""}
            onClick={() => onNavigate("swaps")}
          >
            My Swaps
          </li>
        </ul>

        <div className="sidebar-logout-wrap">
          <button className="sidebar-logout-btn" onClick={onLogout}>
            Logout
          </button>
        </div>
      </aside>

      <main className="portal-main">
        <header className="portal-topbar">
          <div className="topbar-left">{title}</div>
          <div className="topbar-right">Logged in as: {topbarIdentity}</div>
        </header>

        <section className="portal-content">{children}</section>
      </main>
    </div>
  );
}

export default PortalLayout;
