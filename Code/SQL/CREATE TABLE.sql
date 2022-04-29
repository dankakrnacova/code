CREATE TABLE vendor_dimension (
   vendor_key        INTEGER      NOT NULL PRIMARY KEY,
   vendor_name       VARCHAR(64),
   vendor_address    VARCHAR(64),
   vendor_city       VARCHAR(64),
   vendor_state      CHAR(2),
   vendor_region     VARCHAR(32),
   deal_size         INTEGER,
   last_deal_update  DATE
);

CREATE TABLE danka.Table1 (
	ID		INTEGER NOT NULL PRIMARY KEY,
	Name	VARCHAR(20),
	Surname	VARCHAR(20),
	Age		INTEGER
);

INSERT INTO danka.Table1 (
SELECT 1, 'Anna', 'Ggg', 38 UNION
SELECT 2, 'John', 'Aaa', 50 UNION 
SELECT 3, 'Karin', 'Hhh', 28
);