import React from 'react';
import axios from 'axios';
import ContactCard from './ContactCard';
import {
    Button,
    CardGroup,
    Divider,
    Form,
    FormField,
    FormGroup,
    Input
} from 'semantic-ui-react'

export default function LookupTalent() {
    const [formData, setFormData] = React.useState({
        option: "id",
        search: ""
    })
    const [talentData, setTalentData] = React.useState([])

    function handleChange(event) {
        setFormData(prevFormData => {
            console.log(event.target.name, event.target.value)
            return {
                ...prevFormData,
                [event.target.name]: event.target.value
            }
        })
    }

    function handleSubmit(event) {
        event.preventDefault();
        var url = ""
        if (window.location.hostname === "localhost") {
            url = "http://localhost:8888"
        } else {
            url = "https://" + window.location.hostname
        }
        var search = encodeURIComponent(formData.search)
        if (formData.option === "id") {
            url = url + `/api/talent/${search}`
        } else if (formData.option === "email") {
            url = url + `/api/talent/email/${search}`;
        } else if (formData.option === "phone") {
            url = url + `/api/talent/phone/${search}`;
        } else if (formData.option === "first") {
            url = url + `/api/talent/first/${search}`;
        } else if (formData.option === "last") {
            url = url + `/api/talent/last/${search}`;
        } else {
            console.error("Invalid option")
            return
        }
        axios.get(url)
            .then(response => {
                setTalentData(response.data)
            })
            .catch(error => {
                console.error(error)
            });
    }

    return (
        <div>
            <h2>Lookup Talent</h2>
            <Form onSubmit={handleSubmit}>
                <FormGroup widths='equal'>
                    <select 
                        name="option"
                        onChange={handleChange}
                    >
                        <option value="id">ID</option>
                        <option value="email">Email</option>
                        <option value="phone">Phone</option>
                        <option value="first">First Name</option>
                        <option value="last">Last Name</option>
                    </select>
                    <FormField
                        control={Input}
                        type='text'
                        name='search'
                        placeholder='Search...'
                        value={formData.search}
                        onChange={handleChange}
                    />
                    <FormField 
                        control={Button}
                        color="green"
                    >Submit</FormField>
                </FormGroup>
            </Form>
            { talentData.length > 0 && <Divider></Divider> }
            { talentData.length > 0 && 
                <div>
                    <CardGroup itemsPerRow={2}>
                    {talentData.map((talent) => (
                        <ContactCard
                            key={talent.id}
                            id={talent.id}
                            first={talent.first}
                            last={talent.last}
                            role={talent.role}
                            img={talent.img}
                        />
                    ))}
                    </CardGroup>
                </div>
            }
        </div>
    )
}
