-----getting the number of working days between two dates, including the first date. Execute the first section, then use the second section to actually find working days.
------------working days function FROM:
------------https://www.sqlservercentral.com/articles/calculating-work-days
USE MASTER
GO
--If the function already exists, drop it.
IF EXISTS
(
    SELECT *
    FROM dbo.SYSOBJECTS
    WHERE ID = OBJECT_ID(N'[dbo].[fn_WorkDays]')
    AND XType IN (N'FN', N'IF', N'TF')
)
DROP FUNCTION [dbo].[fn_WorkDays]
GO
 CREATE FUNCTION dbo.fn_WorkDays
--Presets
--Define the input parameters (OK if reversed by mistake).
(
    @StartDate DATETIME,
    @EndDate   DATETIME = NULL --@EndDate replaced by @StartDate when DEFAULTed
)

--Define the output data type.
RETURNS INT

AS
--Calculate the RETURN of the function.
BEGIN
    --Declare local variables
    --Temporarily holds @EndDate during date reversal.
    DECLARE @Swap DATETIME

    --If the Start Date is null, return a NULL and exit.
    IF @StartDate IS NULL
        RETURN NULL

    --If the End Date is null, populate with Start Date value so will have two dates (required by DATEDIFF below).
     IF @EndDate IS NULL
        SELECT @EndDate = @StartDate

    --Strip the time element from both dates (just to be safe) by converting to whole days and back to a date.
    --Usually faster than CONVERT.
    --0 is a date (01/01/1900 00:00:00.000)
     SELECT @StartDate = DATEADD(dd,DATEDIFF(dd,0,@StartDate), 0),
            @EndDate   = DATEADD(dd,DATEDIFF(dd,0,@EndDate)  , 0)

    --If the inputs are in the wrong order, reverse them.
     IF @StartDate > @EndDate
        SELECT @Swap      = @EndDate,
               @EndDate   = @StartDate,
               @StartDate = @Swap

    --Calculate and return the number of workdays using the input parameters.
    --This is the meat of the function.
    --This is really just one formula with a couple of parts that are listed on separate lines for documentation purposes.
     RETURN (
        SELECT
        --Start with total number of days including weekends
        (DATEDIFF(dd,@StartDate, @EndDate)+1)
        --Subtact 2 days for each full weekend
        -(DATEDIFF(wk,@StartDate, @EndDate)*2)
        --If StartDate is a Sunday, Subtract 1
        -(CASE WHEN DATENAME(dw, @StartDate) = 'Sunday'
            THEN 1
            ELSE 0
        END)
        --If EndDate is a Saturday, Subtract 1
        -(CASE WHEN DATENAME(dw, @EndDate) = 'Saturday'
            THEN 1
            ELSE 0
        END)
        )
    END
GO

-----------------------------------------------getting the number of workdays between 2 dates -- have to minus 1 if you're not including the start date.
DECLARE @StartDate DATETIME
DECLARE @EndDate DATETIME
SET @StartDate = GETDATE()
SET @EndDate = GETDATE() + 30


SELECT
   (DATEDIFF(dd, @StartDate, @EndDate) + 1)
  -(DATEDIFF(wk, @StartDate, @EndDate) * 2)
  -(CASE WHEN DATENAME(dw, @StartDate) = 'Sunday' THEN 1 ELSE 0 END)
  -(CASE WHEN DATENAME(dw, @EndDate) = 'Saturday' THEN 1 ELSE 0 END)
-------------------------------------------------
