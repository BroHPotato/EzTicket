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
