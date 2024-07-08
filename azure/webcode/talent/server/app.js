const express = require('express')
const app = express()
var cors = require('cors')

app.use(cors())

var corsOptions = {
  origin: 'http://localhost:3000',
  optionsSuccessStatus: 200
}

var db = require('./database/conn.js');
var initialize_db = require('./database/initialize.js')(db)

if (initialize_db) {
  console.log('Database initialized')
}

app.use(express.static('static'))

app.get('/api/talent/:id', cors(corsOptions), (req, res) => {
  var id = parseInt(req.params.id)
  db.query(`SELECT * FROM talent WHERE id=${id}`, function (err, result) {
    if (err) {
      console.log(err)
      res.send("Database error!")
    } else {
      res.send(result)
    }
  })
});

app.get('/api/talent/email/:email', (req, res) => {
  db.query(`SELECT t.* FROM talent t INNER JOIN contact c ON t.id = c.id WHERE c.email='${req.params.email}'`, function (err, result) {
    if (err) {
      console.log(err)
      res.send("Database error!")
    } else {
      res.send(result)
    }
  })
});

app.get('/api/talent/phone/:phone', (req, res) => {
  db.query(`SELECT t.* FROM talent t INNER JOIN contact c ON t.id = c.id WHERE c.phone='${req.params.phone}'`, function (err, result) {
    if (err) {
      console.log(err)
      res.send("Database error!")
    } else {
      res.send(result)
    }
  })
});

app.get('/api/talent/first/:first', cors(corsOptions), (req, res) => {
  var id = parseInt(req.params.id)
  db.query(`SELECT * FROM talent WHERE first='${req.params.first}'`, function (err, result) {
    if (err) {
      console.log(err)
      res.send("Database error!")
    } else {
      res.send(result)
    }
  })
});

app.get('/api/talent/last/:last', cors(corsOptions), (req, res) => {
  var id = parseInt(req.params.id)
  db.query(`SELECT * FROM talent WHERE last='${req.params.last}'`, function (err, result) {
    if (err) {
      console.log(err)
      res.send("Database error!")
    } else {
      res.send(result)
    }
  })
});

app.get('/api/talent/additional/:id', cors(corsOptions), (req, res) => {
  var id = parseInt(req.params.id)
  db.query(`SELECT c.address, c.phone, c.email, p.fees, p.ssn FROM talent t INNER JOIN contact c ON t.id = c.id INNER JOIN payroll p ON t.id = p.id WHERE t.id=${id}`, function (err, result) {
    if (err) {
      console.log(err)
      res.send("Database error!")
    } else {
      res.send(result)
    }
  })
});

app.listen(8888, () =>
  console.log(`Example app listening on port 8888`),
)
