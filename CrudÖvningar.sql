USE Everyloop

--A
SELECT Title,
    'S' + format(Season,'00') + 
    'E' + FORMAT(EpisodeInSeason, '00')
FROM GameOfThrones

--B
UPDATE users2
SET UserName = LOWER(LEFT(FirstName, 2) + LEFT(LastName, 2))

--C
UPDATE Airports2
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
        WHEN LEFT(Name, 2) = Symbol THEN 'Yes'
        ELSE 'No'
    END AS BeginingWithSymbol
    INTO ElementsNames
FROM Elements

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

SELECT Integer,
 CAST([Integer] AS float) / 100 AS Float,
 String,
 DATEADD(MINUTE, [Integer], GETDATE() ) AS DateTime,
 [Integer] % 2 AS Bool
FROM Types2
