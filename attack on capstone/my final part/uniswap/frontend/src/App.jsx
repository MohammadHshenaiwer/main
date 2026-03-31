import { useEffect, useState } from "react";
import LoginPage from "./components/LoginPage";
import StudentSchedulePage from "./components/StudentSchedulePage";
import AvailableCoursesPage from "./components/AvailableCoursesPage";
import TradingPage from "./components/TradingPage";
import MySwapsPage from "./components/MySwapsPage";

const MAX_PROGRAM_YEAR = 4;
const SECOND_YEAR_OVERRIDES = new Set(["22220020", "22001414"]);
const THIRD_YEAR_OVERRIDES = new Set(["23012001", "23012002"]);

function deriveStudentYear(studentNumber) {
  const normalized = String(studentNumber ?? "").trim();
  if (SECOND_YEAR_OVERRIDES.has(normalized)) {
    return 2;
  }
  if (THIRD_YEAR_OVERRIDES.has(normalized)) {
    return 3;
  }

  if (!/^\d{2}/.test(normalized)) {
    return null;
  }

  const intakeYear = 2000 + Number.parseInt(normalized.slice(0, 2), 10);
  const now = new Date();
  const academicStartYear = now.getMonth() >= 8 ? now.getFullYear() : now.getFullYear() - 1;
  const derivedYear = academicStartYear - intakeYear + 1;

  if (derivedYear < 1) {
    return 1;
  }
  if (derivedYear > MAX_PROGRAM_YEAR) {
    return MAX_PROGRAM_YEAR;
  }
  return derivedYear;
}

function App() {
  const [studentProfile, setStudentProfile] = useState({
    id: "",
    name: "Student",
    number: "",
    year: null,
  });
  const [page, setPage] = useState("schedule");
  const studentId = studentProfile.id;

  useEffect(() => {
    const savedStudentId = localStorage.getItem("studentId");
    const savedStudentName = localStorage.getItem("studentName") || "Student";
    const savedStudentNumber = localStorage.getItem("studentNumber") || "";
    const savedStudentYearRaw = localStorage.getItem("studentYear");
    const savedStudentYear = Number.parseInt(savedStudentYearRaw ?? "", 10);
    const savedPage = localStorage.getItem("page");

    if (savedStudentId) {
      setStudentProfile({
        id: savedStudentId,
        name: savedStudentName,
        number: savedStudentNumber,
        year: Number.isNaN(savedStudentYear)
          ? deriveStudentYear(savedStudentNumber)
          : savedStudentYear,
      });
    }

    if (savedPage) {
      setPage(savedPage);
    }
  }, []);

  const handleLogin = (student) => {
    const id = String(student.studentId ?? "");
    const name = student.name || "Student";
    const number = String(student.studentNumber ?? "");
    const year = deriveStudentYear(number);

    setStudentProfile({ id, name, number, year });

    localStorage.setItem("studentId", id);
    localStorage.setItem("studentName", name);
    localStorage.setItem("studentNumber", number);

    if (year !== null) {
      localStorage.setItem("studentYear", String(year));
    } else {
      localStorage.removeItem("studentYear");
    }

    localStorage.setItem("page", "schedule");
    setPage("schedule");
  };

  const handleNavigate = (nextPage) => {
    setPage(nextPage);
    localStorage.setItem("page", nextPage);
  };

  const handleLogout = () => {
    localStorage.removeItem("studentId");
    localStorage.removeItem("studentName");
    localStorage.removeItem("studentNumber");
    localStorage.removeItem("studentYear");
    localStorage.removeItem("page");
    setStudentProfile({ id: "", name: "Student", number: "", year: null });
    setPage("schedule");
  };

  if (!studentId) {
    return <LoginPage onLogin={handleLogin} />;
  }

  if (page === "schedule") {
    return (
      <StudentSchedulePage
        studentId={studentId}
        studentName={studentProfile.name}
        studentNumber={studentProfile.number}
        studentYear={studentProfile.year}
        onNavigate={handleNavigate}
        onLogout={handleLogout}
      />
    );
  }

  if (page === "courses") {
    return (
      <AvailableCoursesPage
        studentId={studentId}
        studentName={studentProfile.name}
        studentNumber={studentProfile.number}
        studentYear={studentProfile.year}
        onNavigate={handleNavigate}
        onLogout={handleLogout}
      />
    );
  }

  if (page === "trading") {
    return (
      <TradingPage
        studentId={studentId}
        studentName={studentProfile.name}
        studentNumber={studentProfile.number}
        studentYear={studentProfile.year}
        onNavigate={handleNavigate}
        onLogout={handleLogout}
      />
    );
  }

  if (page === "swaps") {
    return (
      <MySwapsPage
        studentId={studentId}
        studentName={studentProfile.name}
        studentNumber={studentProfile.number}
        studentYear={studentProfile.year}
        onNavigate={handleNavigate}
        onLogout={handleLogout}
      />
    );
  }

  return null;
}

export default App;
