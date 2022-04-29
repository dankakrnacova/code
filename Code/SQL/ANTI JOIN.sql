INSERT INTO danka.Table3 
	SELECT * FROM danka.Table1 
	EXCEPT 
	SELECT * FROM danka.Table2
UNION ALL
	SELECT * FROM danka.Table2 
	EXCEPT 
	SELECT * FROM danka.Table1