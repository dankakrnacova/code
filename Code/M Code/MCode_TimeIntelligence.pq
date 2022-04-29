// format XY with 0 at the beginning
Date.ToText(DateTime.Date(DateTime.LocalNow()), "yyyy-MM-dd")
Text.PadStart(Text.From([Month]),2,”0″)

enddate = DateTime.Date(DateTime.LocalNow()),

today= End_Date,
year = Number.ToText(Date.Year(today)),
month = Text.PadStart(Number.ToText(Date.Month(today)),2,"0"),
day = Text.PadStart(Number.ToText(Date.Day(today)),2,"0"),
mydate = year&"-"&month&"-"&day,


// Previous month calculation
Previous Month FTE = 
    Var current_month = MONTH(TODAY())
    Return  CALCULATE(
                SUM(PPMC_Assign_All[FTE]),
                FILTER('PPMC_Assign_All', MONTH('PPMC_Assign_All'[Forecast_Date]) = current_month -1)
                )

// Is in previous next current month
= Table.AddColumn(#"Replaced New Client Name", "Forecast_IsIn_PrevCurrNext_Month", each 
if (
Date.IsInNextMonth([Forecast_Date]) or 
Date.IsInPreviousMonth([Forecast_Date]) or  
Date.IsInCurrentMonth([Forecast_Date]))
then "True"
else "False"
)


let
    Source = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WMjDUByIjA0NzpdhYAA==", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [StartDate = _t]),
    #"Added Custom" = Table.AddColumn(Source, "EndDate", each Date.From(DateTime.LocalNow())),
    #"Changed Type" = Table.TransformColumnTypes(#"Added Custom",{{"StartDate", type date}, {"EndDate", type date}}),
    #"InsertDates" = Table.AddColumn(#"Changed Type", "Dates", each {Number.From([StartDate])..Number.From([EndDate])}),
    #"Expanded Dates" = Table.ExpandListColumn(#"InsertDates", "Dates"),
    #"Changed Type1" = Table.TransformColumnTypes(#"Expanded Dates",{{"Dates", type date}}),
    #"Removed Columns" = Table.RemoveColumns(#"Changed Type1",{"StartDate", "EndDate"}),
    #"InsertFiscalYear" = Table.AddColumn(#"Removed Columns", "FiscalYear", each #"Get FY"([Dates], 3)),
    #"InsertFiscalQuarter" = Table.AddColumn(#"InsertFiscalYear", "FiscalQuarter", each #"Get Fiscal Qtr"([Dates], 3)),
    #"InsertFiscalYrQuarter" = Table.AddColumn(#"InsertFiscalQuarter", "FiscalQuarterYear", each [FiscalQuarter] & " " & [FiscalYear]),
    #"InsertYear" = Table.AddColumn(#"InsertFiscalYrQuarter", "Year", each Date.Year([Dates])),
    #"InsertQuarterNumber" = Table.AddColumn(#"InsertYear", "QuarterNumber", each Date.QuarterOfYear([Dates])),
    #"InsertMonth" = Table.AddColumn(#"InsertQuarterNumber", "MonthNumber", each Date.Month([Dates])),
    #"InsertDay" = Table.AddColumn(#"InsertMonth", "DayOfMonth", each Date.Day([Dates])),
    #"InsertDateInt" = Table.AddColumn(#"InsertDay", "DateInt", each [Year] * 10000 + [MonthNumber] * 100 + [DayOfMonth]),
    #"InsertMonthName" = Table.AddColumn(#"InsertDateInt", "Month", each Date.ToText([Dates], "MMMM", "en-US"), type text),
    #"InsertCalendarMonth" = Table.AddColumn(#"InsertMonthName", "Month of Year", each [Month] & " " & Number.ToText([Year])),
    #"InsertMonthYrSort" = Table.AddColumn(#"InsertCalendarMonth", "MonthYrSort", each Date.ToText([Dates], "yyyyMM", "cs-CZ"), type number),
    #"InsertQuarterYrSort" = Table.AddColumn(#"InsertMonthYrSort", "QuarterYrSort", each Number.ToText([Year]) & Number.ToText([QuarterNumber])),
    #"InsertToday"= Table.AddColumn(#"InsertQuarterYrSort", "Today", each DateTime.Date(DateTime.LocalNow())),
    #"Changed Type2" = #"Table.TransformColumnTypes"(#"InsertToday",{{"FiscalYear", Int64.Type}, {"Year", Int64.Type}, {"QuarterNumber", Int64.Type}, {"MonthNumber", Int64.Type}, {"DayOfMonth", Int64.Type}, {"DateInt", Int64.Type}, {"MonthYrSort", Int64.Type}, {"QuarterYrSort", Int64.Type}})
in
    #"Changed Type2"