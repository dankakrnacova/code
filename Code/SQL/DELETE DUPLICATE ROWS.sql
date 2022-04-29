SELECT [FirstName], 
    [LastName], 
    [Country], 
    COUNT(*) AS CNT
FROM [SampleDB].[dbo].[Employee]
GROUP BY [FirstName], 
      [LastName], 
      [Country]
HAVING COUNT(*) > 1;

-- COUNT - to see how many times the row occurs

