// crete queries

//The Power Query Editor Window go to Home Tab
//New Source Drop Down >> Other Sources >> Blank Query
//Once you get a blank query go the View Tab >> Advanced Editor >> Delete everything and paste the first code there. 
//Also rename the Query to something more meaningful like “Get FY”

// Get FY ak DateValue vzdy not null
= (DateValue as date, MonthEnding as number) =>
let
    CY = Text.From ( Date.Year ( DateValue ) ),
    NY = Text.From ( Date.Year ( DateValue ) + 1 ),
    PY = Text.From ( Date.Year ( DateValue ) - 1 ),
    MonthCheck = Date.Month ( DateValue ) > MonthEnding,
    FiscalYear = 
        if
            MonthCheck
        then 
            CY
        else
            PY
in
    FiscalYear

// Get FY ak DateValue moze byt null
= (DateValue, MonthEnding as number) =>
if DateValue <> null then
let 
    CY = Text.From ( Date.Year ( DateValue ) ),
    NY = Text.From ( Date.Year ( DateValue ) + 1 ),
    PY = Text.From ( Date.Year ( DateValue ) - 1 ),
    MonthCheck = Date.Month ( DateValue ) > MonthEnding,
    FiscalYear = 
        if
            MonthCheck
        then 
            NY
        else
            CY 
in
    FiscalYear
else null

// Get Fiscal Qtr
= (DateValue as date, MonthEnding as number) =>
let
    AdjustedMonth = "Q" & Text.From ( Number.RoundUp ( Date.Month ( Date.AddMonths ( DateValue, - MonthEnding ) ) / 3 ) )
in
    AdjustedMonth

// From the Add Columns Tab >> Custom Column
// Write the function = #”Get FY” ( [Dates] , 3 )
// Just to help you understand, our function takes 2 arguments
// The Date Column of your Data (in our case [Dates])
// Fiscal Year Ending Month number. I wrote 3 because the financial year ends in March 
// In our Query for Dates ensure that the dates are in Date Format (and not datetime or any other)

let 
    StartDate = #date(2014, 1, 1),
    DayCount = Duration.Days(Duration.From(#date(Date.Year(Date.AddYears(DateTime.LocalNow(),2)),1,1)  - StartDate)),
    // Add a day back, as Duration math above will give you the days literally between rather than inclusive. Ex Dec 31 - Dec 1 = 30 days, but we need 31 days in that period
    DayCountAdd = DayCount + 1,
    // Create a Dates list object starting at the start date, for the duration of the day count, increment of one year
    Source2 = List.Dates(StartDate,DayCountAdd,#duration(1,0,0,0)),
    // Turn that date list into a table
    TableFromList = Table.FromList(Source2, Splitter.SplitByNothing()),    
    // Update the type to Date
    ChangedType = Table.TransformColumnTypes(TableFromList,{{"Column1", type date}}),
    // Rename the only column in the table to date
    RenamedColumns = Table.RenameColumns(ChangedType,{{"Column1", "Date"}}),
    // Insert columns for different units within the date dimension and supporting columns for sorting
    // Optional "cs-CZ" parameter is used where applicable
    InsertYear = Table.AddColumn(RenamedColumns, "Year", each Date.Year([Date])),
    InsertQuarter = Table.AddColumn(InsertYear, "QuarterNumber", each Date.QuarterOfYear([Date])),
    InsertMonth = Table.AddColumn(InsertQuarter, "MonthNumber", each Date.Month([Date])),
    InsertDay = Table.AddColumn(InsertMonth, "DayOfMonth", each Date.Day([Date])),
    InsertDayInt = Table.AddColumn(InsertDay, "DateInt", each [Year] * 10000 + [MonthNumber] * 100 + [DayOfMonth]),
    InsertMonthName = Table.AddColumn(InsertDayInt, "Month", each Date.ToText([Date], "MMMM", "en-US"), type text),
    InsertCalendarMonth = Table.AddColumn(InsertMonthName, "Month Of Year", each [Month] & " " & Number.ToText([Year])),
    InsertCalendarQtr = Table.AddColumn(InsertCalendarMonth, "Quarter of Year", each "Q" & Number.ToText([QuarterNumber]) & " " & Number.ToText([Year])),
    InsertMonthYrSort = Table.AddColumn(InsertCalendarQtr, "MonthYrSort", each Date.ToText([Date], "yyyyMM", "cs-CZ"), type number),
    InsertQuarterSort = Table.AddColumn(InsertMonthYrSort, "QuarterYrSort", each Number.ToText([Year]) & Number.ToText([QuarterNumber])),
    #"Added Custom" = Table.AddColumn(InsertQuarterSort, "Today", each DateTime.Date(DateTime.LocalNow())),
    InsertDaysFromToday = Table.AddColumn(#"Added Custom", "DaysFromToday", each DateTime.Date(DateTime.LocalNow())-[Date]),
    #"Přejmenované sloupce" = Table.RenameColumns(InsertDaysFromToday,{{"QuarterNumber", "Quarter"}}),
    #"Changed Type" = Table.TransformColumnTypes(#"Přejmenované sloupce",{{"Year", Int64.Type}, {"Quarter", Int64.Type}, {"MonthNumber", Int64.Type}, {"DayOfMonth", Int64.Type}, {"DateInt", Int64.Type}, {"Quarter of Year", type text}, {"Month Of Year", type text}, {"Month", type text}, {"MonthYrSort", Int64.Type}, {"QuarterYrSort", Int64.Type}, {"DaysFromToday", Int64.Type}, {"Today", type date}})
in
    #"Changed Type"
