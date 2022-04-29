CASE case_value
    WHEN when_value THEN statement_list
    [WHEN when_value THEN statement_list] ...
    [ELSE statement_list]
END CASE

/* For the first syntax, 'case_value' is an expression. 
This value is compared to the when_value' expression in each WHEN clause until one of them is equal. */

/* OR */

CASE
    WHEN search_condition THEN statement_list
    [WHEN search_condition THEN statement_list] ...
    [ELSE statement_list]
END CASE

/* EXAMPLE */

SELECT CASE
    WHEN A + B > C THEN
    CASE
        WHEN A = B AND B = C THEN "Equilateral"
        WHEN A = B OR A = C OR B = C THEN "Isosceles"
        ELSE "Scalene"
        END
    ELSE "Not A Triangle"
    END
FROM TRIANGLES