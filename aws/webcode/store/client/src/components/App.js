import './App.css';
import querystring from 'query-string';
import Navigation from './Navigation';
import Tickets from './Tickets';
import Purchase from './Purchase';
import React, {
  useEffect,
  useState
} from 'react';
import {
  BrowserRouter as Router,
  Route,
  Routes
} from 'react-router-dom';
import { jwtDecode } from 'jwt-decode';

export default function App() {
  const hash = window.location.hash
  const pathName = window.location.pathname
  const token = querystring.parse(hash).access_token
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  const checkTokenValidity = (forward) => {
    const token = localStorage.getItem('token');
    if (token) {
      setIsLoggedIn(true)
      try {
        const decoded = jwtDecode(token)
        const currentTime = Date.now() / 1000;
        if (decoded.exp < currentTime) {
          localStorage.removeItem('token');
          setIsLoggedIn(false);
        }
      } catch (e) {
        console.log("Invalid token. Removing...")
        localStorage.removeItem('token');
        setIsLoggedIn(false)
      }
      if (forward) {
        window.location.replace(window.location.origin)
      }
    }
  }

  useEffect(() => {
    if (token) {
      localStorage.setItem('token', token);
      checkTokenValidity(true)
    } else if (localStorage.getItem('token')) {
      checkTokenValidity(false)
    } else {
      setIsLoggedIn(false);
    }
  }, [token]);

  function logout() {
    localStorage.removeItem('token');
    setIsLoggedIn(false);
  }

  return (
    <div className="home">
      <Navigation isLoggedIn={isLoggedIn} logout={logout} />
      <h1 className="centered">Welcome to WayneStock!</h1>
      {isLoggedIn && pathName !== "/purchase" ?
        <Tickets /> :
        !isLoggedIn ?
        <span className="centered">Please log in to purchase tickets</span> : null }
      <Router>
        <Routes>
          <Route path="/purchase" element={<Purchase search={window.location.search}/>} />
        </Routes>
      </Router>
    </div>
  );
}
