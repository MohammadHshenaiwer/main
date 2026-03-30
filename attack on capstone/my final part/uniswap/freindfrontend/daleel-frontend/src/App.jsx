import { useEffect, useState } from "react";
import LoginPage from "./components/LoginPage";
import StudentSchedulePage from "./components/StudentSchedulePage";
import AvailableCoursesPage from "./components/AvailableCoursesPage";
import TradingPage from "./components/TradingPage";

function App() {
  const [studentId, setStudentId] = useState("");
  const [page, setPage] = useState("schedule");

  useEffect(() => {
    const savedStudentId = localStorage.getItem("studentId");
    const savedPage = localStorage.getItem("page");

    if (savedStudentId) {
      setStudentId(savedStudentId);
    }

    if (savedPage) {
      setPage(savedPage);
    }
  }, []);

  const handleLogin = (id) => {
    setStudentId(id);
    localStorage.setItem("studentId", id);
    localStorage.setItem("page", "schedule");
    setPage("schedule");
  };

  const handleNavigate = (nextPage) => {
    setPage(nextPage);
    localStorage.setItem("page", nextPage);
  };

  const handleLogout = () => {
    localStorage.removeItem("studentId");
    localStorage.removeItem("page");
    setStudentId("");
    setPage("schedule");
  };

  if (!studentId) {
    return <LoginPage onLogin={handleLogin} />;
  }

  if (page === "schedule") {
    return (
      <StudentSchedulePage
        studentId={studentId}
        onNavigate={handleNavigate}
        onLogout={handleLogout}
      />
    );
  }

  if (page === "courses") {
    return (
      <AvailableCoursesPage
        studentId={studentId}
        onNavigate={handleNavigate}
        onLogout={handleLogout}
      />
    );
  }

  if (page === "trading") {
    return (
      <TradingPage
        studentId={studentId}
        onNavigate={handleNavigate}
        onLogout={handleLogout}
      />
    );
  }

  return null;
}

export default App;