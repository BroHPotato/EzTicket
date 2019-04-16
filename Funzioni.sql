
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
