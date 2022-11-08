
CREATE TABLE Words(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Word NVARCHAR(100) NOT NULL,
    LanguageId INT NOT NULL,
    WordListId INT NOT NULL
)

CREATE TABLE WordTranslations(
    Id INT IDENTITY(1,1) PRIMARY KEY, 
    WordId INT NOT NULL,
    TranslationWordId INT NOT NULL
)

CREATE TABLE Languages(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
)

CREATE TABLE WordLists(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
)

--##

-- GetLists
SELECT WordListName
FROM WordLists

--Add
DECLARE @FromWordId INT
DECLARE @ToWordId INT



INSERT INTO Words
VALUES
    (@fromWord, @fromLanguage)

INSERT INTO Words
VALUES
    (@ToWord, @toLanguage)

INSERT INTO WordTranslations
VALUES
    (@FromWordId,@ToWordId),
    (@ToWordId,@FromWordId)

--##

SELECT  * FROM WordLists

SELECT * FROM Words

SELECT 
    fromWords.Word AS FromWord,
    fromLang.LanguageName,
    toWords.Word AS ToWord,
    toLang.LanguageName
FROM
    WordTranslations wt
    INNER JOIN Words fromWords ON fromWords.Id = wt.WordId
    INNER JOIN Words toWords ON toWords.Id = wt.TranslationWordId
    INNER JOIN Languages fromLang ON fromWords.LanguageId = fromLang.Id
    INNER JOIN Languages toLang ON toWords.LanguageId = toLang.Id
    INNER JOIN WordListWords wlw ON wlw.WordId = fromWords.Id
    INNER JOIN WordLists wl ON wl.Id = wlw.WordListId AND  wl.WordListName = 'test'

-- SELECT 
--     fromWords.Word AS FromWord,
--     (SELECT LanguageName FROM Languages WHERE Id = fromWords.InLanguage) AS FromLanguage,
--     toWords.Word AS ToWord,
--     (SELECT LanguageName FROM Languages WHERE Id = toWords.InLanguage) AS ToLanguage
-- FROM
--     WordTranslations wt
-- INNER JOIN Words fromWords ON fromWords.Id = wt.WordId
-- INNER JOIN Words toWords ON toWords.Id = wt.TranslationWordId
-- WHERE
--     fromWords.Id IN 
--     (
--         SELECT
--              wlw.WordId
--         FROM 
--             WordListWords wlw 
--         INNER JOIN 
--             WordLists wl ON
--                 wl.Id = wlw.WordListId AND
--                 wl.WordListName = 'test'
--     )

-- SELECT
--     w1.Word,
--     (SELECT LanguageName FROM Languages WHERE Id = w1.InLanguage) AS FromLanguage,
--     w2.Word,
--     (SELECT LanguageName FROM Languages WHERE Id = w2.InLanguage) AS ToLanguage
--  FROM 
--     WordTranslations wt
-- INNER JOIN Words w1 ON wt.WordId = w1.Id
-- INNER JOIN Words w2 ON wt.TranslationWordId = w2.Id


-- SELECT
--     w1.Word AS FromWord,
--     l1.LanguageName AS FromLanguage,
--     w2.Word AS ToWord,
--     l2.LanguageName AS ToLanguage
--  FROM 
--     WordTranslations wt
-- INNER JOIN 
--     Words w1 ON wt.WordId = w1.Id
-- INNER JOIN 
--     Words w2 ON wt.TranslationWordId = w2.Id
-- INNER JOIN 
--     Languages l1 ON w1.InLanguage = l1.Id
-- INNER JOIN 
--     Languages l2 ON w2.InLanguage = l2.Id

INSERT INTO Words 
 VALUES
    ('dog', 1),
    ('hund', 2)

INSERT INTO Words 
 VALUES
    ('died', 1),
    ('dog', 2)   

INSERT INTO Words 
 VALUES
    ('drop', 1),
    ('tappa', 2),
    ('droppe', 2)

SELECT * FROM WordTranslations

INSERT INTO WordTranslations
VALUES
    (1,2),
    (3,4),
    (5,6),
    (5,7),
    (2,1),
    (4,3),
    (6,5),
    (7,5)



-- INSERT INTO Languages 
-- VALUES
--     ('English'),
--     ('Swedish')

select * from Languages


INSERT INTO WordLists
VALUES('test')

INSERT INTO WordListWords
VALUES
    (1,1),
    (1,2),
    (1,5),
    (1,6),
    (1,7)


