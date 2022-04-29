-- This is a self join. The thing is, we usually join 2 different tables. 
-- In some rare cases, we join one table back to itself. That is what we are doing here. 
-- Doing a self join allows us to query on a value within a COLUMN with other rows being used as FILTER.
-- In this case, we are using code and power as filters/ identifiers and querying the coins_needed row

SELECT w.id, p.age, w.coins_needed, w.power
FROM Wands as w JOIN Wands_Property as p ON w.code = p.code
WHERE p.is_evil = 0 AND w.coins_needed = (
    SELECT MIN(coins_needed)
    FROM Wands as w1 JOIN Wands_Property as p1 ON w1.code = p1.code
    WHERE w1.power = w.power AND p1.age = p.age
    )
ORDER BY w.power DESC, p.age DESC

-- The following SQL statement matches customers that are from the same city:

SELECT A.CustomerName AS CustomerName1, B.CustomerName AS CustomerName2, A.City
FROM Customers A, Customers B
WHERE A.CustomerID <> B.CustomerID
AND A.City = B.City
ORDER BY A.City;