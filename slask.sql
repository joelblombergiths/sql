--select
--    'Hej ' + FirstName + '!' as Greeting,
--    len(FirstName + LastName),
--    len(FirstName + ' ' + LastName),
--    len(FirstName) + len(LastName)
--from Users


--test

SELECT *
FROM Elements
WHERE Meltingpoint BETWEEN 100 and 200

SELECT *
FROM Elements
WHERE [Period] = 1
OR Radius > 200

SELECT *
FROM Elements
WHERE Radius > Boilingpoint

SELECT *
FROM Elements
WHERE Valenceel % 2 = 0



SELECT *
FROM Elements
WHERE Boilingpoint IS NULL AND Meltingpoint IS NULL


SELECT CONVERT(nvarchar(10), 'aaaaaaaaaaa')



--####
CREATE SEQUENCE Counter
    START WITH 1
    INCREMENT BY 1;

SELECT 
    CONCAT(UserName, CAST(NEXT VALUE FOR Counter AS int)) as username
    INTO NewUsers2
FROM
    NewUsers
DROP SEQUENCE Counter



DBCC TRACEON(460, -1);
BEGIN TRAN
UPDATE 
    NewUsers
SET
    UserName = UserName + '1'--TRIM(CONCAT(TRIM(UserName), NEXT VALUE FOR Counter ))
WHERE
    UserName IN (
        SELECT
            nu.UserName
        FROM
            NewUsers nu
        GROUP BY
            nu.UserName
        HAVING
            COUNT(*) > 1
    )
ROLLBACK

DROP SEQUENCE Counter


CREATE SEQUENCE Counter
    START WITH 1
    INCREMENT BY 1;

SELECT
    *
FROM
    NewUsers nu

DROP SEQUENCE Counter

--####
sp_help Users

DBCC TRACEON(460, -1);

--DUPLICATE USERNAMES FÖRSÖK
--##
DECLARE @Counter INT = 0

UPDATE
    NewUsers
SET
    UserName = CONCAT(UserName, @Counter),
    @Counter = @Counter + 1
WHERE
    UserName IN (
        SELECT
            nu.UserName
        FROM
            NewUsers nu
        GROUP BY
            nu.UserName
        HAVING
            COUNT(*) > 1
    )

--##
DECLARE @Duplicates TABLE
(
    ID INT IDENTITY(1, 1),
    Username NVARCHAR(6)
)

INSERT INTO
    @Duplicates
SELECT
    nu.UserName
FROM
    NewUsers nu
GROUP BY
    nu.UserName
HAVING
    COUNT(*) > 1

WHILE
    (SELECT COUNT(*) FROM @Duplicates) > 0
BEGIN
    DECLARE @i INT = (
        SELECT
            TOP 1 ID
        FROM
            @Duplicates
        ORDER BY
            ID
        )

    CREATE SEQUENCE Counter
        START WITH 1
        INCREMENT BY 1;

    UPDATE 
        NewUsers
    SET
        UserName = CONCAT(UserName, (NEXT VALUE FOR Counter))
    WHERE
        UserName = (
            SELECT
                UserName
            FROM
                @Duplicates
            WHERE
                ID = @i
        )
    
    DROP SEQUENCE Counter

    DELETE FROM
        @Duplicates
    WHERE
        ID = @i
END
--##

WITH duplicates AS (
    SELECT
        nu.Username,
        ROW_NUMBER() OVER (PARTITION BY nu.Username ORDER BY nu.ID) AS Counter
    FROM
        NewUsers nu
) 
UPDATE 
    duplicates
SET
    duplicates.UserName = CONCAT(duplicates.UserName, duplicates.Counter)
FROM
    duplicates
WHERE   
    duplicates.Counter > 1