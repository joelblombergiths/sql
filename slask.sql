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