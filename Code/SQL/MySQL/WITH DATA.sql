-- STRUCTURE
WITH
  cte1 AS (SELECT a, b FROM table1),
  cte2 AS (SELECT c, d FROM table2)
SELECT b, d FROM cte1 JOIN cte2
WHERE cte1.a = cte2.c;

-- EXAMPLE

/* count total submissions of challenges of each user */
WITH data
AS 
    (
        SELECT h.hacker_id AS id, h.name AS name, COUNT(c.challenge_id) AS counter
        FROM Hackers h JOIN Challenges c ON c.hacker_id = h.hacker_id
        GROUP BY c.hacker_id, h.name
    )
/* select records from above */
SELECT id, name, counter
FROM data
WHERE 
    counter = (SELECT MAX(counter) FROM data) /*select user that has max count submission*/
OR 
    counter in (SELECT counter FROM data
               GROUP BY counter
               HAVING COUNT(counter) = 1
               ) /*filter out the submission count which is unique*/
ORDER BY counter DESC, id

-- ALTERNATIVE CODE

/*1st SELECTING THE VALUES requested to be printed*/
SELECT h.hacker_id, h.name, COUNT(c.challenge_id) AS challenge_counter
FROM hackers h
JOIN challenges c
	ON h.hacker_id = c.hacker_id
GROUP BY h.hacker_id, h.name

/*2nd applying the values found before*/

HAVING 
challenge_counter IN (
	SELECT help_table.counter
/* 'FROM data' would replace () */
	FROM(
		SELECT hacker_id, COUNT(challenge_id) AS counter 
		FROM challenges
		GROUP BY hacker_id
	) AS help_table
	GROUP BY help_table.counter 
	HAVING COUNT(help_table.counter) = 1
)
OR
challenge_counter = (
	SELECT MAX(help_table.counter)
/* 'FROM data' would replace () */
	FROM(                                                   
		SELECT hacker_id, COUNT(challenge_id) AS counter
		FROM challenges
		GROUP BY hacker_id
		ORDER BY counter DESC
	) AS help_table)
/* Finally we order as requested (by counter and hacker_id)*/
ORDER BY challenge_counter DESC, h.hacker_id ASC;


/* Write a query to print the hacker_id, name, and the total number of challenges created by each student. 
Sort your results by the total number of challenges in descending order. 
If more than one student created the same number of challenges, then sort the result by hacker_id. 
If more than one student created the same number of challenges 
and the count is less than the maximum number of challenges created, 
then exclude those students from the result. 
counter = 6, 6, 4, 4, 3, 1 -> we keep both 6 because they equal to max, but exclude one 4 (< max)
*/

-- ANOTHER EXAMPLE where we JOIN help_table

SELECT h.hacker_id, h.name, SUM(t.max_score) as total_score
FROM Hackers h
JOIN (
    SELECT hacker_id, challenge_id, MAX(score) as max_score
    FROM Submissions
    GROUP BY hacker_id, challenge_id
    ) t
ON h.hacker_id = t.hacker_id
GROUP BY h.hacker_id, h.name
HAVING total_score <> 0
ORDER BY total_score DESC, h.hacker_id ASC