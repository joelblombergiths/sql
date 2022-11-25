/*
a) Kopiera hela tabellen Users till en ny tabell. Skapa sedan en vy 
med kolumnerna ID, Firstname, Lastname, Phone som listar alla 
kvinnliga användare från den nya tabellen. Om man lägger till nya 
användare i vyn så ska det bara gå om personnummret indikerar 
att det är en kvinna.
*/
-- create view FemaleUsers AS
-- SELECT 
--     u.Id,
--     u.FirstName,
--     u.LastName,
--     u.Phone
-- FROM 
--     Users2 u
-- WHERE
--     SUBSTRING(u.id, 10, 1) % 2 = 0
-- WITH CHECK OPTION

-- INSERT INTO FemaleUsers
-- Values('500603-4218', 'nisse', 'hult', '1234567')

-- SELECT
--     *
-- FROM
--     FemaleUsers

/*
Antag att vi har en fabrik med 4 produktionslinjer där vi då och då 
kollar av hur många enheter som producerats sedan senaste 
avcheckning och lagrar en timestamp, vilken linje och hur många 
produkter. Skapa en ny tabell med testdata för att simulera att vi 
samlat in sådan data under 10 års tid. Tabellen ska innehålla 
1 miljon rader med kolumnerna ”timestamp” som är random 
datum och tid i spannet 10 år tillbaks och nu; ”line” som är ett 
random värde ’A’, ’B’, ’C’ eller ’D’; samt ”count” som är ett 
random värde 1-5.
*/

SELECT 
    CASE CAST(RAND() * 10 AS INT) % 4
        WHEN 0 THEN 'A'
        WHEN 1 THEN 'B'
        WHEN 2 THEN 'C'
        WHEN 3 THEN 'D'
    END AS Line


declare @r int = CAST(RAND() * 10 AS INT) % 4

SELECT
    @r,
    CASE @r
        WHEN 0 THEN 'A'
        WHEN 1 THEN 'B'
        WHEN 2 THEN 'C'
        WHEN 3 THEN 'D'
    END AS Line

