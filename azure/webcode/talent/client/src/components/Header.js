import React from 'react';
import waynestockLogo from '../images/waynestock-logo.png';
import { MenuItem, Menu } from 'semantic-ui-react'

export default function Header() {
    return (
        <Menu secondary size={"huge"}>
            <MenuItem>
                <img src={waynestockLogo} alt="Waynestock logo"/><span>Talent Management</span>
            </MenuItem>
        </Menu>
    );
}
