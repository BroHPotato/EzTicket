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
  IF (NTicket>=(SELECT Capienza FROM PadiglioniEventi WHERE IdEvento=NEW.IdEvento AND IdFiera=NEW.IdFiera) THEN
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
