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
('PYYGMR93A28E379G','Gianmarco','Pettinato','1993-01-28',NULL),
('BNCFNC00T66B519N','Francesca','Bianchi','2000-12-26','3652895305'),
('LSKLNR89L61L378Y','Eleonora','Losiouk','1989-07-21',NULL),
('SPLRCR86R10L736V','Riccardo','Spolaor','1986-10-10',NULL),
('PNTGRL90B28D883E','Gabriele','Ponte','1990-02-28','8352049385'),
('BRBVNC97H45B196R','Veronica','Barbieri','1997-06-05',NULL),
('TLPFLL00T26G224Y','Fiorello','Tulipano','2000-12-26','333887759'),
('CSTFNC82R49G224K','Francesca','Costa','1982-10-09','88263485593'),
('PRDBRC91E52A662B','Beatrice','Paradiso','1991-05-12','3393710154');

INSERT INTO Biglietto (IdFiera,	IdEvento, Tipo,	Prezzo,	DEmissione,	DataInizioValidita, Cliente) VALUES
('17ed201800','000','Abb4gg','37.50',NOW(),'2018-10-28','PYYGMR93A28E379G'),
('17ed201800','000','Abb4gg','37.50',NOW(),'2018-10-28','BTTGPP95A07I330Q'),
('17ed201800','000','Abb4gg','37.50',NOW(),'2018-10-28','BRBVNC97H45B196R'),
('17ed201800','000','Abb4gg','37.50',NOW(),NULL,'PRDBRC91E52A662B'),
('17ed201800','000','Base','10.00',NOW(),'2018-10-28','CNTMRA68M15G224Z'),
('17ed201800','001','Base','10.00',NOW(),NULL,'SPLRCR86R10L736V'),
('17ed201800','001','Base','10.00',NOW(),NULL,'SPLRCR86R10L736V'),
('79a4201800','001','BaseRid','7.00',NOW(),'2018-10-28','LSKLNR89L61L378Y'),
('79a4201800','001','BaseRid','7.00',NOW(),NULL,'PRDBRC91E52A662B'),
('79a4201800','001','BaseRid','7.00',NOW(),NULL,'PRDBRC91E52A662B'),
('79a4201800','002','Base','10.00',NOW(),NULL,'LSKLNR89L61L378Y'),
('79a4201800','002','Base','10.00',NOW(),'2018-10-28','CNTMRA68M15G224Z'),
('79a4201800','002','Base','10.00',NOW(),'2018-10-28','CNTMRA68M15G224Z'),
('79a4201800','002','Base','10.00',NOW(),'2018-10-28','SPLRCR86R10L736V'),
('79a4201800','002','Base','10.00',NOW(),'2018-10-28','LVSGDU60E19L736G'),
('79a4201800','002','Base','10.00',NOW(),'2018-10-28','LVSGDU60E19L736G'),
('79a4201800','002','Base','10.00',NOW(),'2018-10-28','LVSGDU60E19L736G'),
('79a4201800','002','Base','10.00',NOW(),'2018-10-28','LVSGDU60E19L736G'),
('e695201800','000','Base','10.00',NOW(),'2018-10-28','RSSMRA80A01H501U'),
('e695201800','000','Base','10.00',NOW(),'2018-10-28','CSTFNC82R49G224K'),
('e695201800','001','Base','5.00',NOW(),'2018-10-28','BNCFNC00T66B519N'),
('e695201800','001','Base','5.00',NOW(),'2018-10-28','PNTGRL90B28D883E'),
('e695201800','001','Base','5.00',NOW(),'2018-10-28','PNTGRL90B28D883E'),
('e695201800','002','Base','5.00',NOW(),'2018-10-28','TLPFLL00T26G224Y'),
('e695201800','002','Base','5.00',NOW(),'2018-10-28','TLPFLL00T26G224Y'),
('e695201800','002','Base','5.00',NOW(),'2018-10-28','CNTMRA68M15G224Z'),
('e695201800','002','Base','5.00',NOW(),'2018-10-28','CNTMRA68M15G224Z');
