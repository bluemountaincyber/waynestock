import React, { useState } from 'react'

export default function Purchase({ search }) {
  const seats = search.split('=')[1]
  const [fullName, setFullName] = useState('')
  const [email, setEmail] = useState('')
  const [phone, setPhone] = useState('')
  const [address, setAddress] = useState('')
  const [creditCard, setCreditCard] = useState('')

  function validateForm() {
    if (!fullName || !email || !phone || !address || !creditCard) {
      alert('Please fill out all fields')
      return false
    }
    if (!email.includes('@') || !email.includes('.')) {
      alert('Please enter a valid email address')
      return false
    }
    if (typeof parseInt(phone) !== 'number') {
      alert('Please enter a valid phone number')
      return false
    }
    if (creditCard.length < 15 || typeof parseInt(creditCard) !== 'number') {
      alert('Please enter a valid credit card number')
      return false
    }
    return true
  }

  function handleForm() {
    if (validateForm()) {
      fetch(window.location.origin + '/api/purchase', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: JSON.stringify({
          seats,
          fullName,
          email,
          phone,
          address,
          creditCard
        })
      })
        .then(response => response.json())
        .then(data => window.confirm(data.message)
          .then(window.location.replace('/')))
        .catch(err => console.log(err))
    }
    setButtonText('Purchase')
  }

  return (
    <div>
      <form>
        <label>Seats</label>
        <ul>
          {seats.split(',').map(seat => <li key={seat}>{seat}</li>)}
        </ul>
        <input type="hidden" value={seats} id="seats" name="seats" />
        <label>Full Name</label><br />
        <input type="text" value={fullName} id="name" name="name" onChange={e => setFullName(e.target.value)} /><br />
        <label>Email</label><br />
        <input type="text" value={email} id="email" name="email" onChange={e => setEmail(e.target.value)} /><br />
        <label>Phone</label><br />
        <input type="text" value={phone} id="phone" name="phone" onChange={e => setPhone(e.target.value)} /><br />
        <label>Address</label><br />
        <input type="text" value={address} id="address" name="address" onChange={e => setAddress(e.target.value)} /><br />
        <label>Credit Card</label><br />
        <input type="text" value={creditCard} id="cc" name="cc" onChange={e => setCreditCard(e.target.value)} /><br />
      </form>
      <button onClick={handleForm}>Purchase</button>
    </div>
  )
}