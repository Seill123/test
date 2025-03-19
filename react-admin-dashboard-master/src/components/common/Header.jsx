import { useState } from "react";
import { useNavigate } from "react-router-dom";

const Header = ({ title }) => {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const navigate = useNavigate();

  const handleLogin = () => {
    // 로그인 페이지로 이동
    navigate("/login");
  };

  const handleLogout = () => {
    // 로그아웃 처리
    setIsLoggedIn(false);
    // 로컬 스토리지에서 토큰 제거
    localStorage.removeItem("token");
    // 홈으로 이동
    navigate("/");
  };

  return (
    <header className="bg-gray-800 bg-opacity-50 border-b border-gray-700 shadow-lg backdrop-blur-md">
      <div className="flex items-center justify-between px-4 py-4 mx-auto max-w-7xl sm:px-6 lg:px-8">
        <h1 className="text-2xl font-semibold text-gray-100">{title}</h1>
        <div>
          {isLoggedIn ? (
            <button
              onClick={handleLogout}
              className="px-4 py-2 font-bold text-white bg-red-600 rounded hover:bg-red-700"
            >
              로그아웃
            </button>
          ) : (
            <button
              onClick={handleLogin}
              className="px-4 py-2 font-bold text-white bg-blue-600 rounded hover:bg-blue-700"
            >
              로그인
            </button>
          )}
        </div>
      </div>
    </header>
  );
};

export default Header;
