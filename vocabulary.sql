USE Vocabulary;

CREATE TABLE Words(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Word NVARCHAR(100) NOT NULL,
    InLanguage INT NOT NULL 
)

CREATE TABLE WordTranslations(
    Id INT IDENTITY(1,1) PRIMARY KEY, 
    WordId INT NOT NULL,
    TranslationWordId INT NOT NULL
)

CREATE TABLE Languages(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    LanguageName NVARCHAR(50) NOT NULL
)

CREATE TABLE WordLists(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    WordListName NVARCHAR(50) NOT NULL
)

CREATE TABLE WordListWords(
    Id INT IDENTITY(1,1)PRIMARY KEY,
    WordListId INT NOT NULL,
    WordId INT NOT NULL
)





-- INSERT INTO Languages 
-- VALUES
--     ('English'),
--     ('Swedish')

select * from Languages


-- INSERT INTO Words 
-- VALUES('dog', 2)

-- INSERT INTO WordListWords
-- VALUES(1,1)

