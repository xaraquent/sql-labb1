CREATE DATABASE GymBokning;
USE GymBokning;

-- Skapa tabell för medlemmar
CREATE TABLE Medlemmar(
    medlem_id INT NOT NULL AUTO_INCREMENT,
    medlem_namn VARCHAR(50),
    medlem_email VARCHAR(50),
    medlem_telefon VARCHAR(10),
    medlem_aktiv BOOLEAN DEFAULT 1,
    PRIMARY KEY (medlem_id)
);

-- Skapa tabell för pass
CREATE TABLE Pass(
    pass_id INT NOT NULL AUTO_INCREMENT,
    pass_namn VARCHAR(100),
    pass_max_deltagare INT,
    pass_instruktor VARCHAR(50),
    pass_datum DATETIME NOT NULL,
    PRIMARY KEY (pass_id)
);

-- Skapa tabell för bokningar
CREATE TABLE Bokningar(
    bokning_id INT NOT NULL AUTO_INCREMENT,
    medlem_id INT,
    pass_id INT,
    bokningstid TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (bokning_id),
    FOREIGN KEY (medlem_id) REFERENCES Medlemmar(medlem_id) ON DELETE CASCADE,
    FOREIGN KEY (pass_id) REFERENCES Pass(pass_id) ON DELETE CASCADE
);

-- Skapa testdata
INSERT INTO Medlemmar (medlem_namn, medlem_email, medlem_telefon)
    VALUES ('Simon Michael','simon.michael@gmail.com','0706842947'),
           ('Madeleine Michael','madeleine.michael@hotmail.com','0702459217'),
           ('Adam Michelin', 'adam@michelin.se', '0726234506');

INSERT INTO Pass (pass_namn, pass_max_deltagare, pass_instruktor, pass_datum)
    VALUES ('Spinning',10,'Noomie Werlinder','2025-05-27 10:00:00'),
           ('Cirkel Gym', 15, 'Noomie Werlinder', '2025-05-27 18:00:00');

INSERT INTO Bokningar (medlem_id, pass_id)
    VALUES (4,2),
           (5,1),
           (6,2);

-- Visa data med íd
SELECT * FROM Medlemmar;
SELECT * FROM Pass;
SELECT * FROM Bokningar;

-- Visa data med namn
SELECT m.medlem_namn AS Medlemmar, p.pass_namn AS Pass,p.pass_datum AS Datum
FROM Bokningar b
JOIN Medlemmar m ON b.medlem_id = m.medlem_id
JOIN Pass p ON b.pass_id = p.pass_id;