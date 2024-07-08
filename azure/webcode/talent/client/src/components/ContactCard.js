import React from 'react';
import axios from 'axios'
import {
    Card,
    CardContent,
    Icon,
    Table,
    TableBody,
    TableRow,
    TableCell
} from 'semantic-ui-react'

export default function ContactCard({id, first, last, role, img}) {
    const [additionalInfo, setAdditionalInfo] = React.useState([
        {
            address: "",
            phone: "",
            email: "",
            fees: "",
            ssn: ""
        }
    ])

    function handleClick() {
        if (additionalInfo[0].address === "") {
            var url = ""
            if (window.location.hostname === "localhost") {
                url = "http://localhost:8888"
            } else {
                url = "https://" + window.location.hostname
            }
            url = url + `/api/talent/additional/${id}`
            axios.get(url)
                .then(response => {
                    setAdditionalInfo(response.data)
                })
                .catch(error => {
                    console.error(error)
                });
        } else {
            setAdditionalInfo([
                {
                    address: "",
                    phone: "",
                    email: "",
                    fees: "",
                    ssn: ""
                }
            ])
        }
    }

    const description = (
        <Table basic='very'>
            <TableBody>
                <TableRow>
                    <TableCell width={1}>
                        <Icon fitted name="star"/>
                    </TableCell>
                    <TableCell width={3}>
                        <b>Role</b>
                    </TableCell>
                    <TableCell width={10}>
                        {role}
                    </TableCell>
                    { additionalInfo[0].phone &&
                        <td rowSpan={"6"}>
                            <img src={img} alt={`${first} ${last}`} width={"180px"}/>
                        </td>
                    }
                </TableRow>
                <TableRow>
                    <TableCell>
                        <Icon fitted name="id badge"/>
                    </TableCell>
                    <TableCell>
                    <b>Talent ID</b>
                    </TableCell>
                    <TableCell>
                        {id}
                    </TableCell>
                </TableRow>
                { additionalInfo[0].address &&
                    <TableRow>
                        <TableCell>
                            <Icon fitted name="address card"/>
                        </TableCell>
                        <TableCell>
                            <b>Address</b>
                        </TableCell>
                        <TableCell>
                            {additionalInfo[0].address}
                        </TableCell>
                    </TableRow>
                }
                { additionalInfo[0].phone &&
                    <TableRow style={{display: "none"}}>
                        <TableCell>
                            <Icon fitted name="phone"/>
                        </TableCell>
                        <TableCell>
                            <b>Phone</b>
                        </TableCell>
                        <TableCell>
                            {additionalInfo[0].phone}
                        </TableCell>
                    </TableRow>
                }
                { additionalInfo[0].email &&
                    <TableRow>
                        <TableCell>
                            <Icon fitted name="envelope"/>
                        </TableCell>
                        <TableCell>
                            <b>Email</b>
                        </TableCell>
                        <TableCell>
                            {additionalInfo[0].email}
                        </TableCell>
                    </TableRow>
                }
                { additionalInfo[0].fees &&
                    <TableRow>
                        <TableCell>
                            <Icon fitted name="dollar"/>
                        </TableCell>
                        <TableCell>
                            <b>Fee</b>
                        </TableCell>
                        <TableCell>
                            ${additionalInfo[0].fees}
                        </TableCell>
                    </TableRow>
                }
                { additionalInfo[0].ssn &&
                    <TableRow>
                        <TableCell>
                            <Icon fitted name="shield"/>
                        </TableCell>
                        <TableCell>
                            <b>SSN</b>
                        </TableCell>
                        <TableCell>
                            {additionalInfo[0].ssn}
                        </TableCell>
                    </TableRow>
                }
            </TableBody>
        </Table>
    )
    return (
        <Card onClick={() => handleClick()}>
            <CardContent header={`${first} ${last}`}/>
            <CardContent description={description}/>
            <CardContent extra>
                {role}
            </CardContent>
        </Card>
    );
}
