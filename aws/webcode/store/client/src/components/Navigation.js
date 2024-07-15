import waynestockLogo from '../images/waynestock-logo.png';
import React from 'react';

export default function Navigation({isLoggedIn, logout}) {

    return (
        <nav>
            <ul>
                <li className="nav-left"><a href="/"><img src={waynestockLogo} alt="WayneStock Home" /></a></li>
                {isLoggedIn ?
                    <li className="nav-right" onClick={logout}>Logout</li> :
                    <li className="nav-right"><a href={window.location.origin + "/api/login"}>Login</a></li>
                }
            </ul>
        </nav>
    )
}
