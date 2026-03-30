import { useState } from "react";
import { ensureWallet } from "../api";
import "../styles/login.css";

function LoginPage({ onLogin }) {
  const [studentId, setStudentId] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!studentId || !password) {
      alert("Please enter student ID and password");
      return;
    }

    try {
      setLoading(true);

      await ensureWallet(studentId);

      onLogin(studentId);
    } catch (error) {
      alert(error.message || "Failed to prepare wallet");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-page-custom">
      <div className="login-wrapper">
        <div className="login-card">
          <div className="login-top-text">
            The login credentials for the student portal are now the same as those
            for the e-learning system (eLearning).
          </div>

          <div className="logo-area">
            <img src="/htu-logo.png" alt="HTU Logo" className="htu-logo" />
            <img
              src="/student-portal-logo.png"
              alt="Student Portal Logo"
              className="portal-logo"
            />
          </div>

          <form onSubmit={handleSubmit}>
            <div className="input-group-custom">
              <div className="input-icon green-box">👤</div>
              <input
                type="text"
                placeholder="Student ID"
                value={studentId}
                onChange={(e) => setStudentId(e.target.value)}
              />
            </div>

            <div className="input-group-custom">
              <div className="input-icon yellow-box">✎</div>
              <input
                type="password"
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </div>

            <div className="language-row">
              <label>
                <input type="radio" name="lang" defaultChecked /> English
              </label>
              <label>
                <input type="radio" name="lang" /> عربي
              </label>
            </div>

            <button type="submit" className="login-btn" disabled={loading}>
              {loading ? "Loading..." : "Login"}
            </button>

            <div className="forgot-row">
              <a href="#">Forgot your password?</a>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}

export default LoginPage;