/* DateNow table - to create FY and Q columns and filter out the folders in TimeTracking table
https://dxcportal.sharepoint.com/sites/.../2_Time tracking reports/FY19/Q3 FY19/ 
create columns QX FYXX */

let
    Source = Date.From(DateTime.LocalNow()),
    ConvertedToTable = #table(1, {{Source}}),
    RenamedDate = Table.RenameColumns(ConvertedToTable,{{"Column1", "Date"}}),
    ChangedType = Table.TransformColumnTypes(RenamedDate,{{"Date", type date}}),
    InsertedFY_Step1 = Table.AddColumn(ChangedType, "FY", each GetFY([Date], 3)),
    InsertedFY_Step2 = Table.TransformColumns(InsertedFY_Step1, {{"FY", each Text.End(_, 2), type text}}),
    InsertedQ = Table.AddColumn(InsertedFY_Step2, "Quarter", each GetQ([Date], 3)),
    DuplicatedDate = Table.DuplicateColumn(InsertedQ, "Date", "Month"),
    ExtractedMonthName = Table.TransformColumns(DuplicatedDate, {{"Month", each Date.MonthName(_), type text}}),
    ChangedType1 = Table.TransformColumnTypes(ExtractedMonthName,{{"FY", Int64.Type}, {"Quarter", Int64.Type}})
in
    ChangedType1

// DateCreated NEW

let
    Source = SharePoint.Files("https://dxcportal.sharepoint.com/sites/projectShineRDCSofia/RDCSofiaBusOps", [ApiVersion = 15]),
    FilteredTimeTrackingReports = Table.SelectRows(Source, each Text.Contains([Folder Path], "Time tracking reports")),
    ChangedType1 = Table.TransformColumnTypes(FilteredTimeTrackingReports,{{"Date created", type date}}),
    InsertedFY = Table.AddColumn(ChangedType1, "FY", each Text.BetweenDelimiters([Folder Path], "FY", "/")),
    InsertedQ_Step1 = Table.AddColumn(InsertedFY, "Q", each Text.AfterDelimiter([Folder Path], "Q")),
    InsertedQ_Step2 = Table.TransformColumns(InsertedQ_Step1, {{"Q", each Text.Start(_, 1), type text}}),
    InsertedMonth = Table.AddColumn(InsertedQ_Step2, "Month", each Date.MonthName([Date created])),
    ChangedType2 = Table.TransformColumnTypes(InsertedMonth,{{"FY", Int64.Type}, {"Q", Int64.Type}, {"Month", type text}}),
    MergedCurrentFY = Table.NestedJoin(ChangedType2, {"FY"}, DateNow, {"FY"}, "DateNow", JoinKind.Inner),
    MergedCurrentQ = Table.NestedJoin(MergedCurrentFY, {"Q"}, DateNow, {"Quarter"}, "DateNow.1", JoinKind.Inner),
    MergedCurrentMonth = Table.NestedJoin(MergedCurrentQ, {"Month"}, DateNow, {"Month"}, "DateNow.2", JoinKind.Inner),
    FilteredHiddenFiles = Table.SelectRows(MergedCurrentMonth, each [Attributes]?[Hidden]? <> true),
    FilteredLatestDateCreated = Table.SelectRows(FilteredHiddenFiles, let latest = List.Max(FilteredHiddenFiles[Date created]) in each [Date created] = latest),
    // this step will be removed if there are more files in each month
    InvokeTransformFile = Table.AddColumn(FilteredLatestDateCreated, "Transform File", each #"Transform File"([Content])),
    RenamedDateCreated = Table.RenameColumns(InvokeTransformFile,{{"Date created", "DateCreated"}}),
    SelectDateCreated = Table.SelectColumns(RenamedDateCreated,{"DateCreated"}),
    Added_StartOfMonth = Table.AddColumn(SelectDateCreated, "StartOfMonth", each Date.StartOfMonth([DateCreated]), type date),
    Added_EndOfMonth = Table.AddColumn(Added_StartOfMonth, "EndOfMonth", each Date.EndOfMonth([DateCreated]), type date),
    Added_ListOfDates = Table.AddColumn(Added_EndOfMonth, "ListOfDates", each {Number.From([StartOfMonth])..Number.From([EndOfMonth])}),
    ListOfDates = Table.ExpandListColumn(Added_ListOfDates, "ListOfDates"),
    ChangedType3 = Table.TransformColumnTypes(ListOfDates,{{"ListOfDates", type date}}),
    Added_DayOfWeek = Table.AddColumn(ChangedType3, "DayOfWeek", each Date.DayOfWeek([ListOfDates], Day.Monday)),
    Added_IsCurrentWeek = Table.AddColumn(Added_DayOfWeek, "IsCurrentWeek", each Date.WeekOfMonth([ListOfDates]) = Date.WeekOfMonth([DateCreated]), type logical),
    Added_AllWorkingDays_WithCW = Table.AddColumn(Added_IsCurrentWeek, "AllWorkingDays_WithCurrentWeek", each List.Count(Table.ToList(Table.SelectRows(Added_IsCurrentWeek, each 
                                                                                    [DayOfWeek] <> 5 and [DayOfWeek] <> 6)))),
    Added_ActualWorkingDays_WithCW = Table.AddColumn(Added_AllWorkingDays_WithCW, "ActualWorkingDays_WithCurrentWeek", each List.Count(Table.ToList(Table.SelectRows(Added_IsCurrentWeek, each
                                                    [ListOfDates] < [DateCreated] and [DayOfWeek] <> 5 and [DayOfWeek] <> 6)))),
    Added_ActualWorkingDays_WithoutCW = Table.AddColumn(Added_ActualWorkingDays_WithCW, "ActualWorkingDays_WithoutCurrentWeek", each List.Count(Table.ToList(Table.SelectRows(Added_IsCurrentWeek, each
                                                    [ListOfDates] < [DateCreated] and [DayOfWeek] <> 5 and [DayOfWeek] <> 6 and [IsCurrentWeek] = false)))),
    ChangedType4 = Table.TransformColumnTypes(Added_ActualWorkingDays_WithoutCW,{{"DayOfWeek", Int64.Type}, {"AllWorkingDays_WithCurrentWeek", Int64.Type}, {"ActualWorkingDays_WithCurrentWeek", Int64.Type}, {"ActualWorkingDays_WithoutCurrentWeek", Int64.Type}})
in
    ChangedType4

// DateCreated OLD

let
    Source = SharePoint.Files("https://dxcportal.sharepoint.com/sites/projectShineRDCSofia/RDCSofiaBusOps", [ApiVersion = 15]),
    FilteredTimeTrackingReports = Table.SelectRows(Source, each Text.Contains([Folder Path], "Time tracking reports")),
    ChangedTypeDateCreated = Table.TransformColumnTypes(FilteredTimeTrackingReports,{{"Date created", type date}}),
    InsertedFY = Table.AddColumn(ChangedTypeDateCreated, "FY", each Text.BetweenDelimiters([Folder Path], "FY", "/")),
    InsertedQ_Step1 = Table.AddColumn(InsertedFY, "Q", each Text.AfterDelimiter([Folder Path], "Q")),
    InsertedQ_Step2 = Table.TransformColumns(InsertedQ_Step1, {{"Q", each Text.Start(_, 1), type text}}),
    InsertedMonth = Table.AddColumn(InsertedQ_Step2, "Month", each Date.MonthName([Date created])),
    ChangedType = Table.TransformColumnTypes(InsertedMonth,{{"FY", Int64.Type}, {"Q", Int64.Type}, {"Month", type text}}),
    MergedCurrentFY = Table.NestedJoin(ChangedType, {"FY"}, DateNow, {"FY"}, "DateNow", JoinKind.Inner),
    MergedCurrentQ = Table.NestedJoin(MergedCurrentFY, {"Q"}, DateNow, {"Quarter"}, "DateNow.1", JoinKind.Inner),
    MergedCurrentMonth = Table.NestedJoin(MergedCurrentQ, {"Month"}, DateNow, {"Month"}, "DateNow.2", JoinKind.Inner),
    FilteredHiddenFiles = Table.SelectRows(MergedCurrentMonth, each [Attributes]?[Hidden]? <> true),
    FilteredLatestDateCreated = Table.SelectRows(FilteredHiddenFiles, let latest = List.Max(FilteredHiddenFiles[Date created]) in each [Date created] = latest),
    InvokeTransformFile = Table.AddColumn(FilteredLatestDateCreated, "Transform File", each #"Transform File"([Content])),
    RenamedDateCreated = Table.RenameColumns(InvokeTransformFile,{{"Date created", "DateCreated"}}),
    SelectDateCreated = Table.SelectColumns(RenamedDateCreated,{"DateCreated"}),
    AddedStartOfMonth = Table.AddColumn(SelectDateCreated, "StartOfMonth", each Date.StartOfMonth([DateCreated]), type date),
    AddedListOfDates = Table.AddColumn(AddedStartOfMonth, "ListOfDates", each {Number.From([StartOfMonth])..Number.From([DateCreated])}),
    ListOfDates = AddedListOfDates{0}[ListOfDates],
    ConvertedToTable = Table.FromList(ListOfDates, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    ChangedType1 = Table.TransformColumnTypes(ConvertedToTable,{{"Column1", type date}}),
    RenamedColumns = Table.RenameColumns(ChangedType1,{{"Column1", "Dates"}}),
    AddedDayOfWeek = Table.AddColumn(RenamedColumns, "DayOfWeek", each Date.DayOfWeek([Dates], Day.Monday)),
    FilteredWeekDays = Table.SelectRows(AddedDayOfWeek, each ([DayOfWeek] <> 5 and [DayOfWeek] <> 6)),
    AddedDaysCountWithReportDay = Table.AddColumn(FilteredWeekDays, "DaysCountWithReportDay", each List.Count(Table.ToList(FilteredWeekDays))),
    AddedDaysCountWoutReportDay = Table.AddColumn(AddedDaysCountWithReportDay, "DaysCountWithoutReportDay", each [DaysCountWithReportDay] - 1),
    KeptLastRow = Table.LastN(AddedDaysCountWoutReportDay, 1),
    #"Added Custom" = Table.AddColumn(KeptLastRow, "ActualTotalHrs", each [DaysCountWithoutReportDay] * 8),
    ChangedType2 = Table.TransformColumnTypes(#"Added Custom",{{"DaysCountWithReportDay", Int64.Type}, {"DaysCountWithoutReportDay", Int64.Type}, {"ActualTotalHrs", Int64.Type}})
in
    ChangedType2

// TimeTracking

let
    Source = SharePoint.Files("https://dxcportal.sharepoint.com/sites/projectShineRDCSofia/RDCSofiaBusOps", [ApiVersion = 15]),
    FilteredTimeTrackingReports = Table.SelectRows(Source, each Text.Contains([Folder Path], "Time tracking reports")),
    ChangedTypeDateCreated = Table.TransformColumnTypes(FilteredTimeTrackingReports,{{"Date created", type date}}),
    InsertedFY = Table.AddColumn(ChangedTypeDateCreated, "FY", each Text.BetweenDelimiters([Folder Path], "FY", "/")),
    InsertedQ_Step1 = Table.AddColumn(InsertedFY, "Q", each Text.AfterDelimiter([Folder Path], "Q")),
    InsertedQ_Step2 = Table.TransformColumns(InsertedQ_Step1, {{"Q", each Text.Start(_, 1), type text}}),
    InsertedMonth = Table.AddColumn(InsertedQ_Step2, "Month", each Date.MonthName([Date created])),
    ChangedType = Table.TransformColumnTypes(InsertedMonth,{{"FY", Int64.Type}, {"Q", Int64.Type}, {"Month", type text}}),
    MergedCurrentFY = Table.NestedJoin(ChangedType, {"FY"}, DateNow, {"FY"}, "DateNow", JoinKind.Inner),
    MergedCurrentQ = Table.NestedJoin(MergedCurrentFY, {"Q"}, DateNow, {"Quarter"}, "DateNow.1", JoinKind.Inner),
    MergedCurrentMonth = Table.NestedJoin(MergedCurrentQ, {"Month"}, DateNow, {"Month"}, "DateNow.2", JoinKind.Inner),
    FilteredHiddenFiles = Table.SelectRows(MergedCurrentMonth, each [Attributes]?[Hidden]? <> true),
    FilteredMaxCreatedDate = Table.SelectRows(FilteredHiddenFiles, let latest = List.Max(FilteredHiddenFiles[Date created]) in each [Date created] = latest),
    InvokeTransformFile = Table.AddColumn(FilteredMaxCreatedDate, "Transform File", each #"Transform File"([Content])),
    SelectTransformFile = Table.SelectColumns(InvokeTransformFile, {"Transform File"}),
    ExpandedTable = Table.ExpandTableColumn(SelectTransformFile, "Transform File", Table.ColumnNames(#"Transform File"(#"Sample File"))),
    LowercasedText = Table.TransformColumns(ExpandedTable,{{"Name", Text.Lower, type text}}),
    FilteredRawData = Table.SelectRows(LowercasedText, each Text.Contains([Name], "raw")),
    AddedData1 = Table.AddColumn(FilteredRawData, "Data1", each Table.PromoteHeaders([Data], [PromoteAllScalars=true])),
    AddedData2 = Table.AddColumn(AddedData1, "Data2", each Table.SelectColumns([Data1],{"Activity Month", "Employee", "Employee name", "Activity Hours", "Total target hrs", "DXC Supervisor", "L5 Lead", "L4 Lead"})),
    Data2 = AddedData2{0}[Data2],
    FilteredL4 = Table.SelectRows(Data2, each ([L4 Lead] = "Peter Mrazik")),
    RenamedColumns = Table.RenameColumns(FilteredL4,{{"Employee", "EID"}, {"Employee name", "EmployeeName"}, {"Activity Hours", "TrackedHrs"}, {"Activity Month", "ActivityMonth"}, {"Total target hrs", "TotalTargetHrs"}}),
    RemovedColumns = Table.RemoveColumns(RenamedColumns,{"L4 Lead"}),
    ChangedType2 = Table.TransformColumnTypes(RemovedColumns,{{"TrackedHrs", type number}, {"TotalTargetHrs", type number}, {"EID", Int64.Type}}),
    GroupBy = Table.Group(ChangedType2, {"ActivityMonth", "EID", "TotalTargetHrs"}, {{"ActivityHrsTracked", each List.Sum([TrackedHrs]), type nullable number}})
in
    GroupBy

// DAX

LessThanActualTotalHrs = TimeTracking[ActivityHrsTracked] < DateCreated[Actual Total Hrs]
DateTable = CALENDAR(DATE(YEAR(DateCreated[Dates]),MONTH(DateCreated[Dates]),1), DATE(YEAR(DateCreated[Dates]),MONTH(DateCreated[Dates]),1))