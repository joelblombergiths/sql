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


-- CREATE TABLE BookPublishers
-- (
--     ISBN NVARCHAR(20) NOT NULL,
--     PublisherId INT NOT NULL,
--     CONSTRAINT PK_BookPublishers
--         PRIMARY KEY(ISBN, PublisherId),
--     CONSTRAINT FK_BP_Books
--         FOREIGN KEY (ISBN)
--         REFERENCES Books(ISBN),
--     CONSTRAINT FK_BP_Publishers
--         FOREIGN KEY (PublisherId)
--         REFERENCES Publishers(Id)
-- )

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
    Quantity INT NOT NULL DEFAULT(0),
    CONSTRAINT PK_Inventory
        PRIMARY KEY (ISBN, StoreId),
     CONSTRAINT FK_I_Books
        FOREIGN KEY (ISBN)
        REFERENCES Books(ISBN),
    CONSTRAINT FK_I_Stores
        FOREIGN KEY (StoreId)
        REFERENCES Stores(Id)
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

-- INSERT INTO 
--     Authors
-- VALUES
-- (
--     'Robert',
--     'Jordan',
--     '1948-10-17'
-- ),
-- (
--     'J.K',
--     'Rowling',
--     '1965-07-31'
-- ),
-- (
--     'James',
--     'Corey',
--     '1900-01-01'
-- ),
-- (
--     'Douglas',
--     'Adams',
--     '1952-05-11'
-- )



SELECT * FROM Authors
-- SELECT IIF(dbo.ValidateISBNv2('978-0-306-40615-7') = 1, 1, 0)
-- SELECT dbo.ValidateISBNv2('978-3-16-148410-0')

-- select FORMAT(100,'C','se')

SELECT *
FROM tabell
WHERE ISNULL(column, 0) IN (0,1)