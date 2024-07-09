import waynestockLogo from '../images/waynestock-logo.png';
import {
  BrowserRouter,
  Link,
  Routes,
  Route
} from "react-router-dom";
import {
  Container,
  Menu,
  MenuHeader,
  MenuItem
} from "semantic-ui-react"
import Home from "./Home";
import Tickets from './Tickets';
import About from "./About";
import Lineup from "./Lineup";
import Modal from "./Modal";
import React from "react";

export default function App() {

  const menuStyle = {
    marginTop: "10px",
  }
  const imgStyle = {
    margin: "auto",
    height: "30px"
  }
  return (
    <Container style={{height: "100vh"}}>
      <Modal />
      <BrowserRouter>
        <Menu secondary style={menuStyle}>
          <MenuHeader>
            <img src={waynestockLogo} alt="Waynestock logo" style={imgStyle} />
          </MenuHeader>
          <MenuItem>
            <Link to="/">Home</Link>
          </MenuItem>
          <MenuItem>
            <Link to="/lineup">Lineup</Link>
          </MenuItem>
          <MenuItem>
            <Link to="/tickets">Tickets</Link>
          </MenuItem>
          <MenuItem>
            <Link to="/about">About</Link>
          </MenuItem>
        </Menu>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/lineup" element={<Lineup />} />
          <Route path="/tickets" element={<Tickets />} />
          <Route path="/about" element={<About />} />
        </Routes>
      </BrowserRouter>
    </Container>
  );
}
