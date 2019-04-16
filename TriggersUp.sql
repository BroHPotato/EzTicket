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
