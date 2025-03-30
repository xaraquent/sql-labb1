CREATE DATABASE GymBokning;
USE GymBokning;

-- TABELLER ------------------------------------------------------------------------------------------------
-- Skapa tabell för medlemmar
CREATE TABLE Medlemmar(
    medlem_id INT NOT NULL AUTO_INCREMENT,
    medlem_namn VARCHAR(50),
    medlem_email VARCHAR(50) UNIQUE,
    medlem_telefon VARCHAR(10),
    medlem_aktiv BOOLEAN DEFAULT 0,
    PRIMARY KEY (medlem_id)
);

-- Skapa tabell för fakturor
CREATE TABLE Fakturor(
    faktura_id INT NOT NULL AUTO_INCREMENT,
    faktura_medlem_id INT,
    faktura_datum DATETIME DEFAULT CURRENT_TIMESTAMP,
    faktura_belopp DECIMAL (10,2) DEFAULT 199.00,
    faktura_status ENUM('Obetald','Betald') DEFAULT 'Obetald',
    PRIMARY KEY (faktura_id),
    FOREIGN KEY (faktura_medlem_id) REFERENCES Medlemmar(medlem_id) ON DELETE CASCADE
);

-- Skapa tabell för instruktörer
CREATE TABLE Instruktorer(
    instruktor_id INT NOT NULL AUTO_INCREMENT,
    instruktor_namn VARCHAR(50),
    instruktor_email VARCHAR(50) UNIQUE,
    instruktor_telefon VARCHAR(10),
    PRIMARY KEY (instruktor_id)
);

-- Skapa tabell för pass
CREATE TABLE Pass(
    pass_id INT NOT NULL AUTO_INCREMENT,
    pass_namn VARCHAR(100),
    pass_max_deltagare INT,
    pass_instruktor_id INT,
    pass_datum DATETIME NOT NULL,
    PRIMARY KEY (pass_id),
    FOREIGN KEY (pass_instruktor_id) REFERENCES Instruktorer(instruktor_id)
);

-- Skapa tabell för bokningar
CREATE TABLE Bokningar(
    bokning_id INT NOT NULL AUTO_INCREMENT,
    bokning_medlem_id INT,
    bokning_pass_id INT,
    bokningstid TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (bokning_id),
    FOREIGN KEY (bokning_medlem_id) REFERENCES Medlemmar(medlem_id) ON DELETE CASCADE,
    FOREIGN KEY (bokning_pass_id) REFERENCES Pass(pass_id)  ON DELETE CASCADE
);
-- ------------------------------------------------------------------------------------------------------

-- VYER -----------------------------------------------------------------------------------------------
-- Skapa bokningsvy
CREATE VIEW MedlemsBokningar AS
SELECT m.medlem_namn AS Medlemmar, p.pass_namn AS Pass,i.instruktor_namn AS Instruktörer,p.pass_datum AS Datum
FROM Bokningar b
INNER JOIN Medlemmar m ON b.bokning_medlem_id = m.medlem_id
INNER JOIN Pass p ON b.bokning_pass_id = p.pass_id
INNER JOIN Instruktorer i ON p.pass_instruktor_id = i.instruktor_id;
-- ---------------------------------------------------------------------------------------------------------

-- TRIGGER -----------------------------------------------------------------------------------------------
-- Trigger: När en bokning görs, skapa en faktura och aktivera medlemmen
DELIMITER //
CREATE TRIGGER AfterBookingInsert
    AFTER INSERT ON Bokningar
    FOR EACH ROW
        BEGIN
        -- Skapa en faktura för medlemmen
        INSERT INTO Fakturor (faktura_medlem_id) VALUES (new.bokning_medlem_id);

        -- Aktivera medlemmen om de bokar ett pass
        UPDATE Medlemmar SET medlem_aktiv = 1 WHERE medlem_id = new.bokning_medlem_id;
    END //

-- HÅRDKODAD TESTDATA ------------------------------------------------------------------------------------
-- Skapa testdata
INSERT INTO Medlemmar (medlem_namn, medlem_email, medlem_telefon)
    VALUES ('Simon Michael','simon.michael@gmail.com','0706842947'),
           ('Madeleine Michael','madeleine.michael@hotmail.com','0702459217'),
           ('Adam Michelin', 'adam@michelin.se', '0726234506');

INSERT INTO Instruktorer (instruktor_namn, instruktor_email, instruktor_telefon)
    VALUES ('Noomie Werlinder', 'noomie.werlinder@gmail.com','0723503790'),
           ('Per Werlinder','per.werlinder@gmail.com','0745234589');
;

INSERT INTO Pass (pass_namn, pass_max_deltagare, pass_instruktor_id, pass_datum)
    VALUES ('Spinning',10,1,'2025-05-27 10:00:00'),
           ('Cirkel Gym', 15, 2, '2025-05-27 18:00:00');

INSERT INTO Bokningar (bokning_medlem_id, bokning_pass_id)
    VALUES (1,2),
           (2,1),
           (3,2);

-- --------------------------------------------------------------------------------------------------------

-- FUNKTIONER --------------------------------------------------------------------------------------------
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
    IN in_pass_instruktor_id INT,
    IN in_pass_datum DATETIME
)
    BEGIN
        INSERT INTO Pass(pass_namn, pass_max_deltagare, pass_instruktor_id, pass_datum)
            VALUES (in_pass_name,in_pass_max_deltagare,in_pass_instruktor_id,in_pass_datum);
    END //

-- Visa medlemstabell
DELIMITER //
CREATE PROCEDURE GetAllMembers()
    BEGIN
        SELECT * FROM Medlemmar;
    END //

-- Visa fakturatabell
DELIMITER //
CREATE PROCEDURE GetAllInvoices()
    BEGIN
        SELECT * FROM Fakturor;
    END //

-- Visa instruktörstabell
DELIMITER //
CREATE PROCEDURE GetAllInstructors()
    BEGIN
        SELECT * FROM Instruktorer;
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

-- Betala faktura
DELIMITER //
CREATE PROCEDURE PayInvoice(
    IN in_faktura_id INT
)
    BEGIN
        DECLARE rows_affected INT;

        -- Uppdatera betalningsstatus
        UPDATE Fakturor
        SET faktura_status = 'Betald'
        WHERE faktura_id = in_faktura_id;

        -- Kontrollera om en rad faktiskt uppdaterades
        SET rows_affected = ROW_COUNT();

        IF rows_affected > 0 THEN
            SELECT CONCAT('Betalning med ID ', in_faktura_id, ' har markerats som betald.') AS Bekräftelse;
        ELSE
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ingen betalning hittades med det ID:t';
        END IF;
    END //

-- Tar bort medlem
DELIMITER //
CREATE PROCEDURE DeleteMember(
    IN in_medlem_namn VARCHAR(50)
)
    BEGIN
        START TRANSACTION;
        -- Kontrollera om medlem finns
        IF EXISTS (SELECT 1 FROM Medlemmar Where medlem_namn = in_medlem_namn) THEN
            DELETE FROM Medlemmar WHERE medlem_namn = in_medlem_namn;
            COMMIT;
            -- Bekräftelsemeddelande
            SELECT CONCAT('Medlem "', in_medlem_namn, '" har raderats.') AS Status;
        ELSE
            ROLLBACK;
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Medlemmen existerar inte';
        END IF;
    END //

-- Uppdatera email
DELIMITER //
CREATE PROCEDURE UpdateMemberEmail(
    IN in_medlem_id INT,
    IN new_medlem_email VARCHAR(50)
)
    BEGIN
        DECLARE rows_affected INT;

        -- Uppdaterar e-post
        UPDATE Medlemmar
        SET medlem_email = new_medlem_email
        WHERE medlem_id = in_medlem_id;

        -- Kontrollera om någon rad uppdaterades
        SET rows_affected = ROW_COUNT();

        IF rows_affected > 0 THEN
            SELECT CONCAT('E-post uppdaterad till: ', new_medlem_email) AS Bekräftelse;
        ELSE
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ingen medlem hittades med det ID:t';
        END IF;
    END //
-- --------------------------------------------------------------------------------------------------------

-- KALKYLERA -----------------------------------------------------------------------------------------------
-- Räkna antalet medlemmar
SELECT COUNT(*) AS AntalMedlemmar FROM Medlemmar;

-- Räkna antalet bokningar
SELECT COUNT(*) AS AntalBokningar FROM Bokningar;
-- -------------------------------------------------------------------------------------------------------

-- ANROP -------------------------------------------------------------------------------------------------
-- Skapa pass
CALL CreatePass('Gympa','20',1,'2025-05-20 20:00:00');

-- Skapa medlem
CALL CreateMember('Peter Michael', 'peter.michael@gmail.com', '0723452817');

-- Hämta medlemstabell
CALL GetAllMembers();

-- Hämta Betalningstabell
CALL GetAllInvoices();

-- Hämta instruktörstabell
Call GetAllInstructors();

-- Hämta passtabell
CALL GetAllPass();

-- Hämta bokningstabell
CALL GetAllBookings();

-- Uppdatera medlem
CALL UpdateMemberEmail(4,'peter.michael@BYTTEMAIL.com');

-- Betala faktura
CALL PayInvoice(2);

-- Radera medlem
CALL DeleteMember('Simon Michael');

-- Hämta medlemstabell igen efter ändringar
CALL GetAllMembers();

-- Hämta Betalningstabell igen efter betalning
CALL GetAllInvoices();

-- Visa tydligare bokningstabell
SELECT * FROM MedlemsBokningar;
-- -------------------------------------------------------------------------------------------------

-- DEV FUNCTIONS -------------------------------------------------------------------------------
-- SET FOREIGN_KEY_CHECKS = 0;
-- SET FOREIGN_KEY_CHECKS = 1;
-- DROP TABLE IF EXISTS Pass;
-- DROP PROCEDURE IF EXISTS UpdateMemberEmail;
-- DROP VIEW MedlemsBokningar;
-- DROP DATABASE GymBokning;
