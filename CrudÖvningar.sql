USE Everyloop

--A
SELECT 
    Title,
    'S' + FORMAT(Season,'00') + 
    'E' + FORMAT(EpisodeInSeason, '00')
    AS Episode
FROM 
    GameOfThrones

--B
UPDATE 
    users2
SET 
    UserName = LOWER(LEFT(FirstName, 2) + LEFT(LastName, 2))

--C
UPDATE 
    Airports2
SET
    Time = ISNULL([Time], '-'),
    DST = ISNULL(DST, '-')

--D
DELETE Elements2
WHERE 
    Name IN ('Erbium', 'Helium', 'Nitrogen', 'Platinum', 'Selenium') or
    Name LIKE '[dkmou]%'

--E
SELECT
    Symbol,
    Name,
    CASE 
        WHEN LEFT(Name, LEN(Symbol)) = Symbol THEN 'Yes'
        ELSE 'No'
    END AS BeginingWithSymbol
    INTO ElementsNames
FROM Elements

SELECT *
FROM ElementsNames
ORDER BY Symbol

--F
SELECT Name, Red, Green, Blue
INTO Colors2
FROM Colors

SELECT 
    *,
    CONCAT(
        '#',
        FORMAT(Red, 'X2'),
        FORMAT(Green, 'X2'),
        FORMAT(Blue, 'X2')
    ) AS Code
FROM Colors2

--G

SELECT *
FROM Types

SELECT
    Integer,
    [Integer] / 100.0 AS Float,
    String,
    DATEADD(DAY, [Integer], DATEADD(MINUTE, [Integer], '2018-12-31 09:00:00' )) AS DateTime,
    [Integer] % 2 AS Bool
FROM 
    Types2

select GETDATE()