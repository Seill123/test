import React, { useState } from "react";
import authService from "../../services/authService";

const Register = () => {
  const [username, setUsername] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [successful, setSuccessful] = useState(false);
  const [message, setMessage] = useState("");

  const onChangeUsername = (e) => {
    setUsername(e.target.value);
  };

  const onChangeEmail = (e) => {
    setEmail(e.target.value);
  };

  const onChangePassword = (e) => {
    setPassword(e.target.value);
  };

  const handleRegister = (e) => {
    e.preventDefault();
    setMessage("");
    setSuccessful(false);

    authService
      .register(username, email, password)
      .then((response) => {
        setMessage(response.data.message);
        setSuccessful(true);
      })
      .catch((error) => {
        const resMessage =
          (error.response &&
            error.response.data &&
            error.response.data.message) ||
          error.message ||
          error.toString();

        setMessage(resMessage);
        setSuccessful(false);
      });
  };

  return (
    <div className="col-md-12">
      <div className="card card-container">
        <img
          src="//ssl.gstatic.com/accounts/ui/avatar_2x.png"
          alt="profile-img"
          className="profile-img-card"
        />

        <form onSubmit={handleRegister}>
          {!successful && (
            <div>
              <div className="form-group">
                <label htmlFor="username">사용자명</label>
                <input
                  type="text"
                  className="form-control"
                  name="username"
                  value={username}
                  onChange={onChangeUsername}
                  required
                  minLength="3"
                  maxLength="20"
                />
              </div>

              <div className="form-group">
                <label htmlFor="email">이메일</label>
                <input
                  type="email"
                  className="form-control"
                  name="email"
                  value={email}
                  onChange={onChangeEmail}
                  required
                />
              </div>

              <div className="form-group">
                <label htmlFor="password">비밀번호</label>
                <input
                  type="password"
                  className="form-control"
                  name="password"
                  value={password}
                  onChange={onChangePassword}
                  required
                  minLength="6"
                />
              </div>

              <div className="form-group">
                <button className="btn btn-primary btn-block">회원가입</button>
              </div>
            </div>
          )}

          {message && (
            <div className="form-group">
              <div
                className={
                  successful ? "alert alert-success" : "alert alert-danger"
                }
                role="alert"
              >
                {message}
              </div>
            </div>
          )}
        </form>
      </div>
    </div>
  );
};

export default Register;
