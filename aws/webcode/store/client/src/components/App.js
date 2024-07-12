import './App.css';
import queryString from 'query-string';
import axios from 'axios';
import {
  Container,
  Menu,
  MenuHeader,
  MenuItem,
} from 'semantic-ui-react'
import {
  BrowserRouter,
  Link,
  Route,
  Routes
} from 'react-router-dom';
import { jwtDecode } from "jwt-decode";
import waynestockLogo from '../images/waynestock-logo.png';
import Home from './Home';
import Tickets from './Tickets';

export default function App() {
  const menuStyle = {
    marginTop: "10px",
  }
  const imgStyle = {
    margin: "auto",
    height: "30px"
  }

  const access_token = queryString.parse(window.location.hash).access_token
  if (access_token) {
    localStorage.setItem('token', access_token)
    window.location.href = window.location.origin
  }

  if (localStorage.getItem('token')) {
    console.log(jwtDecode(localStorage.getItem('token')))
    axios.defaults.headers.common['Authorization'] = 'Bearer ' + localStorage.getItem('token')
  }

  function logoff() {
    localStorage.removeItem('token');
    axios.defaults.headers.common['Authorization'] = '';
    window.location.href = window.location.origin;
  }

  function login() {
    window.location.href = window.location.origin + "/api/login"
  }

  return (
    <Container style={{ height: "100vh" }}>
      <BrowserRouter>
        <Menu secondary style={menuStyle}>
          <MenuHeader>
            <img src={waynestockLogo} alt="Waynestock logo" style={imgStyle} />
          </MenuHeader>
          <MenuItem>
            <Link to="/">Home</Link>
          </MenuItem>
          <MenuItem>
            <Link to="/tickets">Tickets</Link>
          </MenuItem>
          <MenuItem>
            {access_token ?
              <Link to="/" onClick={() => logoff()}>Logout</Link> :
              <Link to="/" onClick={() => login()}>Login</Link>
            }
          </MenuItem>
        </Menu>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/tickets" element={<Tickets />} />
        </Routes>
      </BrowserRouter>
    </Container>
  );
}
