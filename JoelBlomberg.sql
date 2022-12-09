SELECT
    m.Spacecraft,
    m.[Launch date],
    m.[Carrier rocket],
    m.Operator,
    m.[Mission type]
    INTO SuccessfulMissions
FROM
    MoonMissions m
WHERE
    m.Outcome = 'Successful'

GO

UPDATE
    SuccessfulMissions
SET
    Operator = LTRIM(Operator)

GO

UPDATE
    SuccessfulMissions
SET
    Spacecraft = RTRIM(SUBSTRING(Spacecraft, 1, CHARINDEX('(', Spacecraft) - 1))
WHERE
    CHARINDEX('(', Spacecraft) > 0

GO

SELECT
    Operator,
    [Mission type],
    COUNT(*) AS 'Mission Count'
FROM
    SuccessfulMissions
GROUP BY
    Operator,
    [Mission type]
HAVING
    COUNT(*) > 1
ORDER BY
    Operator,
    [Mission type]

GO

SELECT 
    u.ID,
    u.UserName,
    u.Password,
    CONCAT(u.FirstName, ' ', u.LastName) AS Name,
    CASE SUBSTRING(u.ID, 10, 1) % 2
        WHEN 0 THEN 'Female'
        ELSE 'Male'
    END AS Gender,
    u.Email,
    u.Phone
    INTO NewUsers
FROM 
    Users u

GO

SELECT
    nu.UserName,
    COUNT(*) AS NumDuplicates
FROM
    NewUsers nu
GROUP BY
    nu.UserName
HAVING
    COUNT(*) > 1

GO

WITH duplicates AS (
    SELECT
        u.FirstName,
        u.LastName,
        nu.UserName,
        ROW_NUMBER() OVER (PARTITION BY nu.Username ORDER BY nu.ID) AS Counter
    FROM
        NewUsers nu
        INNER JOIN Users u ON u.ID = nu.ID
) 
UPDATE 
    duplicates
SET
    duplicates.UserName = 
    CASE
        WHEN LEN(duplicates.FirstName) >= 4
        THEN 
            CONCAT(
                LOWER(SUBSTRING(duplicates.FirstName, 1, 4)),
                LOWER(SUBSTRING(duplicates.LastName, 1, 2))
            )
        ELSE
            CONCAT(
                LOWER(SUBSTRING(duplicates.FirstName, 1, 2)),
                LOWER(SUBSTRING(duplicates.LastName, 1, 4))
            )
    END
FROM
    duplicates
WHERE   
    duplicates.Counter > 1

GO

DELETE FROM
    NewUsers
WHERE
    SUBSTRING(ID, 1, 6) < DATEFROMPARTS(1970, 1, 1) AND
    Gender = 'Female'
    
GO

DECLARE @firstName NVARCHAR(20) = 'Kalle'
DECLARE @lastName NVARCHAR(20) = 'Karlsson'

INSERT INTO
    NewUsers
    (
        ID,
        UserName,
        Password,
        Name,
        Gender,
        Email,
        Phone
    )
VALUES
    (
        '700101-1235',
        CONCAT(SUBSTRING(@firstName, 1, 3), SUBSTRING(@lastName, 1 ,3)),
        NEWID(),
        CONCAT(@firstName, ' ', @lastName),
        'Male',
        CONCAT(@firstName, '.', @lastName, '@mail.com'),
        '071123456789'
    )

GO

SELECT
    nu.Gender,
    AVG(
        DATEDIFF(
            YEAR,
            SUBSTRING(nu.ID, 1, 6),
            GETDATE()
        )
    ) AS AverageAge
FROM
    NewUsers nu
GROUP BY
    nu.Gender

GO

SELECT
    p.Id,
    p.ProductName AS Product,
    s.CompanyName AS Supplier,
    c.CategoryName AS Category
FROM
    company.products p
    INNER JOIN company.suppliers s ON s.Id = p.SupplierId
    INNER JOIN company.categories c ON c.Id = p.CategoryId

GO

SELECT
    r.RegionDescription AS Region,
    COUNT(distinct e.Id) AS EmployeesInRegion
FROM
    company.regions r
    INNER JOIN company.territories t ON t.RegionId = r.Id
    INNER JOIN company.employee_territory et ON et.TerritoryId = t.Id 
    INNER JOIN company.employees e ON e.Id = et.EmployeeId
GROUP BY
    r.RegionDescription

GO

SELECT
    e.Id,
    CONCAT(e.TitleOfCourtesy, ' ', e.FirstName, ' ', e.LastName) AS Name,
    CASE
        WHEN (e.ReportsTo IS NULL) THEN
            'Nobody!'
        ELSE
            CONCAT(m.TitleOfCourtesy, ' ', m.FirstName, ' ', m.LastName)
    END AS ReportsTo
FROM
    company.employees e
    LEFT JOIN company.employees m ON m.Id = e.ReportsTo

GO