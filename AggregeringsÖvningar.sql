
--A
SELECT
    Period,
    MIN(Number) AS LowestAtomNumber,
    MAX(Number) AS HigestAtomNumber,
    FORMAT(AVG(CAST(StableIsotopes AS float)),'0.00') AS AverageIsostopes,
    STRING_AGG(Symbol,',') AS Symbols   
FROM
    Elements
GROUP BY
    Period

--B
SELECT
    City,
    Country,
    Region,
    Count(*) AS Customers
FROM
    company.customers
GROUP BY 
    City,
    Country,
    Region
HAVING 
    COUNT(*) >= 2

--C
DECLARE @text NVARCHAR(max) = ''

SELECT 
    @text += CHAR(13) + FORMATMESSAGE
    (
        'Säsong %i sändes från %s till %s. Totalt sändes %i avsnitt, som i genomsnitt sågs av %s miljoner människor i USA.',
        Season,
        FORMAT(MIN([Original air date]), 'MMMM','sv-SE'),
        FORMAT(MAX([Original air date]), 'MMMM yyyy','sv-SE'),
        COUNT(*),
        FORMAT(AVG([U.S. viewers(millions)]),'0.0')
    )
FROM 
    GameOfThrones
GROUP BY
    Season

PRINT(@text)

--D
SELECT 
    CONCAT(FirstName, ' ', LastName),
    DATEDIFF(YEAR, SUBSTRING(ID,1,6), GETDATE()),
    CASE SUBSTRING(ID,10,1) % 2
        WHEN 0 THEN 'Female'
        ELSE 'Male'
    END
FROM 
    Users
ORDER BY
    FirstName,
    LastName
SELECT * FROM Users
--E

SELECT 
    Region,
    COUNT(Country) AS TotalCountries,
    SUM(CAST(Population AS bigint)) AS TotalPop,
    SUM([Area (sq# mi#)]) AS TotalArea,
    FORMAT(SUM(CAST(Population AS bigint)) / CAST(SUM([Area (sq# mi#)]) AS float),'0.00') AS RegionAvgDensity
FROM
    Countries
GROUP BY
    Region

SELECT 
    Region,
    FORMAT(AVG(CAST(REPLACE([Pop# Density (per sq# mi#)],',','.') AS Float)),'0.00') AS Avg,
    FORMAT(SUM(CAST(Population AS bigint)) / CAST(SUM([Area (sq# mi#)]) AS float),'0.00') AS RegionAvgDensity
FROM
    Countries
GROUP BY 
    Region

SELECT top 3 Country,Population,[Area (sq# mi#)], [Pop# Density (per sq# mi#)]
FROM Countries
WHERE Region = 'ASIA (EX. NEAR EAST)'

    SELECT FORMAT(SUM(CAST(Population AS bigint)) / CAST(SUM([Area (sq# mi#)]) AS float),'0.00') AS RegionAvgDensity
    FROM Countries
    WHERE Region = 'ASIA (EX. NEAR EAST)'

    SELECT SUM(CAST(REPLACE([Pop# Density (per sq# mi#)],',','.') AS Float))
    FROM Countries
    WHERE Region = 'ASIA (EX. NEAR EAST)'


 --F

 /*
 Från tabellen ”Airports”, gruppera per land och ta ut kolumner som visar: 
land, antal flygplatser (IATA-koder), antal som saknar ICAO-kod, samt hur 
många procent av flygplatserna i varje land som saknar ICAO-kod
 */

SELECT 
    (select [value]
FROM
    Airports
CROSS APPLY
    string_split([Location served], ',')
    )
