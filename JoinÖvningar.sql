IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Länder]') AND type in (N'U'))
DROP TABLE [dbo].[Länder]

CREATE TABLE Länder
(
    Id INT,
    Namn NVARCHAR(100)
)

INSERT INTO Länder
VALUES (1, 'Sverige')

INSERT INTO Länder
VALUES (2, 'Norge')

INSERT INTO Länder
VALUES (3, 'Danmark')

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Städer]') AND type in (N'U'))
DROP TABLE [dbo].[Städer]

CREATE TABLE Städer
(
    ID INT,
    Namn NVARCHAR(100),
    LandID INT
)

INSERT INTO Städer
VALUES (1, 'Oslo', 2)

INSERT INTO Städer
VALUES (2, 'Köpenhamn', 3)

INSERT INTO Städer
VALUES (3, 'Helsingfors', 4)

INSERT INTO Städer
VALUES (4, 'Bergen', 2)


SELECT
    s.Namn,
    l.Namn
FROM 
    Städer s
FULL JOIN 
    Länder l ON s.LandID = l.Id

--####################-

DROP TABLE Kurser

CREATE TABLE Kurser
(
    ID INT,
    Namn NVARCHAR(100)
)

INSERT INTO Kurser
VALUES(1,'Programmering C#')
INSERT INTO Kurser
VALUES(2,'Databaser')
INSERT INTO Kurser
VALUES(3,'Webprogrammering')
INSERT INTO Kurser
VALUES(4,'Molntjänster')

DROP TABLE Studenter

CREATE TABLE Studenter
(
    ID INT,
    Namn NVARCHAR(100)
)

INSERT INTO Studenter
VALUES(1,'Joel')
INSERT INTO Studenter
VALUES(2,'Markus')
INSERT INTO Studenter
VALUES(3,'Pontus')
INSERT INTO Studenter
VALUES(4,'Rickard')
INSERT INTO Studenter
VALUES(5,'David')
INSERT INTO Studenter
VALUES(6,'Mikael')

DROP TABLE StudenterKurser

CREATE TABLE StudenterKurser
(
    sudentId INT,
    kursId INT
)

INSERT INTO StudenterKurser
VALUES(1,1)
INSERT INTO StudenterKurser
VALUES(2,1)
INSERT INTO StudenterKurser
VALUES(3,1)
INSERT INTO StudenterKurser
VALUES(4,1)
INSERT INTO StudenterKurser
VALUES(1,2)
INSERT INTO StudenterKurser
VALUES(2,2)
INSERT INTO StudenterKurser
VALUES(4,3)
INSERT INTO StudenterKurser
VALUES(5,3)
INSERT INTO StudenterKurser
VALUES(6,3)

-- Kurser
SELECT 
    k.Namn AS Kurs,
    COUNT(s.Namn) AS AntalStudenter,
    STRING_AGG(s.Namn, ', ') AS Studenter
FROM 
    Kurser k 
    INNER JOIN StudenterKurser sk ON k.ID = sk.kursId
    INNER JOIN Studenter s ON s.ID = sk.sudentId
GROUP BY 
    k.Namn

-- Studenter
SELECT 
    s.Namn AS Student,
    COUNT(k.Namn) AS AntalKurser,
    STRING_AGG(k.Namn, ', ') AS Kurser
FROM 
    Kurser k 
    INNER JOIN StudenterKurser sk ON k.ID = sk.kursId
    INNER JOIN Studenter s ON s.ID = sk.sudentId
GROUP BY 
    s.Namn


SELECT 
    s.Namn AS Student,
    COUNT(k.Namn) AS AntalKurser,
    STRING_AGG(k.Namn, ', ') AS Kurser
FROM 
    StudenterKurser sk 
    INNER JOIN Kurser k ON k.ID = sk.kursId 
    INNER JOIN Studenter s ON s.ID = sk.sudentId
GROUP BY 
    s.Namn



--################################


--A
/*
Företagets totala produktkatalog består av 77 unika produkter.
Om vi kollar bland våra ordrar,
hur stor andel av dessa produkter har vi någon gång leverarat till London
*/
SELECT 
    FORMAT(CAST(COUNT(distinct od.ProductId) AS float) / (SELECT COUNT(Distinct ProductName) FROM company.Products), 'P')
FROM
    company.orders o
    INNER JOIN company.order_details od ON od.OrderId = o.Id
WHERE
    o.ShipCity = 'London'  


--B

/*
Till vilken stad har vi levererat flest unika produkter?
*/

SELECT
    TOP 1 o.ShipCity, 
    COUNT(DISTINCT od.ProductId)
FROM
    company.orders o
    INNER JOIN company.order_details od ON od.OrderId = o.Id
GROUP BY
    o.ShipCity
ORDER BY
    2 DESC


--C
/*
Av de produkter som inte längre finns I vårat sortiment,
hur mycket har vi sålt för totalt till Tyskland?
*/

SELECT
   SUM(od.UnitPrice * od.Quantity) AS TotalForGermany
FROM
    company.orders o
    INNER JOIN company.order_details od ON od.OrderId = o.Id
    INNER JOIN company.products p ON p.Id = od.ProductId
WHERE
    p.Discontinued = 1 AND
    o.ShipCountry = 'Germany' 

--D
/*
För vilken produktkategori har vi högst lagervärde?
*/

SELECT
    TOP 1 c.CategoryName,
     SUM(p.UnitsInStock)
FROM
    company.products p
    INNER JOIN company.categories c ON c.Id = p.CategoryId
GROUP BY
    c.CategoryName
ORDER BY
    2 DESC


--E
/*
Från vilken leverantör har vi sålt flest produkter totalt under sommaren 2013?
*/
SELECT
    TOP 1 s.CompanyName,
    SUM(od.Quantity)

FROM
    company.orders o
    INNER JOIN company.order_details od ON od.OrderId = o.Id
    INNER JOIN company.products p ON p.Id = od.ProductId
    INNER JOIN company.suppliers s ON s.Id = p.SupplierId
WHERE
    o.OrderDate BETWEEN '2013-06-01' AND '2013-08-31' 
GROUP BY
    s.CompanyName
ORDER BY    
    2 DESC
    
--###

DECLARE @playlist VARCHAR(max) = 'Heavy Metal Classic'

SELECT
    g.Name AS Genre,
    a.Name AS Artist,
    ab.Title AS Album,
    t.Name AS Track,
    CONCAT(
        FORMAT(t.Milliseconds / (1000 * 60) % 60,'00'),
        ':',
        FORMAT((t.Milliseconds / 1000) % 60,'00')
    ) AS Length,
    FORMAT(CAST(t.Bytes AS float) / 1024 / 1024,'0.00') AS Size,
    t.Composer
FROM 
    music.tracks t
    INNER JOIN music.playlist_track pt ON pt.TrackId = t.TrackId
    INNER JOIN music.playlists p ON p.PlaylistId = pt.PlaylistId
    INNER JOIN music.genres g ON g.GenreId = t.GenreId
    INNER JOIN music.albums ab ON ab.AlbumId = t.AlbumId
    INNER JOIN music.artists a ON a.ArtistId = ab.ArtistId 
WHERE
    p.Name = @playlist

--1

DECLARE @TopArtist NVARCHAR(120)

SET @TopArtist = (
    SELECT
        TOP 1 a.Name
    FROM 
        music.tracks t
        INNER JOIN music.albums ab ON ab.AlbumId = t.AlbumId
        INNER JOIN music.artists a ON a.ArtistId = ab.ArtistId
    WHERE
        t.MediaTypeId IN (1,2,4,5)
    GROUP BY
        a.Name
    ORDER BY
        SUM(t.Milliseconds) DESC
)

SELECT @TopArtist

--2

SELECT
    CONCAT(
        FORMAT(AVG(t.Milliseconds) / (1000 * 60) % 60,'00'),
        ':',
        FORMAT((AVG(t.Milliseconds) / 1000) % 60,'00')
    ) AS Length
FROM
    music.artists a
    INNER JOIN music.albums ab ON ab.ArtistId = a.ArtistId
    INNER JOIN music.tracks t ON t.AlbumId = ab.AlbumId
WHERE
    a.Name = @TopArtist

--3

SELECT
    FORMAT(CAST(SUM(CAST(t.Bytes AS bigint)) AS float) / 1024 / 1024 / 1024,'0.00 GB') AS TotalSize
FROM
    music.tracks t
WHERE
    t.MediaTypeId = 3


--4

SELECT
    TOP 1 p.Name,
    COUNT(DISTINCT a.Name) AS NumArtists
FROM
    music.playlists p
    INNER JOIN music.playlist_track pt ON pt.PlaylistId = p.PlaylistId
    INNER JOIN music.tracks t ON t.TrackId = pt.TrackId
    INNER JOIN music.albums ab ON ab.AlbumId = t.AlbumId
    INNER JOIN music.artists a ON a.ArtistId = ab.ArtistId
GROUP BY
    p.Name
ORDER BY 
    2 DESC


--5

SELECT
    AVG(ap.artistsPerPlaylist)
FROM
(
    SELECT
        COUNT(DISTINCT a.Name) AS artistsPerPlaylist
    FROM
        music.playlists p
        INNER JOIN music.playlist_track pt ON pt.PlaylistId = p.PlaylistId
        INNER JOIN music.tracks t ON t.TrackId = pt.TrackId
        INNER JOIN music.albums ab ON ab.AlbumId = t.AlbumId
        INNER JOIN music.artists a ON a.ArtistId = ab.ArtistId
    GROUP BY
        p.Name
) AS ap
