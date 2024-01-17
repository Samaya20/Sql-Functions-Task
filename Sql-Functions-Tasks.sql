-- 1. Write a function that returns a list of books with the minimum number of pages issued by a particular publisher.

CREATE FUNCTION GetBooksByPublisherAndMinPages (@PublisherName nvarchar(30))
RETURNS TABLE
AS
RETURN
(
    SELECT 
        B.Id AS BookId,
        B.[Name] AS BookName,
        B.Pages,
        B.YearPress,
        P.[Name] AS PublisherName
    FROM Books B
    INNER JOIN Press P ON B.Id_Press = P.Id
    WHERE P.[Name] = @PublisherName
    AND B.Pages = (SELECT MIN(Pages) FROM Books WHERE Id_Press = P.Id)
);


SELECT * FROM dbo.GetBooksByPublisherAndMinPages('BHV');


-- 2. Write a function that returns the names of publishers who have
-- published books with an average number of pages greater than N. 
-- The average number of pages is passed through the parameter.


CREATE FUNCTION GetPublishersByAveragePages (@AveragePagesThreshold int)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        P.Id AS PublisherId,
        P.[Name] AS PublisherName
    FROM Press P
    INNER JOIN Books B ON P.Id = B.Id_Press
    GROUP BY P.Id, P.[Name]
    HAVING AVG(CAST(B.Pages AS float)) > @AveragePagesThreshold
);



SELECT * FROM dbo.GetPublishersByAveragePages(200);


-- 3. Write a function that returns the total sum of the pages of all 
-- the books in the library issued by the specified publisher.


CREATE FUNCTION GetTotalPagesByPublisher (@PublisherName NVARCHAR(30))
RETURNS INT
AS
BEGIN
    DECLARE @TotalPages int;

    SELECT @TotalPages = SUM(Pages)
    FROM Books B
    INNER JOIN Press P ON B.Id_Press = P.Id
    WHERE P.[Name] = @PublisherName;

    RETURN ISNULL(@TotalPages, 0);
END;


DECLARE @PublisherName NVARCHAR(30) = 'BHV';
DECLARE @TotalPages int;

SET @TotalPages = dbo.GetTotalPagesByPublisher(@PublisherName);

SELECT @TotalPages AS TotalPages;



-- 4. Write a function that returns a list of names and surnames
-- of all students who took books between the two specified dates.

CREATE FUNCTION GetStudentsWhoTookBooksBetweenDates (@StartDate DATETIME, @EndDate DATETIME)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        S.FirstName AS StudentFirstName,
        S.LastName AS StudentLastName
    FROM Students S
    INNER JOIN S_Cards SC ON S.Id = SC.Id_Student
    WHERE SC.DateOut BETWEEN @StartDate AND @EndDate
);


DECLARE @StartDate DATETIME = '2001-01-01';
DECLARE @EndDate DATETIME = '2001-12-31';

SELECT * FROM dbo.GetStudentsWhoTookBooksBetweenDates(@StartDate, @EndDate);



-- 5. Write a function that returns a list of students who are currently 
-- working with the specified book of a certain author.

CREATE FUNCTION GetStudentsWorkingWithBook (@AuthorId int, @BookId int)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        S.FirstName AS StudentFirstName,
        S.LastName AS StudentLastName
    FROM Students S
    INNER JOIN S_Cards SC ON S.Id = SC.Id_Student
    INNER JOIN Books B ON SC.Id_Book = B.Id
    WHERE 
        B.Id_Author = @AuthorId
        AND B.Id = @BookId
        AND SC.DateIn IS NULL 
);


DECLARE @AuthorId int = 1;
DECLARE @BookId int = 3; 

SELECT * FROM dbo.GetStudentsWorkingWithBook(@AuthorId, @BookId);


-- 6. Write a function that returns information about publishers whose total
-- number of pages of books issued by them is greater than N.

CREATE FUNCTION GetPublishersByTotalPages (@TotalPagesThreshold int)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        P.Id AS PublisherId,
        P.[Name] AS PublisherName,
        SUM(B.Pages) AS TotalPages
    FROM Press P
    INNER JOIN Books B ON P.Id = B.Id_Press
    GROUP BY P.Id, P.[Name]
    HAVING SUM(B.Pages) > @TotalPagesThreshold
);


DECLARE @TotalPagesThreshold int = 5000;

SELECT * FROM dbo.GetPublishersByTotalPages(@TotalPagesThreshold);
