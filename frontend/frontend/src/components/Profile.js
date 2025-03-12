import React from "react";
import authService from "../services/authService";

const Profile = () => {
  const currentUser = authService.getCurrentUser();

  return (
    <div className="container">
      <header className="jumbotron">
        <h3>
          <strong>{currentUser.username}</strong> 프로필
        </h3>
      </header>
      <p>
        <strong>토큰:</strong> {currentUser.accessToken.substring(0, 20)} ...{" "}
        {currentUser.accessToken.substr(currentUser.accessToken.length - 20)}
      </p>
      <p>
        <strong>ID:</strong> {currentUser.id}
      </p>
      <p>
        <strong>이메일:</strong> {currentUser.email}
      </p>
      <strong>권한:</strong>
      <ul>
        {currentUser.roles &&
          currentUser.roles.map((role, index) => <li key={index}>{role}</li>)}
      </ul>
    </div>
  );
};

export default Profile;
