CREATE DATABASE GymBokning;
USE GymBokning;

-- TABELLER --------------------------------------------------------------------------------------------------------------------
-- Skapa tabell för medlemmar
CREATE TABLE Medlemmar(
    medlem_id INT NOT NULL AUTO_INCREMENT,
    medlem_namn VARCHAR(50),
    medlem_email VARCHAR(50) UNIQUE,
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
-- -------------------------------------------------------------------------------------------------------------------

-- HÅRDKODAD TESTDATA -------------------------------------------------------------------------------------------------
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
-- -------------------------------------------------------------------------------------------------------------------------------

-- FUNKTIONER ---------------------------------------------------------------------------------------------------------------------
-- Skapa medlem
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

-- Skapa Pass
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

-- Visa medlemstabell
DELIMITER //
CREATE PROCEDURE GetAllMembers()
    BEGIN
        SELECT * FROM Medlemmar;
    END //

-- Visa passtabell
DELIMITER //
CREATE PROCEDURE GetAllPass()
    BEGIN
        SELECT * FROM Pass;
    END //

-- Visa Bokningstabell
DELIMITER //
CREATE PROCEDURE GetAllBookings()
    BEGIN
        SELECT * FROM Bokningar;
    END //

DELIMITER //

-- Tar bort medlem ---------Funkar den?--------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE DeleteMember(IN in_medlem_namn VARCHAR(50))
    BEGIN
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
            BEGIN
                ROLLBACK;
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Fel vid radering av medlem';
            END;

        START TRANSACTION;

        -- Kontrollera om medlem finns
        IF EXISTS (SELECT 1 FROM Medlemmar Where medlem_namn = in_medlem_namn) THEN
            DELETE FROM Medlemmar WHERE medlem_namn = in_medlem_namn;
            COMMIT;
        ELSE
            ROLLBACK;
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Medlemmen existerar inte';
        END IF;
    END //

    DELIMITER

-- -----------------------------------------------------------------------------------------------------------------------------------------

-- ANROP -----------------------------------------------------------------------------------------------------------------------------------
-- Skapa pass
CALL CreatePass('Gympa','20','Simon Michael','2025-05-20 20:00:00');

-- Skapa medlem
CALL CreateMember('Peter Michael', 'peter.michael@gmail.com', '0723452817');

-- Hämta medlemstabell
CALL GetAllMembers();

-- Hämta passtabell
CALL GetAllPass();

-- Hämta bokningstabell
CALL GetAllBookings();

CALL DeleteMember('Simon Michael');
-- ---------------------------------------------------------------------------------------------------------------------------------------


-- Visa data med namn
SELECT m.medlem_namn AS Medlemmar, p.pass_namn AS Pass,p.pass_datum AS Datum
FROM Bokningar b
INNER JOIN Medlemmar m ON b.medlem_id = m.medlem_id
INNER JOIN Pass p ON b.pass_id = p.pass_id;
