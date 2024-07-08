module.exports = function(connection) {
    connection.query('CREATE TABLE IF NOT EXISTS talent (id INT NOT NULL AUTO_INCREMENT, first VARCHAR(20), last VARCHAR(20), role VARCHAR(40), img VARCHAR(128), PRIMARY KEY (id))', function (err, result) {
        if (err) {
            console.log(err)
        }
        connection.query('CREATE TABLE IF NOT EXISTS payroll (id INT NOT NULL, ssn VARCHAR(20), fees INT, FOREIGN KEY (id) REFERENCES talent(id))', function (err, result) {
            if (err) {
                console.log(err)
            }
            connection.query('CREATE TABLE IF NOT EXISTS contact (id INT NOT NULL, address VARCHAR(100), phone VARCHAR(20), email VARCHAR(40), FOREIGN KEY (id) REFERENCES talent(id))', function (err, result) {
                if (err) {
                    console.log(err)
                }
            const talent = require('./talent.json')
            connection.query('SELECT COUNT(*) FROM talent', function (err, result) {
                if (err) {
                    console.log(err)
                }
                if (result[0]['COUNT(*)'] < talent.length) {
                    var img = [
                        process.env.SA_URL + "fsharp.jpeg",
                        process.env.SA_URL + "bcahn.jpeg",
                        process.env.SA_URL + "hdan.jpeg",
                        process.env.SA_URL + "mscream.jpeg",
                        process.env.SA_URL + "bkjergen.jpeg",
                        process.env.SA_URL + "cwong.jpeg",
                        process.env.SA_URL + "gfoster.jpeg",
                        process.env.SA_URL + "afocx.jpeg",
                        process.env.SA_URL + "mferrari.jpeg",
                        process.env.SA_URL + "boliver.jpeg",
                        process.env.SA_URL + "wcampbell.jpeg",
                        process.env.SA_URL + "galgar.jpeg",
                        process.env.SA_URL + "nvanderhoff.jpeg",
                        process.env.SA_URL + "rfinely.jpeg",
                        process.env.SA_URL + "dpreston.jpeg",
                        process.env.SA_URL + "rpaxton.jpeg",
                        process.env.SA_URL + "styler.jpeg",
                        process.env.SA_URL + "jperry.jpeg",
                        process.env.SA_URL + "thamilton.jpeg",
                        process.env.SA_URL + "jkramer.jpeg",
                        process.env.SA_URL + "bwhitford.jpeg",
                        process.env.SA_URL + "cfarley.jpeg",
                        process.env.SA_URL + "goneill.jpeg",
                        process.env.SA_URL + "evedder.jpeg",
                        process.env.SA_URL + "sgossard.jpeg",
                        process.env.SA_URL + "jament.jpeg",
                        process.env.SA_URL + "mmccready.jpeg",
                        process.env.SA_URL + "dabbruzzese.jpeg",
                        process.env.SA_URL + "evanhalen.jpeg",
                        process.env.SA_URL + "avanhalen.jpeg",
                        process.env.SA_URL + "manthony.jpeg",
                        process.env.SA_URL + "shagar.jpeg",
                        process.env.SA_URL + "rtaylor.jpeg"
                    ]
                    for (var i = 0; i < talent.length; i++) {
                        try {
                            connection.query(`INSERT INTO talent VALUES (${talent[i].id}, "${talent[i].first}", "${talent[i].last}", "${talent[i].role}", "${img[i]}")`, function (err, result) {
                                if (err) {
                                    console.log(err)
                                }
                            })
                        } catch {
                            console.log('Moving on...')
                        }
                    }
                } else {
                    console.log('talent table already populated')
                }
                const contact = require('./contact.json')
                connection.query('SELECT COUNT(*) FROM contact', function (err, result) {
                    if (err) {
                        console.log(err)
                    }
                    if (result[0]['COUNT(*)'] < contact.length) {
                        for (var i = 0; i < contact.length; i++) {
                            try {
                                connection.query(`INSERT INTO contact VALUES (${contact[i].id}, "${contact[i].address}", "${contact[i].phone}", "${contact[i].email}")`, function (err, result) {
                                    if (err) {
                                        console.log(err)
                                    }
                                })
                            } catch {
                                console.log('Moving on...')
                            }
                        }
                    } else {
                        console.log('Contact table already populated')
                    }
                    const payroll = require('./payroll.json')
                    connection.query('SELECT COUNT(*) FROM payroll', function (err, result) {
                        if (err) {
                            console.log(err)
                        }
                        if (result[0]['COUNT(*)'] < payroll.length) {
                            for (var i = 0; i < payroll.length; i++) {
                                try {
                                    connection.query(`INSERT INTO payroll VALUES (${payroll[i].id}, "${payroll[i].ssn}", ${payroll[i].fee})`, function (err, result) {
                                        if (err) {
                                            console.log(err)
                                        }
                                    })
                                } catch {
                                    console.log('Moving on...')
                                }
                            }
                        } else {
                            console.log('Payroll table already populated')
                        }
        })})})})})})
    return true
}