import React, {
  useEffect,
  useState
} from 'react'

export default function Tickets() {
  const [seats, setSeats] = useState([])
  const [selectedSeats, setSelectedSeats] = useState([])
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    setIsLoading(true);
    fetch('/api/seats', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${localStorage.getItem('token')}`
      }
    })
      .then(res => res.json())
      .then(data => {
        setSeats(data)
        setIsLoading(false);
      })
      .catch(err => console.log(err))
  }, [])

  const handleSeatClick = (e) => {
    const seat = e.target;
    if (seat.style.backgroundColor === 'blue') {
      seat.style.backgroundColor = 'white';
      setSelectedSeats(selectedSeats.filter(selectedSeat => selectedSeat !== seat.id));
    } else {
      seat.style.backgroundColor = 'blue';
      setSelectedSeats([...selectedSeats, seat.id]);
    }
  }

  const handleSubmit = () => {
    if (selectedSeats.length === 0) {
      alert('Please select a seat to purchase')
      return;
    } else if (selectedSeats.length > 8) {
      alert('You can only purchase up to eight tickets at a time')
      return;
    }
    console.log(selectedSeats);
    window.location.replace(`/purchase?seats=${selectedSeats.join(',')}`)
  }

  return (
    <div>
      {isLoading ? <div>Loading seating chart...</div> :
        <div>
          <div className="grid-container-stage">
            <div className="grid-item stage">
              Stage
            </div>
          </div>
          <div className="grid-container">
            {seats.map(seat => {
              if (seat.section === 1) {
                var seatStyle = {}
                seatStyle = {
                  backgroundColor: seat.available ? 'white' : 'gray',
                  gridColumn: seat.seat,
                  gridRow: seat.row + 1,
                  hidden: false,
                  cursor: seat.available ? 'pointer' : 'not-allowed'
                }
              } else if (seat.section === 2) {
                seatStyle = {
                  backgroundColor: seat.available ? 'white' : 'gray',
                  gridColumn: seat.seat + 16,
                  gridRow: seat.row + 1,
                  hidden: false,
                  cursor: seat.available ? 'pointer' : 'not-allowed'
                }
              } else {
                seatStyle = {
                  backgroundColor: seat.available ? 'white' : 'gray',
                  gridColumn: seat.seat + 32,
                  gridRow: seat.row + 1,
                  hidden: false,
                  cursor: seat.available ? 'pointer' : 'not-allowed'
                }
              }
              return (
                <div key={seat.seat_id} className="grid-item" id={seat.seat_id} style={seatStyle} onClick={seat.available ? handleSeatClick : null}>
                  <p></p>
                </div>
              )
            })}
          </div>
          <button onClick={handleSubmit}>Buy</button>
        </div>
      } </div>
  )
}
