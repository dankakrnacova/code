SELECT ROUND(AVG(middle_values), 4) FROM (
  SELECT t1.LAT_N AS 'middle_values' FROM
    (
      SELECT @row:=@row+1 as `row`, x.LAT_N
      FROM STATION AS x, (SELECT @row:=0) AS r
      WHERE 1
      -- put some where clause here
      ORDER BY x.LAT_N
    ) AS t1,
    (
      SELECT COUNT(*) as 'count'
      FROM STATION x
      WHERE 1
      -- put same where clause here
    ) AS t2
    -- the following condition will return 1 record for odd number sets, or 2 records for even number sets.
    WHERE t1.row >= t2.count/2 and t1.row <= ((t2.count/2) +1)) AS t3;

    1 2 3 4 5 6
    >= 3 and <= 4
    AVG = 3,5
    
    1 2 3 4 5
    >=