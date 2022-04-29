CREATE schema danka
GRANT USAGE, CREATE ON SCHEMA danka TO public 

CREATE TABLE danka.MojaTabulka (
	IDZamestnanec int,
	Meno varchar(15),
	Priezvisko varchar(20),
	Vek int,
	AktivnyStav boolean,
	Nastup date	
)

DROP TABLE danka.TransactionsPerAccount  

CREATE TABLE danka.MojaTab AS 
	SELECT NazovUctu, YEAR(CasZaciatok) AS RokTransakcie, COUNT(IDTransakciaZapisane) AS PocetTransakcii 
	FROM colnasprava.EPSUcet
	LEFT JOIN colnasprava.SYSTransakcia
	ON EPSUcet.IDUcet = SYSTransakcia.IDUcet 
	GROUP BY NazovUctu, YEAR(CasZaciatok)
	HAVING YEAR(SYSTransakcia.CasZaciatok) > 2016	
	ORDER BY NazovUctu ASC, RokTransakcie DESC
	
ALTER TABLE danka.MojaTab RENAME TO TransactionsPerAccount;
	
SELECT * FROM danka.TransactionsPerAccount 

CREATE TABLE danka.Pouzivatel AS 
	SELECT * FROM colnasprava.EPSPouzivatel
	
SELECT Nazov, COUNT(IDTransakciaZapisane) AS PocetTransakcii
FROM danka.Pouzivatel 
GROUP BY Nazov
HAVING COUNT(IDTransakciaZapisane) > 1

CREATE TABLE danka.Transakcia AS 
	SELECT * FROM colnasprava.SYSTransakcia 

SELECT MAX(CasKoniec) FROM danka.Transakcia 

SELECT * FROM danka.Transakcia 
WHERE MONTH(CasKoniec) = 3

SELECT MONTH(CasZaciatok) AS MesiacTransakcie, COUNT(IDTransakcia) AS PocetTransakcii 
FROM danka.Transakcia 
GROUP BY MesiacTransakcie
ORDER BY PocetTransakcii DESC 
