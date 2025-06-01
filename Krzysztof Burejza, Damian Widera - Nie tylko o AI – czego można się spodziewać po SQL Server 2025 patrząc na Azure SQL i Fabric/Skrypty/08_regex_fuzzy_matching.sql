/* #############################################
   ##   REGEX & FUZZY MATCHING SQL SKRYPT    ##
   ##   Przyk³ady wykorzystania wyra¿eñ      ##
   ##   regularnych oraz dopasowania         ##
   ##   przybli¿onego (fuzzy matching)       ##
   ############################################# */

/* 1. Sprawdzenie kompatybilnoœci bazy danych */
SELECT name AS DatabaseName, 
       compatibility_level 
FROM sys.databases
WHERE name = 'dc-sandbox-demo-db'; 

/* 2. Ustawienie poziomu kompatybilnoœci bazy danych na 170 */
ALTER DATABASE CURRENT 
SET COMPATIBILITY_LEVEL = 170;

/* 3. Tworzenie tabeli BoardGames z dodatkowymi kolumnami */
DROP TABLE IF EXISTS dbo.BoardGames;
CREATE TABLE dbo.BoardGames (
    GameID INT PRIMARY KEY,
    GameName NVARCHAR(100),
    GameType NVARCHAR(50),
    Theme NVARCHAR(50),
    GameDescription NVARCHAR(500),
    ReleaseYear INT,  -- Rok wydania
    Publisher NVARCHAR(100),  -- Wydawca
    Mechanics NVARCHAR(200),  -- Mechaniki gry
    Rating DECIMAL(3,1),  -- Ocena gry
    UserReview NVARCHAR(500)  -- Recenzja u¿ytkownika
);


/* 4. Wstawianie przyk³adowych danych do tabeli BoardGames */
INSERT [dbo].[BoardGames] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (1, N'Talisman', N'RPG', N'Fantasy', N'Klasyczna gra przygodowa z rzutami koscia i eksploracja.', 1983, N'Games Workshop', N'Roll-and-move, adventure', CAST(7.2 AS Decimal(3, 1)), N'Super gra, ale zalezna od losowosci!')
GO
INSERT [dbo].[BoardGames] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (2, N'Wiedzmin: Stary Swiat', N'RPG', N'Fantasy', N'Gra osadzona w swiecie Wiedzmina, gracze wcielaja sie w wiedzminów.', 2022, N'Go On Board', N'Deck-building, exploration', CAST(8.1 AS Decimal(3, 1)), N'Bardzo klimatyczna, choc troche dluga.')
GO
INSERT [dbo].[BoardGames] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (3, N'Cyberpunk 2077: Gangs of Night City', N'Strategia', N'Sci-Fi', N'Rywalizacja gangów o wladze w Night City.', 2023, N'CMON', N'Area control, asymmetric powers', CAST(7.8 AS Decimal(3, 1)), N'Mega klimatyczna, jak ktos lubi Cyberpunk to must-have!')
GO
INSERT [dbo].[BoardGames] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (4, N'Star Wars: Rebellion', N'Strategia', N'Sci-Fi', N'Wielka wojna miedzy Rebelia a Imperium.', 2016, N'Fantasy Flight Games', N'Asymmetry, hidden movement', CAST(8.5 AS Decimal(3, 1)), N'Genialna strategia, ale dluga rozgrywka.')
GO
INSERT [dbo].[BoardGames] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (5, N'Star Wars: Imperial Assault', N'Wojna', N'Sci-Fi', N'Taktyczna gra figurkowa w swiecie Star Wars.', 2014, N'Fantasy Flight Games', N'Miniatures, campaign mode', CAST(8.0 AS Decimal(3, 1)), N'Bardzo dobra, ale setup dlugo trwa...')
GO
INSERT [dbo].[BoardGames] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (6, N'Dune: Imperium', N'Strategia', N'Sci-Fi', N'Strategia inspirowana powiescia Diuna.', 2020, N'Dire Wolf Digital', N'Deck-building, worker placement', CAST(8.4 AS Decimal(3, 1)), N'Jeden z najlepszych deck-builderów ever!')
GO
INSERT [dbo].[BoardGames] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (7, N'Mage Knight', N'Strategia', N'Fantasy', N'Deck-building i eksploracja w jednym.', 2011, N'WizKids', N'Deck-building, exploration', CAST(8.1 AS Decimal(3, 1)), N'Bardzo trudna, ale satysfakcjonujaca.')
GO
INSERT [dbo].[BoardGames] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (8, N'Gloomhaven', N'RPG', N'Fantasy', N'Taktyczna gra RPG z rozbudowana kampania.', 2017, N'Cephalofair Games', N'Campaign, hand management', CAST(8.8 AS Decimal(3, 1)), N'Nie dla kazdego, ale jak sie wciagniesz to sztos.')
GO
INSERT [dbo].[BoardGames] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (9, N'Terraformacja Marsa', N'Strategia', N'Sci-Fi', N'Zarzadzanie korporacja terraformujaca Marsa.', 2016, N'FryxGames', N'Engine building, resource management', CAST(8.4 AS Decimal(3, 1)), N'Troche losowosci, ale klimat super!')
GO
INSERT [dbo].[BoardGames] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (10, N'Catan', N'Rodzinna', N'Sredniowiecze', N'Zbieranie surowców i handel na wyspie.', 1995, N'Kosmos', N'Trading, route building', CAST(7.1 AS Decimal(3, 1)), N'Klasyka, ale czasem irytuje losowosc.')
GO

/* 5. Wyszukiwanie gier z mechanik¹ "deck-building" 
za pomoc¹ wyra¿eñ regularnych */
SELECT * FROM BoardGames
WHERE REGEXP_LIKE(Mechanics, 'deck-building', 'i');

/* 6. Wyszukiwanie recenzji z entuzjastycznymi opiniami */
SELECT * FROM BoardGames
WHERE REGEXP_LIKE(UserReview, 'mega|sztos|genialna', 'i');

/* 7. Sprawdzenie poprawnoœci formatu roku wydania */
SELECT * FROM BoardGames
WHERE REGEXP_LIKE(CAST(ReleaseYear AS NVARCHAR(10)), '[0-9]{4}')

/* 8. Pobranie recenzji zawieraj¹cych s³owo "losowoœæ" */
SELECT UserReview FROM BoardGames
WHERE REGEXP_LIKE(UserReview, 'losowoœæ', 'i');

/* 9. Przyk³ad u¿ycia REGEXP_REPLACE do formatowania numerów */
SELECT REGEXP_REPLACE(
'123-456-7890', 
'([0-9]{3})-([0-9]{3})-([0-9]{4})', 
'(\1) \2-\3');

/* #############################################
   ##         FUZZY MATCHING (DOPASOWANIE PRZYBLI¯ONE)         ##
   ############################################# */

/* 10. Tworzenie tabeli z b³êdnie zapisanymi nazwami gier */
DROP TABLE IF EXISTS dbo.BoardGamesFuzzy;
CREATE TABLE dbo.BoardGamesFuzzy (
    GameID INT PRIMARY KEY,
    GameName NVARCHAR(100),
    GameType NVARCHAR(50),
    Theme NVARCHAR(50),
    GameDescription NVARCHAR(500),
    ReleaseYear INT,
    Publisher NVARCHAR(100),
    Mechanics NVARCHAR(200),
    Rating DECIMAL(3,1),
    UserReview NVARCHAR(500)
);

/* 11. Wstawianie danych z b³êdami do tabeli BoardGamesFuzzy */
INSERT [dbo].[BoardGamesFuzzy] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (1, N'Talisman', N'RPG', N'Fantasy', N'Klasyczna gra przygodowa.', 1983, N'Games Workshop', N'Roll-and-move', CAST(7.2 AS Decimal(3, 1)), N'Fajna gra!')
GO
INSERT [dbo].[BoardGamesFuzzy] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (2, N'Talizman', N'RPG', N'Fantasy', N'Bledna pisownia Talisman.', 1983, N'GamesWorkshopp', N'Roll&move', CAST(7.1 AS Decimal(3, 1)), N'Fajna gra')
GO
INSERT [dbo].[BoardGamesFuzzy] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (3, N'Wiedzmin: Stary Swiat', N'RPG', N'Fantasy', N'Gra osadzona w swiecie Wiedzmina.', 2022, N'Go On Board', N'Deck-building', CAST(8.1 AS Decimal(3, 1)), N'Super klimat!')
GO
INSERT [dbo].[BoardGamesFuzzy] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (4, N'Wiedzmin - Stary Swiat', N'RPG', N'Fantasy', N'Bledna nazwa Wiedzmin.', 2022, N'GoOnBoard', N'Deckbuilding', CAST(8.0 AS Decimal(3, 1)), N'Super klimatt!')
GO
INSERT [dbo].[BoardGamesFuzzy] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (5, N'Cyberpunk 2077: Gangs of Night City', N'Strategia', N'Sci-Fi', N'Gra planszowa o gangach Night City.', 2023, N'CMON', N'Area control', CAST(7.8 AS Decimal(3, 1)), N'Mega fajna!')
GO
INSERT [dbo].[BoardGamesFuzzy] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (6, N'Cyber-Punk 2077', N'Strategia', N'Sci-Fi', N'Bledna nazwa Cyberpunk.', 2023, N'C-MON', N'Control area', CAST(7.7 AS Decimal(3, 1)), N'Mega faina!')
GO
INSERT [dbo].[BoardGamesFuzzy] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (7, N'Star Wars: Rebellion', N'Strategia', N'Sci-Fi', N'Rebelianci vs Imperium.', 2016, N'Fantasy Flight Games', N'Asymmetry', CAST(8.5 AS Decimal(3, 1)), N'Bardzo dobra strategia!')
GO
INSERT [dbo].[BoardGamesFuzzy] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (8, N'Star Wars Rebelln', N'Strategia', N'Sci-Fi', N'Literówka w Star Wars: Rebellion.', 2016, N'Fantasy Flight', N'Asymetric', CAST(8.4 AS Decimal(3, 1)), N'Bardz dobra strategia!')
GO
INSERT [dbo].[BoardGamesFuzzy] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (9, N'Terraformacja Marsa', N'Strategia', N'Sci-Fi', N'Kultowa gra o terraformacji Marsa.', 2016, N'FryxGames', N'Engine building', CAST(8.4 AS Decimal(3, 1)), N'Super gra!')
GO
INSERT [dbo].[BoardGamesFuzzy] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (10, N'Terraforming Mars', N'Strategia', N'Sci-Fi', N'Angielska wersja gry.', 2016, N'Fryx Games', N'Engine-building', CAST(8.3 AS Decimal(3, 1)), N'Great game!')
GO
INSERT [dbo].[BoardGamesFuzzy] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (11, N'Catan', N'Rodzinna', N'Sredniowiecze', N'Klasyczna gra ekonomiczna.', 1995, N'Kosmos', N'Trading', CAST(7.1 AS Decimal(3, 1)), N'Klasyka!')
GO
INSERT [dbo].[BoardGamesFuzzy] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (12, N'Osadnicy z Catanu', N'Rodzinna', N'Sredniowiecze', N'Polska wersja Catan.', 1995, N'Kosmos', N'Handel', CAST(7.0 AS Decimal(3, 1)), N'Super zabawa!')
GO
INSERT [dbo].[BoardGamesFuzzy] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (13, N'Gloomhaven', N'RPG', N'Fantasy', N'Taktyczna RPG z rozwojem bohatera.', 2017, N'Cephalofair Games', N'Hand management', CAST(8.8 AS Decimal(3, 1)), N'Najlepsza RPG!')
GO
INSERT [dbo].[BoardGamesFuzzy] ([GameID], [GameName], [GameType], [Theme], [GameDescription], [ReleaseYear], [Publisher], [Mechanics], [Rating], [UserReview]) VALUES (14, N'Gloom Haven', N'RPG', N'Fantasy', N'Blednie zapisany Gloomhaven.', 2017, N'Cephalofair', N'Hand-management', CAST(8.7 AS Decimal(3, 1)), N'Najlpsza RPG!')

/* 12. Dopasowanie podobnych nazw gier na podstawie 
EDIT_DISTANCE */
SELECT a.GameName AS OriginalName, 
       b.GameName AS SimilarName, 
       EDIT_DISTANCE(a.GameName, b.GameName) AS EditDistance
FROM dbo.BoardGamesFuzzy a
JOIN dbo.BoardGamesFuzzy b ON a.GameID <> b.GameID
order by EditDistance

/* 13. Dopasowanie podobnych nazw na podstawie 
EDIT_DISTANCE_SIMILARITY */
SELECT a.GameName AS OriginalName, 
       b.GameName AS SimilarName, 
       EDIT_DISTANCE_SIMILARITY(a.GameName, b.GameName) AS Similarity
FROM dbo.BoardGamesFuzzy a 
JOIN dbo.BoardGamesFuzzy b ON a.GameID <> b.GameID
order by Similarity

/* 14. Dopasowanie wydawców na podstawie 
JARO_WINKLER_DISTANCE */
SELECT a.Publisher AS OriginalPublisher, 
       b.Publisher AS SimilarPublisher, 
       JARO_WINKLER_DISTANCE(a.Publisher, b.Publisher) AS Similarity
FROM dbo.BoardGamesFuzzy a
JOIN dbo.BoardGamesFuzzy b ON a.GameID <> b.GameID
order by Similarity

/* 15. Dopasowanie podobnych mechanik gry */
SELECT a.Mechanics, b.Mechanics, 
       JARO_WINKLER_SIMILARITY(a.Mechanics, b.Mechanics) AS Similarity
FROM BoardGames a
JOIN BoardGames b ON a.GameID <> b.GameID
order by Similarity

