--CREATE DATABASE StoryKeeper

GO

-- DROP TABLE Publishers
-- DROP TABLE Customers
-- DROP TABLE Orders
-- DROP TABLE Reviews
-- DROP TABLE Inventory
-- DROP TABLE OrderRows
-- -- DROP TABLE BookPublishers
-- DROP TABLE BookAuthors
-- DROP TABLE Stores
-- DROP TABLE Authors
-- DROP TABLE Books
-- DROP FUNCTION dbo.ValidateISBNv2

CREATE TABLE Publishers
(
    Id INT IDENTITY(1, 1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Region NVARCHAR(100) NULL
)

CREATE TABLE Books
(
	ISBN NVARCHAR(20) PRIMARY KEY,
	Title NVARCHAR(200) NOT NULL,
    Series NVARCHAR(200) NULL,
	Language NVARCHAR(50) NULL,
    Price FLOAT NULL,
    PublishedDate DATETIME2 NULL,
    PublisherId INT NOT NULL,
    CONSTRAINT CHK_Valid_ISBN 
        CHECK(dbo.ValidateISBNv2(ISBN) = 1),
    CONSTRAINT FK_B_Stores
        FOREIGN KEY (PublisherId)
        REFERENCES Publishers(Id)
)

CREATE TABLE Authors
(
	Id INT IDENTITY(1, 1) PRIMARY KEY,
	FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    DOB DATETIME2 NULL
)

CREATE TABLE BookAuthors
(
	ISBN NVARCHAR(20) NOT NULL,
	AuthorId INT NOT NULL,
    CONSTRAINT PK_BookAuthors 
        PRIMARY KEY(ISBN, AuthorId),
    CONSTRAINT FK_BA_Books
        FOREIGN KEY (ISBN)
        REFERENCES Books(ISBN),
    CONSTRAINT FK_BA_Authors
        FOREIGN KEY (AuthorId)
        REFERENCES Authors(Id)
)


CREATE TABLE Stores
(
	Id INT IDENTITY(1, 1) PRIMARY KEY,
	Name NVARCHAR(100) NOT NULL,
	Street NVARCHAR(200) NULL,
	PostalCode NVARCHAR(20) NULL,
	City NVARCHAR(100) NULL,
    Country NVARCHAR(100) NULL
)

CREATE TABLE Inventory
(
    ISBN NVARCHAR(20) NOT NULL,
    StoreId INT NOT NULL,
    Quantity INT NOT NULL DEFAULT(1),
    CONSTRAINT PK_Inventory
        PRIMARY KEY (ISBN, StoreId),
     CONSTRAINT FK_I_Books
        FOREIGN KEY (ISBN)
        REFERENCES Books(ISBN),
    CONSTRAINT FK_I_Stores
        FOREIGN KEY (StoreId)
        REFERENCES Stores(Id),
    CONSTRAINT CHK_I_Positive_Quantity
        CHECK (Quantity > 0)
)

CREATE TABLE Customers
(
    Id INT IDENTITY(1, 1) PRIMARY KEY,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    Street NVARCHAR(200) NOT NULL,
	PostalCode NVARCHAR(20) NOT NULL,
	City NVARCHAR(100) NOT NULL,
    Country NVARCHAR(100) NOT NULL
)

CREATE TABLE Orders
(
    Id INT IDENTITY(1, 1) PRIMARY KEY,
    StoreId INT NOT NULL,
    CustomerId INT NOT NULL,
    OrderDate DATETIME2 NOT NULL DEFAULT(GETDATE()),
    UseInvoiceAddress BIT NOT NULL DEFAULT(1),
    DeliveryStreet NVARCHAR(200) NULL,
	DeliveryPostalCode NVARCHAR(20) NULL,
	DeliveryCity NVARCHAR(100) NULL,
    DeliveryCountry NVARCHAR(100) NULL,
    DeliveredDate DATETIME2 NULL,
    CONSTRAINT FK_O_Store
        FOREIGN KEY (StoreId)
        REFERENCES Stores(Id),
    CONSTRAINT FK_O_Customer
        FOREIGN KEY (CustomerId)
        REFERENCES Customers(Id)
)

CREATE TABLE OrderRows
(
    OrderId INT NOT NULL,
    ISBN NVARCHAR(20) NOT NULL,
    Price FLOAT NOT NULL,
    Quantity INT NOT NULL DEFAULT(1),
    CONSTRAINT PK_OrderRows
        PRIMARY KEY (OrderId, ISBN),
    CONSTRAINT FK_OR_Order
        FOREIGN KEY (OrderId)
        REFERENCES Orders(Id),
    CONSTRAINT FK_OR_Book
        FOREIGN KEY (ISBN)
        REFERENCES Books(ISBN)
)

CREATE TABLE Reviews
(
    ISBN NVARCHAR(20) NOT NULL,
    CustomerId INT NOT NULL,
    Rating INT NOT NULL,
    Review NVARCHAR(MAX) NULL,
    CONSTRAINT PK_Reviews
        PRIMARY KEY (CustomerId, ISBN),
    CONSTRAINT CHK_Valid_Rating
        CHECK (Rating IN (1,2,3,4,5)),
    CONSTRAINT FK_R_Customer
        FOREIGN KEY (CustomerId)
        REFERENCES Customers(Id),
    CONSTRAINT FK_R_Book
        FOREIGN KEY (ISBN)
        REFERENCES Books(ISBN)
)

-- GO

-- CREATE FUNCTION dbo.ValidateISBN (@ISBN NVARCHAR(20))
--     RETURNS SMALLINT
-- AS 
-- BEGIN
--     SET @ISBN = REPLACE(REPLACE(@ISBN, '-', ''), ' ', '')
--     IF LEN(@ISBN) <> 13
--         RETURN -1

--     DECLARE @ISBN_PART VARCHAR(12) = SUBSTRING(@ISBN, 1, 12)

--     DECLARE @Index INT = 1
--     DECLARE @Multiplier INT = 1
--     DECLARE @Sum INT = 0

--     WHILE @Index <= 12
--     BEGIN
--         SET @Sum += SUBSTRING(@ISBN_PART, @Index, 1) * @Multiplier
        
--         SET @Index += 1

--         SET @Multiplier = 
--             CASE WHEN @Index % 2 = 0
--                 THEN 3
--                 ELSE 1
--             END
--     END

--     DECLARE @checksum INT =
--         CASE WHEN @Sum % 10 = 0
--             THEN 0
--             ELSE 10 - @Sum % 10
--         END

--     IF (SUBSTRING(@ISBN, 13, 1) = @checksum)
--         RETURN 1

--     RETURN 0
-- END

GO
CREATE FUNCTION dbo.ValidateISBNv2 (@ISBN NVARCHAR(20))
    RETURNS BIT
AS 
BEGIN
    SET @ISBN = REPLACE(REPLACE(@ISBN, '-', ''), ' ', '')
    IF LEN(@ISBN) <> 13
        RETURN 0

    DECLARE @checksum INT
	SELECT @checksum = 
		CASE WHEN SUM(checksum.Digit * checksum.Multiplier) % 10 = 0
			THEN 0
			ELSE 10 - SUM(checksum.Digit * checksum.Multiplier) % 10
		END
	FROM
	(
		SELECT TOP 12 
			SUBSTRING(SUBSTRING(@ISBN, 1, 12), t.n, 1) AS Digit,
			CASE WHEN t.n % 2 = 0
				THEN 3
				ELSE 1
			END AS Multiplier
		FROM TallyTable t
	) AS checksum

    IF (SUBSTRING(@ISBN, 13, 1) = @checksum)
        RETURN 1

    RETURN 0
END

GO

CREATE VIEW TitlesPerAuthor AS
SELECT
    CONCAT(a.FirstName, ' ', a.LastName) AS Name,
    DATEDIFF(YEAR,a.DOB, GETDATE()) AS Age,
    COUNT(distinct b.ISBN) AS Titles,    
    FORMAT(SUM(i.Quantity * b.Price),'C','se') AS 'Inventory Value'
FROM
    Authors a
    INNER JOIN BookAuthors ba ON ba.AuthorId = a.Id
    INNER JOIN Books b ON b.ISBN = ba.ISBN
    INNER JOIN Inventory i ON i.ISBN = b.ISBN
GROUP BY
    a.FirstName,
    a.LastName,
    a.DOB

GO



ALTER PROCEDURE MoveBook
    @FromStore INT,
    @ToStore INT,
    @ISBN NVARCHAR(20),
    @Quantity INT = 1
AS
BEGIN
    BEGIN TRY
        IF(@FromStore = @ToStore)        
            THROW 50000, 'Destination Same As Source', 0

        IF NOT EXISTS (SELECT * FROM Stores WHERE Id = @FromStore)
            THROW 50000, 'Source Store Not Found', 0

        IF NOT EXISTS (SELECT * FROM Stores WHERE Id = @ToStore)        
            THROW 50000, 'Destination Store Not Found', 0

        IF NOT EXISTS (SELECT * FROM Books WHERE ISBN = @ISBN)
            THROW 50000, 'Book Not Found', 0

        IF NOT EXISTS
        (
            SELECT * 
            FROM Inventory i
            WHERE
                i.ISBN = @ISBN AND
                i.StoreId = @FromStore AND
                i.Quantity >= @Quantity
        )
            THROW 50000, 'Quantity Too Big', 0
        
        BEGIN TRAN

        DECLARE @beforeSum int

        SELECT
            @beforeSum = SUM(i.Quantity)
        FROM
            Inventory i            
        WHERE
            i.ISBN = @ISBN AND
            i.StoreId IN (@FromStore, @ToStore)

        DECLARE @sourceQuantity INT

        SELECT
            @sourceQuantity = Quantity
        FROM
            Inventory i
        WHERE
            ISBN = @ISBN AND
            StoreId = @FromStore

        IF(@sourceQuantity > @Quantity)
            BEGIN
                UPDATE
                    Inventory
                SET 
                    Quantity = Quantity - @Quantity
                WHERE
                    ISBN = @ISBN AND
                    StoreId = @FromStore
            END
        ELSE
            BEGIN
                DELETE FROM Inventory
                WHERE
                    ISBN = @ISBN AND
                    StoreId = @FromStore
            END

        IF EXISTS (SELECT * FROM Inventory WHERE StoreId = @ToStore AND ISBN = @ISBN)    
            BEGIN
                UPDATE
                    Inventory
                SET 
                    Quantity = Quantity + @Quantity
                WHERE
                    ISBN = @ISBN AND
                    StoreId = @ToStore
            END
        ELSE
            BEGIN    
                INSERT INTO Inventory
                VALUES
                (
                    @ISBN,
                    @ToStore,
                    @Quantity
                )
            END

        DECLARE @afterSum int

        SELECT
            @afterSum = SUM(i.Quantity)
        FROM
            Inventory i            
        WHERE
            i.ISBN = @ISBN AND
            i.StoreId IN (@FromStore, @ToStore)

        IF(@beforeSum = @afterSum)        
            COMMIT
        ELSE
            THROW 50000, 'Missmatch In Transfer', 0

    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS ERROR

        IF(@@trancount > 0)
            ROLLBACK
    END CATCH
END

GO


CREATE VIEW ShowToplist AS
/*
This view shows the toprated and most frequently bought books
that the stores uses to determine what books to display most prominently
and to make sure is in stock in all stores.
*/

SELECT TOP 5
    b.Title,
    AVG(CAST(r.Rating AS float)) AS AverageRating,
    SUM(row.Quantity) AS TotalBooksSold
FROM
    Books b
    INNER JOIN OrderRows row ON row.ISBN = b.ISBN
    INNER JOIN Reviews r ON r.ISBN = b.ISBN
GROUP BY
    b.Title
ORDER BY
    AverageRating DESC,
    TotalBooksSold DESC

GO
-- UPDATE Reviews
-- SET Rating = 5
-- WHERE ISBN = '9780261103283'

-- INSERT INTO Reviews
-- SELECT
--     ISBN,
--     t.n,
--     ABS(CHECKSUM(NewId())) % 5 + 1,
--     'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc a imperdiet leo. Proin eu justo dui. Praesent rutrum auctor sapien, nec interdum elit varius eget. Sed dui purus, commodo eget nulla ultricies, hendrerit sagittis dui. Integer bibendum dui justo, quis blandit arcu maximus non. Aenean ut blandit ante, in sagittis orci. Aliquam nec sapien dignissim, iaculis magna quis, posuere erat. Mauris porta viverra neque, ac condimentum purus. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. In et massa ac magna finibus pretium. Donec rutrum mauris vitae metus sollicitudin, nec faucibus mi lacinia. Morbi at pellentesque nibh.'
-- FROM
--     Books
-- CROSS APPLY TallyTable t
-- WHERE t.n <= 20

-- INSERT INTO Stores
-- VALUES
-- (
--     'The Fantastic Story Keeper',
--     '123 W 11th St',
--     'NY 10014',
--     'New York',
--     'United States'
-- ),
-- (
--     'The Wondrous Story Keeper',
--     '123 Shaftesbury Ave',
--     'WC2H 8HB',
--     'London',
--     'United Kingdom'
-- ),
-- (
--     'The Inspiring Story Keeper',
--     'Teatergatan 123',
--     '411 35',
--     'Gothenburg',
--     'Sweden'
-- ),
-- (
--     'The Digital Story Keeper',
--     'www.storykeeper.com',
--     '',
--     '',
--     'Internet'
-- )

-- INSERT INTO Customers
-- VALUES
--   ('Nevada','Herrera','nevadaherrera140@outlook.couk','3528 Sit Road','351117','Massa Martana','South Korea'),
--   ('Barry','Buck','barrybuck@aol.com','758-4650 Dolor. St.','268726','Copenhagen','Germany'),
--   ('Roth','Alford','rothalford9956@google.edu','889-5928 Amet Rd.','2116 NT','Meerhout','China'),
--   ('Russell','Stewart','russellstewart@icloud.org','626-6890 Diam Rd.','5446','Conselice','Belgium'),
--   ('Berk','Irwin','berkirwin7083@icloud.couk','291-7630 Congue. Rd.','60007','Bahawalnagar','Spain'),
--   ('Iona','Cortez','ionacortez@yahoo.couk','P.O. Box 337, 2964 Ornare, Street','746573','Albury','Italy'),
--   ('Dominique','Winters','dominiquewinters@aol.net','910-6235 Volutpat. St.','2594','Grayvoron','France'),
--   ('Barbara','Branch','barbarabranch@icloud.com','Ap #923-8808 In, Road','65-56','Gore','Singapore'),
--   ('Alden','Kane','aldenkane@hotmail.net','331-3605 Sed Rd.','219590','Blois','Ireland'),
--   ('Levi','Petty','levipetty@hotmail.net','Ap #573-8854 Hendrerit St.','7688','Plauen','Norway');

-- INSERT INTO Customers
-- VALUES
--   ('Jackson','Herman','jacksonherman5489@icloud.ca','754-848 At, Av.','10528','Kupang','Sweden'),
--   ('Charity','Guzman','charityguzman7332@protonmail.org','Ap #961-3622 Ante Road','50-066','San Andrés','Sweden'),
--   ('Dylan','Barnett','dylanbarnett3661@hotmail.couk','Ap #852-8578 Tincidunt St.','236763','Campinas','United Kingdom'),
--   ('Mariko','Oneal','marikooneal@hotmail.couk','Ap #460-6274 Fusce Av.','74743','Bogotá','United States'),
--   ('Dorian','Hicks','dorianhicks9534@outlook.ca','Ap #553-771 Aliquet St.','70729','Makurdi','Sweden'),
--   ('Leila','Odom','leilaodom9580@hotmail.ca','P.O. Box 943, 2340 Auctor, Av.','21731','Baubau','United States'),
--   ('Cheryl','Benson','cherylbenson8062@icloud.net','P.O. Box 225, 9685 Elementum Street','6371-0615','Bryne','United States'),
--   ('Ria','Mendez','riamendez7167@outlook.couk','P.O. Box 172, 4467 Ornare, St.','469280','Almere','United States'),
--   ('Haley','Wynn','haleywynn4868@aol.couk','Ap #397-6029 Ornare St.','533553','Neelum Valley','Sweden'),
--   ('Laurel','Bonner','laurelbonner@icloud.com','P.O. Box 695, 8676 Metus Rd.','72731','Bạc Liêu','United Kingdom');



-- SELECT IIF(dbo.ValidateISBNv2('978-0-306-40615-7') = 1, 1, 0)
-- SELECT dbo.ValidateISBNv2('978-3-16-148410-0')

-- select FORMAT(100,'C','se')

