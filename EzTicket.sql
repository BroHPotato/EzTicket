CREATE DATABASE IF NOT EXISTS EzTicket;

USE EzTicket;

CREATE TABLE IF NOT EXISTS Fiera (
  Id char(10) PRIMARY KEY,
  Nome char(255) NOT NULL,
  Città char(255) NOT NULL,
  Luogo char(255),
  DataInizio date NOT NULL,
  DataFine date NOT NULL
);

CREATE TABLE IF NOT EXISTS Padiglione(
  Id char(3) NOT NULL,
  Città char(30) NOT NULL,
  Luogo char(30) NOT NULL,
  Capienza int(5),
  PRIMARY KEY(Id, Luogo, Città)
);

CREATE TABLE IF NOT EXISTS Evento(
  Id char (3),
  IdFiera char(10),
  Nome char(255) NOT NULL,
  Padiglione char(3),
  DataInizio datetime NOT NULL,
  DataFine datetime NOT NULL,
  FOREIGN KEY (Padiglione) REFERENCES Padiglione(Id)
  ON DELETE SET NULL
  ON UPDATE CASCADE,
  FOREIGN KEY (IdFiera) REFERENCES Fiera(Id)
  ON DELETE CASCADE
  ON UPDATE CASCADE ,
  PRIMARY KEY(Id, IdFiera)
);

CREATE TABLE IF NOT EXISTS Tariffa (
   IdFiera  char(10) NOT NULL,
   IdEvento char(10) NOT NULL,
   Tipo char(10) NOT NULL,
   Prezzo decimal(4,2) NOT NULL,
   Giorni int(2),
   FOREIGN KEY (IdFiera,IdEvento) REFERENCES Evento (IdFiera,Id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
   PRIMARY KEY (IdFiera, IdEvento, Tipo, Prezzo)
 );

CREATE TABLE IF NOT EXISTS Cliente (
  CF char(16) NOT NULL PRIMARY KEY UNIQUE,
 	Nome char(255) NOT NULL,
 	Cognome char(255) NOT NULL,
 	DataNascita DATE NOT NULL,
 	NTelefono char(13)
 );

 CREATE TABLE IF NOT EXISTS Biglietto (
  Id int(8) NOT NULL,
 	IdFiera char(10) NOT NULL,
 	IdEvento char(10)NOT NULL,
 	Tipo char(10) NOT NULL,
  Prezzo decimal(4,2) NOT NULL,
 	DEmissione datetime DEFAULT NOW() NOT NULL,
  DataInizioValidita datetime NOT NULL,
  DataFineValidita datetime NOT NULL,
  DataConvalida datetime,
 	Cliente char(16) NOT NULL,
 	PRIMARY KEY (Id,IdFiera,IdEvento),
 		UNIQUE (Id,IdFiera,IdEvento),
 	FOREIGN KEY(IdFiera, IdEvento, Tipo, Prezzo) REFERENCES Tariffa (IdFiera, IdEvento, Tipo, Prezzo)
 		ON DELETE RESTRICT
 		ON UPDATE RESTRICT,
 	FOREIGN KEY (Cliente) REFERENCES Cliente (CF)
 		ON DELETE RESTRICT
 		ON UPDATE CASCADE
 	);

  ##QUERY

  ##Incasso delle Fiere
  CREATE VIEW Incasso AS SELECT Fiera.Nome, sum(Prezzo) AS Incasso FROM Biglietto, Fiera WHERE Biglietto.IdFiera=Fiera.id;

  ## Fiere con il numero di padiglioni usati
  CREATE VIEW NPadUsati AS SELECT Fiera.Nome, count(Padiglione) as Padiglioni FROM Evento LEFT JOIN Fiera ON Evento.IdFiera=Fiera.Id group by Fiera.Id;

  ##Media dei Padiglioni usati in ogni Fiera
  CREATE VIEW MediaPadiglioni AS SELECT c.Nome, AVG(Padiglioni) as Media FROM NPadUsati as c group by c.Nome;

  ##Fiere con i relativi eventi e Tariffario
  CREATE VIEW InfoFiere AS SELECT Fiera.Nome,Città,Luogo,Padiglione, Evento.Nome as NomeEvento, Evento.DataInizio,Evento.DataFine, Tipo, Prezzo FROM Fiera LEFT JOIN Evento ON Fiera.id=Evento.IdFiera LEFT JOIN Tariffa ON Evento.Id=Tariffa.IdEvento AND Tariffa.IdFiera=Evento.IdFiera;

  ##Fiere con i relativi eventi, date, padiglioni con Capienza
  CREATE VIEW PadiglioniEventi AS SELECT Fiera.id as IdFiera, Evento.Id as IdEvento, Padiglione.Id as IdPadiglione, Fiera.Città, Fiera.Luogo,Padiglione.Capienza, Evento.DataInizio, Evento.DataFine, Evento.Nome as 'Evento', Fiera.Nome as 'Fiera' FROM Evento LEFT JOIN Fiera ON Evento.IdFiera=Fiera.Id LEFT JOIN Padiglione ON Evento.Padiglione=Padiglione.Id AND Fiera.Città=Padiglione.Città AND Fiera.Luogo=Padiglione.Luogo WHERE !IsNull(Evento.Padiglione);


  ##PROCEDURE

  DELIMITER $$
  DROP PROCEDURE IF EXISTS PadDisp;
  CREATE PROCEDURE PadDisp (IN FDataInizio datetime, IN FDataFine datetime,IN FCittà char(30))
  SELECT * FROM Padiglione WHERE Città=FCittà AND (Id,Città,Luogo) NOT IN(SELECT IdPadiglione,Città,Luogo FROM PadiglioniEventi WHERE !(FDataFine<PadiglioniEventi.DataInizio OR FDataInizio>PadiglioniEventi.DataFine ));
  $$
  DELIMITER ;

  DELIMITER $$
  DROP PROCEDURE IF EXISTS MaxCapFiera;
  CREATE PROCEDURE MaxCapFiera (IN FId char(10))
  SELECT Fiera.Nome, Padiglione.Città, Padiglione.Luogo, sum(Capienza) as Capienza FROM Padiglione, Fiera WHERE (Padiglione.Id,Padiglione.Città,Padiglione.Luogo,Fiera.Id) IN (SELECT Padiglione as Id, Città, Luogo, Fiera.Id as IdFiera FROM Fiera  LEFT JOIN Evento ON Fiera.Id=Evento.IdFiera WHERE Fiera.Id=FId AND !IsNull(Padiglione));
  $$
  DELIMITER ;

  DELIMITER $$
  DROP PROCEDURE IF EXISTS VenditeFiera;
  CREATE PROCEDURE VenditeFiera (IN FId char(10))
  SELECT Fiera.Nome, count(*) AS NumeroBiglietti FROM Biglietto, Fiera WHERE (IdFiera, Fiera.Nome) in (SELECT Id, Nome  FROM Fiera WHERE Id=FId);
  $$
  DELIMITER ;

  DELIMITER $$
  DROP PROCEDURE IF EXISTS PersoneInFiera;
  CREATE PROCEDURE PersoneInFiera (IN FId char(10))
  SELECT Fiera.Nome, count(*) AS 'Persone in fiera' FROM Biglietto, Fiera WHERE (IdFiera, Fiera.Nome) in (SELECT Id, Nome  FROM Fiera WHERE Id=FId) AND !IsNull(DataConvalida);
  $$
  DELIMITER ;

  DELIMITER $$
  DROP PROCEDURE IF EXISTS BigliettiCompratiDaCliente;
  CREATE PROCEDURE BigliettiCompratiDaCliente (IN FCF char(16),IN FY int)
  SELECT  Cliente.Nome, Cliente.Cognome, count(*) as Biglietti_Acquistati FROM Cliente LEFT JOIN Biglietto ON Cliente.CF=Biglietto.Cliente WHERE CF=FCF AND YEAR(DEmissione)=FY;
  $$
  DELIMITER ;

  DELIMITER $$
  DROP PROCEDURE IF EXISTS EventoTop;
  CREATE PROCEDURE EventoTop (IN FId char(10))
  SELECT Evento.Nome, count(*) as ingressi FROM Biglietto, Evento WHERE Biglietto.IdFiera=FId AND Evento.IdFiera=FId AND Biglietto.IdEvento=Evento.Id group by (Biglietto.IdEvento) order by ingressi DESC LIMIT 1;
  $$
  DELIMITER ;

  DELIMITER $$
  DROP PROCEDURE IF EXISTS EventoTariffa;
  CREATE PROCEDURE EventoTariffa (IN FNomeEvento varchar(10))
  SELECT * FROM InfoFiere WHERE NomeEvento=FNomeEvento;
  $$
  DELIMITER ;

  DELIMITER $$
  DROP PROCEDURE IF EXISTS EventoTempo;
  CREATE PROCEDURE EventoTempo (IN FDataInizio datetime, IN FDataFine datetime)
  SELECT Fiera.Nome,Città,Luogo,Padiglione, Evento.Nome, Evento.DataInizio,Evento.DataFine FROM Fiera LEFT JOIN Evento ON Fiera.id=Evento.IdFiera WHERE FDataInizio>=Evento.DataInizio AND FDataFine<=Evento.DataFine;
  $$
  DELIMITER ;

  ##FUNZIONI

  DELIMITER $$
  DROP FUNCTION IF EXISTS CreateFieraId;
  CREATE FUNCTION CreateFieraId (FNome varchar(255),FCittà varchar(255),FData DATE) returns char(10)
  BEGIN
    DECLARE BigId char(10);
    DECLARE TempId VARCHAR(10);
    DECLARE Numb int(2);
    SET TempId = CONCAT(CONVERT (MD5(CONCAT(FNome,' ',FCittà)),char(4)), YEAR(FData));
    SELECT Id FROM Fiera where Id LIKE (CONCAT(TempId,'%')) order by Id DESC LIMIT 1 INTO BigId;
    IF IsNull(BigId)=1 THEN
     SET TempId = CONCAT(TempId,'00');
    ELSE
     SET Numb = CONVERT ((SELECT RIGHT (BigId,2)), int);
     IF Numb>=99 THEN
       SIGNAL SQLSTATE '45000'
       SET MYSQL_ERRNO=30001,
       MESSAGE_TEXT='Impossibile creare la Fiera con questo nome';
     END IF;
     SET Numb = Numb + 1;
     IF Numb < 10 THEN
       SET TempId = CONCAT(TempId,'0',Numb);
     ELSE
       SET TempId = CONCAT(TempId,Numb);
     END IF;
    END IF;
    RETURN TempId;
  END$$
  DELIMITER ;

  DELIMITER $$
  DROP FUNCTION IF EXISTS CreateEventId;
  CREATE FUNCTION CreateEventId (FIdFiera varchar(10)) RETURNS char(3)
  BEGIN
  DECLARE LastId char(3);
  SET LastId = CONVERT((SELECT Id FROM Evento WHERE Evento.IdFiera=FIdFiera order by Id DESC LIMIT 1), int) + 1;
  IF IsNull(LastId) THEN
    SET LastId = '000';
  ELSEIF LastId < 10 THEN
    SET LastId = CONCAT('00',LastId);
  ELSEIF LastId < 100 THEN
    SET LastId = CONCAT('0',LastId);
  END IF;
  RETURN LastId;
  END$$
  DELIMITER ;

  ##TRIGGERS

  DELIMITER ||
  DROP TRIGGER IF EXISTS CreateId;
  CREATE TRIGGER CreateId
    BEFORE insert on Fiera FOR EACH ROW
    BEGIN
    SET NEW.Id = CreateFieraId(NEW.Nome,NEW.Città,NEW.DataInizio);
    END ||
  DELIMITER ;

  DELIMITER ||
  DROP TRIGGER IF EXISTS CreatEvent;
  CREATE TRIGGER CreatEvent
    AFTER insert on Fiera FOR EACH ROW
    BEGIN
    INSERT INTO `Evento` (`Id`, `IdFiera`, `Nome`, `Padiglione`, `DataInizio`, `DataFine`) VALUES ('000', NEW.Id, NEW.Nome, NULL, NEW.DataInizio, NEW.DataFine);
    END ||
  DELIMITER ;

  DELIMITER ||
  DROP TRIGGER IF EXISTS ValidTicket;
  CREATE TRIGGER ValidTicket
    BEFORE insert on Biglietto FOR EACH ROW
    BEGIN
    DECLARE Cgiorni int;
    DECLARE NTicket int;
    DECLARE NId int(8);
    SELECT Id FROM Biglietto WHERE IdEvento=NEW.IdEvento AND IdFiera=NEW.IdFiera ORDER BY Id DESC LIMIT 1 INTO NId;
    IF IsNull(NId) != 1 THEN
      SET NEW.Id = NId+1;
    ELSE
      SET NEW.Id=0;
    END IF;
    IF ((NEW.DataInizioValidita < (SELECT DataInizio FROM Evento WHERE Id=NEW.IdEvento AND IdFiera=NEW.IdFiera LIMIT 1)) OR
        (NEW.DataInizioValidita > (SELECT DataFine FROM Evento WHERE Id=NEW.IdEvento AND IdFiera=NEW.IdFiera LIMIT 1))) OR
    IsNull(NEW.DataInizioValidita) THEN
          SET NEW.DataInizioValidita = (SELECT DataInizio FROM Evento WHERE Id=NEW.IdEvento AND IdFiera=NEW.IdFiera LIMIT 1);
    END IF;
    SELECT count(*) FROM Biglietto WHERE IdEvento=NEW.IdEvento AND IdFiera=NEW.IdFiera INTO NTicket;
    SELECT Giorni FROM Tariffa WHERE IdEvento=NEW.IdEvento AND IdFiera=NEW.IdFiera AND Tipo=NEW.Tipo AND Prezzo=NEW.Prezzo LIMIT 1 INTO Cgiorni;
    SET NEW.DataFineValidita = DATE_ADD(NEW.DataInizioValidita, INTERVAL Cgiorni DAY);
    IF (NEW.DataFineValidita > (SELECT DataFine FROM Evento WHERE Id=NEW.IdEvento AND IdFiera=NEW.IdFiera LIMIT 1)) THEN
      SET NEW.DataFineValidita = (SELECT DataFine FROM Evento WHERE Id=NEW.IdEvento AND IdFiera=NEW.IdFiera LIMIT 1);
    END IF;
    IF (NTicket>=(SELECT Capienza FROM PadiglioniEventi WHERE IdEvento=NEW.IdEvento AND IdFiera=NEW.IdFiera)) THEN
      SIGNAL SQLSTATE '45000'
      SET MYSQL_ERRNO=30002,
      MESSAGE_TEXT='Capienza massima superata impossibile creare il biglietto';
    END IF;
    END ||
  DELIMITER ;

  DELIMITER ||
  DROP TRIGGER IF EXISTS ControlEvent;
  CREATE TRIGGER ControlEvent
  BEFORE insert on Evento FOR EACH ROW
  BEGIN
    DECLARE DIni datetime;
    DECLARE DFin datetime;
    DECLARE FLuogo char(30);
    DECLARE FCittà char(30);
    SELECT Fiera.DataInizio FROM Fiera WHERE Fiera.Id=NEW.IdFiera LIMIT 1 INTO DIni;
    SELECT Fiera.DataFine FROM Fiera WHERE Fiera.Id=NEW.IdFiera LIMIT 1 INTO DFin;
    SET NEW.Id=CreateEventId(NEW.IdFiera);
    IF IsNull(NEW.DataInizio) THEN
      SET NEW.DataInizio=DIni;
    END IF;
    IF IsNull(NEW.DataInizio) THEN
        SET NEW.DataFine=DFin;
    END IF;
    IF DIni>NEW.DataInizio OR DFin<NEW.DataFine OR NEW.DataInizio>NEW.DataFine THEN
        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO=30003,
        MESSAGE_TEXT='Evento non conforme alle date della Fiera';
    END IF;
    SELECT Città FROM Fiera WHERE Id = NEW.IdFiera INTO FCittà;
    SELECT Luogo FROM Fiera WHERE Id = NEW.IdFiera INTO FLuogo;
    IF !IsNull(FLuogo) THEN
      IF !IsNull(NEW.Padiglione) AND (NEW.Padiglione NOT IN ( SELECT Id FROM Padiglione WHERE (Id,Città,Luogo) NOT IN(SELECT IdPadiglione,Città,Luogo FROM PadiglioniEventi WHERE !(NEW.DataFine<PadiglioniEventi.DataInizio OR NEW.DataInizio>PadiglioniEventi.DataFine )) AND Città=FCittà AND Luogo=FLuogo )) THEN
        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO=30004,
        MESSAGE_TEXT='Padiglione non disponibile';
      END IF;
    ELSE
      IF !IsNull(NEW.Padiglione) THEN
        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO=30005,
        MESSAGE_TEXT='Non puoi selezionare un Padiglione';
      END IF;
    END IF;
  END ||
  DELIMITER ;

  DELIMITER ||
  DROP TRIGGER IF EXISTS CreateTariffa;
  CREATE TRIGGER CreateTariffa
    AFTER insert on Evento FOR EACH ROW
    BEGIN
    DECLARE PrezzoBase DECIMAL(4,2);
    SET PrezzoBase='10.00';
    INSERT INTO `Tariffa` (`IdFiera`, `IdEvento`, `Tipo`, `Prezzo`, `Giorni`) VALUES (NEW.IdFiera,NEW.Id,'Default',PrezzoBase,'1');
    END ||
  DELIMITER ;

  DELIMITER ||
  DROP TRIGGER IF EXISTS ControlEventUpdate;
  CREATE TRIGGER ControlEventUpdate
  BEFORE UPDATE on Evento FOR EACH ROW
  BEGIN
    DECLARE DIni datetime;
    DECLARE DFin datetime;
    DECLARE FLuogo char(30);
    DECLARE FCittà char(30);
    SELECT Fiera.DataInizio FROM Fiera WHERE Fiera.Id=NEW.IdFiera LIMIT 1 INTO DIni;
    SELECT Fiera.DataFine FROM Fiera WHERE Fiera.Id=NEW.IdFiera LIMIT 1 INTO DFin;
    SET NEW.Id=CreateEventId(NEW.IdFiera);
    IF IsNull(NEW.DataInizio) THEN
      SET NEW.DataInizio=DIni;
    END IF;
    IF IsNull(NEW.DataInizio) THEN
        SET NEW.DataFine=DFin;
    END IF;
    IF DIni>NEW.DataInizio OR DFin<NEW.DataFine OR NEW.DataInizio>NEW.DataFine THEN
        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO=30003,
        MESSAGE_TEXT='Evento non conforme alle date della Fiera';
    END IF;
    SELECT Città FROM Fiera WHERE Id = NEW.IdFiera INTO FCittà;
    SELECT Luogo FROM Fiera WHERE Id = NEW.IdFiera INTO FLuogo;
    IF !IsNull(FLuogo) THEN
      IF !IsNull(NEW.Padiglione) AND (NEW.Padiglione NOT IN ( SELECT Id FROM Padiglione WHERE (Id,Città,Luogo) NOT IN(SELECT IdPadiglione,Città,Luogo FROM PadiglioniEventi WHERE !(NEW.DataFine<PadiglioniEventi.DataInizio OR NEW.DataInizio>PadiglioniEventi.DataFine )) AND Città=FCittà AND Luogo=FLuogo )) THEN
        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO=30004,
        MESSAGE_TEXT='Padiglione non disponibile';
      END IF;
    ELSE
      IF !IsNull(NEW.Padiglione) THEN
        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO=30005,
        MESSAGE_TEXT='Non puoi selezionare un Padiglione';
      END IF;
    END IF;
  END ||
  DELIMITER ;

  DELIMITER ||
  DROP TRIGGER IF EXISTS CheckBiglietto;
  CREATE TRIGGER CheckBiglietto
    BEFORE UPDATE on Biglietto FOR EACH ROW
    BEGIN
    IF NEW.DataConvalida > OLD.DataFineValidita THEN
      SIGNAL SQLSTATE '45000'
      SET MYSQL_ERRNO=30006,
      MESSAGE_TEXT='Il biglietto non è valido';
    END IF;
    END ||
  DELIMITER ;

  ##POPOLAMENTO

  INSERT INTO Fiera (Nome, Città, Luogo, DataInizio, DataFine) VALUES
  ('Fiera campionaria','Padova','Fiera','2018-05-10','2018-05-18'),
  ('Fiera campionaria','Padova','Fiera','2018-09-20','2018-09-30'),
  ('Fiera del Radioamatore ed Elettronica','Pordenone','Fiera','2018-09-20','2018-09-30'),
  ('Lucca Comix & Games', 'Lucca', NULL,'2018-10-28','2018-10-31'),
  ('MantovaComix','Mantova','Fiera','2018-08-28','2018-09-3'),
  ('Carnevale','Ivrea',NULL,'2018-02-8','2018-02-13'),
  ('Carnevale','Venezia',NULL,'2018-02-8','2018-02-13');

  INSERT INTO Padiglione(Id,Città, Luogo, Capienza) VALUES
  ('P01','Padova','Fiera','500'),
  ('P02','Padova','Fiera','300'),
  ('P03','Padova','Fiera','50'),
  ('P04','Padova','Fiera','500'),
  ('P01','Padova','Geox','100'),
  ('P02','Padova','Geox','30'),
  ('P01','Mantova','Fiera','500'),
  ('P02','Mantova','Fiera','100'),
  ('P03','Mantova','Fiera','253'),
  ('P01','Pordenone','Fiera','500'),
  ('P02','Pordenone','Fiera','236');

  INSERT INTO Evento (IdFiera, Nome, Padiglione, DataInizio, DataFine) VALUES
  ('17ed201800','Gara di cosplay',NULL,'2018-10-31','2018-10-31'),
  ('cf3e201800','Gara di cosplay','P03','2018-08-31','2018-08-31'),
  ('79a4201800','Degustazione di cioccolato','P01','2018-05-15','2018-05-16'),
  ('79a4201800','Spritz','P02','2018-05-15','2018-05-16'),
  ('79a4201801','Spritz','P02','2018-09-25','2018-09-26'),
  ('e695201800','Esposizione radio d´epoca','P01','2018-09-20','2018-09-30'),
  ('e695201800','Comunicazione Internazionale','P02','2018-09-20','2018-09-30');

  INSERT INTO Tariffa (IdFiera, IdEvento, Tipo, Prezzo, Giorni) VALUES
  ('17ed201800','000','Abb4gg','37.50','4'),
  ('17ed201800','000','BaseRid','7.50','1'),
  ('17ed201800','000','Abb4ggRid','7.50','4'),
  ('79a4201800','001','BaseRid','7.00','1'),
  ('79a4201801','000','Abb3gg','18.00','3'),
  ('e695201800','001','Base','5.00','1'),
  ('e695201800','002','Base','5.00','1');

  INSERT INTO Cliente (CF, Nome, Cognome, DataNascita, NTelefono) VALUES
  ('RSSMRA80A01H501U','Mario','Rossi','1980-01-01','3995304855'),
  ('LVSGDU60E19L736G','Guido','Lavespa','1960-05-19','3927493740'),
  ('CNTMRA68M15G224Z','Mauro','Conti','1968-08-15',NULL),
  ('BTTGPP95A07I330Q','Giuseppe Vito','Bitetti','1995-01-07',NULL),
  ('PTTGMR93A28E379G','Gianmarco','Pettinato','1993-01-28',NULL),
  ('BNCFNC00T66B519N','Francesca','Bianchi','2000-12-26','3652895305'),
  ('LSKLNR89L61L378Y','Eleonora','Losiouk','1989-07-21',NULL),
  ('SPLRCR86R10L736V','Riccardo','Spolaor','1986-10-10',NULL),
  ('PNTGRL90B28D883E','Gabriele','Ponte','1990-02-28','8352049385'),
  ('BRBVNC97H45B196R','Veronica','Barbieri','1997-06-05',NULL),
  ('TLPFLL00T26G224Y','Fiorello','Tulipano','2000-12-26','333887759'),
  ('CSTFNC82R49G224K','Francesca','Costa','1982-10-09','88263485593'),
  ('GGIDST00P13L378A','Gigi','Dagostino','1900-09-13',NULL),
  ('PRDBRC91E52A662B','Beatrice','Paradiso','1991-05-12','3393710154');

  INSERT INTO Biglietto (IdFiera,	IdEvento, Tipo,	Prezzo,	DataInizioValidita, Cliente) VALUES
  ('17ed201800','000','Abb4gg','37.50','2018-10-28','PTTGMR93A28E379G'),
  ('17ed201800','000','Abb4gg','37.50','2018-10-28','BTTGPP95A07I330Q'),
  ('17ed201800','000','Abb4gg','37.50','2018-10-28','BRBVNC97H45B196R'),
  ('17ed201800','000','Abb4gg','37.50',NULL,'PRDBRC91E52A662B'),
  ('17ed201800','000','Default','10.00','2018-10-28','CNTMRA68M15G224Z'),
  ('17ed201800','001','Default','10.00',NULL,'SPLRCR86R10L736V'),
  ('17ed201800','001','Default','10.00',NULL,'SPLRCR86R10L736V'),
  ('79a4201800','001','BaseRid','7.00','2018-10-28','LSKLNR89L61L378Y'),
  ('79a4201800','001','BaseRid','7.00',NULL,'PRDBRC91E52A662B'),
  ('79a4201800','001','BaseRid','7.00',NULL,'PRDBRC91E52A662B'),
  ('79a4201800','002','Default','10.00',NULL,'LSKLNR89L61L378Y'),
  ('79a4201800','002','Default','10.00','2018-10-28','CNTMRA68M15G224Z'),
  ('79a4201800','002','Default','10.00','2018-10-28','CNTMRA68M15G224Z'),
  ('79a4201800','002','Default','10.00','2018-10-28','SPLRCR86R10L736V'),
  ('79a4201800','002','Default','10.00','2018-10-28','LVSGDU60E19L736G'),
  ('79a4201800','002','Default','10.00','2018-10-28','LVSGDU60E19L736G'),
  ('79a4201800','002','Default','10.00','2018-10-28','LVSGDU60E19L736G'),
  ('79a4201800','002','Default','10.00','2018-10-28','LVSGDU60E19L736G'),
  ('e695201800','000','Default','10.00','2018-10-28','RSSMRA80A01H501U'),
  ('e695201800','000','Default','10.00','2018-10-28','CSTFNC82R49G224K'),
  ('e695201800','001','Base','5.00','2018-10-28','BNCFNC00T66B519N'),
  ('e695201800','001','Base','5.00','2018-10-28','PNTGRL90B28D883E'),
  ('e695201800','001','Base','5.00','2018-10-28','PNTGRL90B28D883E'),
  ('e695201800','002','Base','5.00','2018-10-28','TLPFLL00T26G224Y'),
  ('e695201800','002','Base','5.00','2018-10-28','TLPFLL00T26G224Y'),
  ('e695201800','002','Base','5.00','2018-10-28','CNTMRA68M15G224Z'),
  ('e695201800','002','Base','5.00','2018-10-28','CNTMRA68M15G224Z');
