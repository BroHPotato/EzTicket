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
