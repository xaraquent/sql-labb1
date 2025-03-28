CREATE DATABASE GymBokning;
USE GymBokning;

-- Skapa tabell för medlemmar
CREATE TABLE Medlemmar(
    medlem_id INT NOT NULL AUTO_INCREMENT,
    medlem_namn VARCHAR(50),
    medlem_email VARCHAR(50) UNIQUE,
    medlem_telefon VARCHAR(10),
    medlem_aktiv BOOLEAN DEFAULT 1,
    PRIMARY KEY (medlem_id)
);

DELIMITER //
CREATE PROCEDURE CreateMember(
    IN in_medlem_namn VARCHAR(50),
    IN in_medlem_email VARCHAR(50),
    IN in_medlem_telefon VARCHAR(10)
)
    BEGIN
        INSERT INTO Medlemmar(medlem_namn, medlem_email, medlem_telefon)
            VALUES (in_medlem_namn,in_medlem_email,in_medlem_telefon);
    END //

CALL CreateMember('Peter Michael', 'peter.michael@gmail.com', '0723452817');

-- Skapa tabell för pass
CREATE TABLE Pass(
    pass_id INT NOT NULL AUTO_INCREMENT,
    pass_namn VARCHAR(100),
    pass_max_deltagare INT,
    pass_instruktor VARCHAR(50),
    pass_datum DATETIME NOT NULL,
    PRIMARY KEY (pass_id)
);

DELIMITER //
CREATE PROCEDURE CreatePass(
    IN in_pass_name VARCHAR(100),
    IN in_pass_max_deltagare INT,
    IN in_pass_instruktor VARCHAR(50),
    IN in_pass_datum DATETIME
)
    BEGIN
        INSERT INTO Pass(pass_namn, pass_max_deltagare, pass_instruktor, pass_datum)
            VALUES (in_pass_name,in_pass_max_deltagare,in_pass_instruktor,in_pass_datum);
    END //

CALL CreatePass('Gympa','20','Simon Michael','2025-05-20 20:00:00');

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
    VALUES (1,2),
           (2,1),
           (3,2);


DELIMITER //
CREATE PROCEDURE GetAllMembers()
    BEGIN
        SELECT * FROM Medlemmar;
    END //

DELIMITER //
CREATE PROCEDURE GetAllPass()
    BEGIN
        SELECT * FROM Pass;
    END //

DELIMITER //
CREATE PROCEDURE GetAllBookings()
    BEGIN
        SELECT * FROM Bokningar;
    END //


CALL GetAllBookings();

-- Visa data med namn
SELECT m.medlem_namn AS Medlemmar, p.pass_namn AS Pass,p.pass_datum AS Datum
FROM Bokningar b
JOIN Medlemmar m ON b.medlem_id = m.medlem_id
JOIN Pass p ON b.pass_id = p.pass_id;