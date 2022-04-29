// GRAD TRACKER v_1

let
    Source = SharePoint.Files("https://dxcportal.sharepoint.com/sites/GIDCEEReportAutomation", [ApiVersion = 15]),
    #"GIDC GRAD Tracker 8 September xlsx_https://dxcportal sharepoint com/sites/GIDCEEReportAutomation/Shared Documents/Reports/" = Source{[Name="GIDC_GRAD_Tracker.xlsx",#"Folder Path"="https://dxcportal.sharepoint.com/sites/GIDCEEReportAutomation/Shared Documents/Reports/"]}[Content],
    #"Imported Excel Workbook" = Excel.Workbook(#"GIDC GRAD Tracker 8 September xlsx_https://dxcportal sharepoint com/sites/GIDCEEReportAutomation/Shared Documents/Reports/"),
    #"RAW DATA_Sheet" = #"Imported Excel Workbook"{[Item="RAW DATA",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(#"RAW DATA_Sheet", [PromoteAllScalars=true]),
    #"Removed Other Columns" = Table.SelectColumns(#"Promoted Headers",{"WMA", "Req No"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Removed Other Columns",{{"Req No", Int64.Type}}),
    #"Removed Errors" = Table.RemoveRowsWithErrors(#"Changed Type", {"Req No"})
in
    #"Removed Errors"

// GRAD TRACKER v_2

let
    Source = SharePoint.Files("https://dxcportal.sharepoint.com/sites/GIDCEEReportAutomation", [ApiVersion = 15]),
    #"GIDC GRAD Tracker 8 September xlsx_https://dxcportal sharepoint com/sites/GIDCEEReportAutomation/Shared Documents/Reports/" = Source{[Name="GIDC_GRAD_Tracker.xlsx",#"Folder Path"="https://dxcportal.sharepoint.com/sites/GIDCEEReportAutomation/Shared Documents/Reports/"]}[Content],
    #"Imported Excel Workbook" = Excel.Workbook(#"GIDC GRAD Tracker 8 September xlsx_https://dxcportal sharepoint com/sites/GIDCEEReportAutomation/Shared Documents/Reports/"),
    #"RAW DATA" = #"Imported Excel Workbook"{[Name="RAW DATA"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(#"RAW DATA", [PromoteAllScalars=true]),
    #"Removed Other Columns" = Table.SelectColumns(#"Promoted Headers",{"WMA", "Req No"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Removed Other Columns",{{"Req No", Int64.Type}}),
    #"Removed Errors" = Table.RemoveRowsWithErrors(#"Changed Type", {"Req No"})
in
    #"Removed Errors"

// LABOR PLAN

let
    Source = Excel.Workbook(Web.Contents("https://dxcportal.sharepoint.com/sites/GIDCEEReportAutomation/Shared%20Documents/Reports/Labor_Plan.xlsx"), null, true),
    #"Labor Plan_Sheet" = Source{[Item="Labor Plan",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(#"Labor Plan_Sheet", [PromoteAllScalars=true]),
    #"Removed Columns" = Table.RemoveColumns(#"Promoted Headers",{"SL"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"Labor Plan Q3 Hiring Plan", "1.10.2021"}, {"Labor Plan Q4 Hiring Plan", "1.1.2022"}}),
    #"Reordered Columns" = Table.ReorderColumns(#"Renamed Columns",{"Country", "L4_ID", "1.10.2021", "1.1.2022"}),
    #"Unpivoted Columns" = Table.UnpivotOtherColumns(#"Reordered Columns", {"L4_ID", "Country"}, "HireOffer_StartDate", "Count_of_Reqs"),
    #"Changed Type" = Table.TransformColumnTypes(#"Unpivoted Columns",{{"Count_of_Reqs", Int64.Type}, {"HireOffer_StartDate", type date}, {"L4_ID", Int64.Type}}),
    #"Added Custom" = Table.AddColumn(#"Changed Type", "Requisition Status", each "Labor Plan")
in
    #"Added Custom"

// EMEA GEO REPORT v_1

let
    Source = SharePoint.Files("https://dxcportal.sharepoint.com/sites/GIDCEEReportAutomation", [ApiVersion = 15]),
    #"EMEA GEO report 8 September xlsx_https://dxcportal sharepoint com/sites/GIDCEEReportAutomation/Shared Documents/Reports/" = Source{[Name="EMEA_GEO_Report.xlsx",#"Folder Path"="https://dxcportal.sharepoint.com/sites/GIDCEEReportAutomation/Shared Documents/Reports/"]}[Content],
    #"Imported Excel Workbook" = Excel.Workbook(#"EMEA GEO report 8 September xlsx_https://dxcportal sharepoint com/sites/GIDCEEReportAutomation/Shared Documents/Reports/"),
    Sheet1_Sheet = #"Imported Excel Workbook"{[Item="Export",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(Sheet1_Sheet, [PromoteAllScalars=true]),
    RemovedColumns2 = Table.SelectColumns(#"Promoted Headers",{"Report Date", "Requisition Number", "Req Offer Status", "Job Profile", "Req Posting Recommendation", "PPMC Position ID (Demand ID)", "Hiring Manager", "Hiring Manager EID", "HM L4 Mngr Name", "Latest Filled Date", "P&L Org L1", "WMA ID", "Job Type", "Target Hire Date Proposed", "Revised Target Hire Date Proposed", "Inbound Staffing Process Completed", "Requisition Status", "Country"}),
    MergedQueriesGradTracker = Table.NestedJoin(RemovedColumns2, {"WMA ID"}, GIDC_Grad_Tracker, {"WMA"}, "GradTracker", JoinKind.LeftAnti),
    #"Split Column by Character Transition" = Table.SplitColumn(MergedQueriesGradTracker, "HM L4 Mngr Name", Splitter.SplitTextByCharacterTransition((c) => not List.Contains({"0".."9"}, c), {"0".."9"}), {"HM L4 Mngr Name.1", "L4"}),
    #"Split Column by Character Transition1" = Table.SplitColumn(#"Split Column by Character Transition", "L4", Splitter.SplitTextByCharacterTransition({"0".."9"}, (c) => not List.Contains({"0".."9"}, c)), {"L4.1", "L4.2"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Split Column by Character Transition1",{{"L4.1", Int64.Type}}),
    #"Added Custom" = Table.AddColumn(#"Changed Type", "L4_ID", each if [L4.1] = "" then [Hiring Manager EID] else [L4.1], type text),
    #"Removed Columns" = Table.RemoveColumns(#"Added Custom",{"L4.2", "L4.1", "HM L4 Mngr Name.1"}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Removed Columns",{{"L4_ID", Int64.Type}}),
    FilteredMultipleFilters = Table.SelectRows(#"Changed Type1", each 
                                    (
                                        [Country] = "Bulgaria" or [Country] = "Poland" or [Country] = "Slovakia"
                                    ) and
                                    (
                                        [Job Type] <> "Graduate Job"                                                      
                                    ) and
                                    (
                                        [Job Profile] <> "00442D - Graduate Development Program"
                                    ) and
                                    (
                                        [Requisition Status] = "Open" or
                                        [Requisition Status] = "Filled"
                                    ) and
                                    (
                                        [Hiring Manager EID] = 20001326 or [L4_ID] = 20001326 or
                                        [Hiring Manager EID] = 21680395 or [L4_ID] = 21680395 or
                                        [Hiring Manager EID] = 20255800 or [L4_ID] = 20255800 or
                                        [Hiring Manager EID] = 11701587 or [L4_ID] = 11701587 or
                                        [Hiring Manager EID] = 21393104 or [L4_ID] = 21393104 or
                                        [Hiring Manager EID] = 20059961 or [L4_ID] = 20059961 or
                                        [Hiring Manager EID] = 11574889 or [L4_ID] = 11574889 or
                                        [Hiring Manager EID] = 11705657 or [L4_ID] = 11705657 or
                                        [Hiring Manager EID] = 21458596 or [L4_ID] = 21458596
                                    )
                                    ),
    FilteredReqContainsExternal = Table.SelectRows(FilteredMultipleFilters, each Text.Contains([Req Posting Recommendation], "External")),
    AddedLatestFilledDateFiscalYr = Table.AddColumn(FilteredReqContainsExternal, "Latest_Filled_Date_FiscalYr", each #"Get FY"([Latest Filled Date], 3), Int64.Type),
    AddedCurrentFiscalYr = Table.AddColumn(AddedLatestFilledDateFiscalYr, "CurrentFiscalYr", each #"Get FY"([Report Date], 3), Int64.Type),
    AddedLatestFilledDate_IsCurrentFY = Table.AddColumn(AddedCurrentFiscalYr, "LatestFilledDate_IsCurrentFY", each Value.Equals([Latest_Filled_Date_FiscalYr], [CurrentFiscalYr]), type logical),
    FilteredFilledOpen = Table.SelectRows(AddedLatestFilledDate_IsCurrentFY, each (
                                    (
                                    [LatestFilledDate_IsCurrentFY] = true and 
                                        [Requisition Status] = "Filled" and
                                            (Text.Contains([Inbound Staffing Process Completed], "Hire") or Text.Contains([Inbound Staffing Process Completed], "masked"))
                                    ) or 
                                    [Requisition Status] = "Open")
                                ),
    AddedHireOffer_StartDate = Table.AddColumn(FilteredFilledOpen, "HireOffer_StartDate", each 
                                    if  [Requisition Status] = "Filled"
                                        then [Latest Filled Date]
                                    else
                                        if ([Requisition Status] = "Open" and ([Req Offer Status] = "Offer Accepted" or [Req Offer Status] = "Offer Extended"))
                                        then   
                                            if [Latest Filled Date] <> null then [Latest Filled Date]
                                            else if [Revised Target Hire Date Proposed] <> null then [Revised Target Hire Date Proposed]
                                            else if [Revised Target Hire Date Proposed] = null then [Target Hire Date Proposed]
                                            else null
                                    else
                                    null,
                                    type date
                                    ),
    #"Replaced Value" = Table.ReplaceValue(AddedHireOffer_StartDate," Accepted","",Replacer.ReplaceText,{"Req Offer Status"}),
    #"Replaced Value1" = Table.ReplaceValue(#"Replaced Value"," Extended","",Replacer.ReplaceText,{"Req Offer Status"}),
    #"Grouped Rows" = Table.Group(#"Replaced Value1", {"Country", "Requisition Status", "Req Offer Status", "L4_ID", "HireOffer_StartDate", "Report Date"}, {{"Count_of_Reqs", each Table.RowCount(_), Int64.Type}}),
    #"Merged Columns" = Table.CombineColumns(#"Grouped Rows",{"Requisition Status", "Req Offer Status"},Combiner.CombineTextByDelimiter(" ", QuoteStyle.None),"Requisition Status"),
    #"Appended Query" = Table.Combine({#"Merged Columns", Labor_Plan}),
    AddQuarter = Table.AddColumn(#"Appended Query", "Quarter", each 
                                                    if [HireOffer_StartDate] = null then "No HireOffer Date"
                                                    else if Date.IsInCurrentQuarter([HireOffer_StartDate]) then "Current Q"
                                                    else if Date.IsInPreviousQuarter([HireOffer_StartDate]) then "Current -1 Q"
                                                    else if Date.IsInNextQuarter([HireOffer_StartDate]) then "Current +1 Q"
                                                    else if Date.IsInPreviousNQuarters([HireOffer_StartDate], 3) and not Date.IsInPreviousQuarter([HireOffer_StartDate]) then "Current -2 Q"
                                                    else "Other Q",
                                                    type text)
in
    AddQuarter

// EMEA_GEO_Report v_2

let
    Source = SharePoint.Files("https://dxcportal.sharepoint.com/sites/GIDCEEReportAutomation", [ApiVersion = 15]),
    #"EMEA GEO report 8 September xlsx_https://dxcportal sharepoint com/sites/GIDCEEReportAutomation/Shared Documents/Reports/" = Source{[Name="EMEA_GEO_Report.xlsx",#"Folder Path"="https://dxcportal.sharepoint.com/sites/GIDCEEReportAutomation/Shared Documents/Reports/"]}[Content],
    #"Imported Excel Workbook" = Excel.Workbook(#"EMEA GEO report 8 September xlsx_https://dxcportal sharepoint com/sites/GIDCEEReportAutomation/Shared Documents/Reports/"),
    Sheet1_Sheet = #"Imported Excel Workbook"{[Item="Export",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(Sheet1_Sheet, [PromoteAllScalars=true]),
    RemovedColumns2 = Table.SelectColumns(#"Promoted Headers",{"Report Date", "Requisition Number", "Req Offer Status", "Job Profile", "Req Posting Recommendation", "PPMC Position ID (Demand ID)", "Hiring Manager", "Hiring Manager EID", "HM L4 Mngr Name", "Latest Filled Date", "P&L Org L1", "WMA ID", "Job Type", "Target Hire Date Proposed", "Revised Target Hire Date Proposed", "Inbound Staffing Process Completed", "Requisition Status", "Country"}),
    MergedQueriesGradTracker = Table.NestedJoin(RemovedColumns2, {"WMA ID"}, GIDC_Grad_Tracker, {"WMA"}, "GradTracker", JoinKind.LeftAnti),
    #"Split Column by Character Transition" = Table.SplitColumn(MergedQueriesGradTracker, "HM L4 Mngr Name", Splitter.SplitTextByCharacterTransition((c) => not List.Contains({"0".."9"}, c), {"0".."9"}), {"HM L4 Mngr Name.1", "L4"}),
    #"Split Column by Character Transition1" = Table.SplitColumn(#"Split Column by Character Transition", "L4", Splitter.SplitTextByCharacterTransition({"0".."9"}, (c) => not List.Contains({"0".."9"}, c)), {"L4.1", "L4.2"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Split Column by Character Transition1",{{"L4.1", Int64.Type}}),
    #"Added Custom" = Table.AddColumn(#"Changed Type", "L4_ID", each if [L4.1] = "" then [Hiring Manager EID] else [L4.1], type text),
    #"Removed Columns" = Table.RemoveColumns(#"Added Custom",{"L4.2", "L4.1", "HM L4 Mngr Name.1"}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Removed Columns",{{"L4_ID", Int64.Type}}),
    FilteredMultipleFilters = Table.SelectRows(#"Changed Type1", each 
                                    (
                                        [Country] = "Bulgaria" or [Country] = "Poland" or [Country] = "Slovakia"
                                    ) and
                                    (
                                        [Job Type] <> "Graduate Job"                                                      
                                    ) and
                                    (
                                        [Job Profile] <> "00442D - Graduate Development Program"
                                    ) and
                                    (
                                        [Requisition Status] = "Open" or
                                        [Requisition Status] = "Filled" or 
                                        [Requisition Status] = "Closed"
                                    ) and
                                    (
                                        [Hiring Manager EID] = 20001326 or [L4_ID] = 20001326 or
                                        [Hiring Manager EID] = 21680395 or [L4_ID] = 21680395 or
                                        [Hiring Manager EID] = 20255800 or [L4_ID] = 20255800 or
                                        [Hiring Manager EID] = 11701587 or [L4_ID] = 11701587 or
                                        [Hiring Manager EID] = 21393104 or [L4_ID] = 21393104 or
                                        [Hiring Manager EID] = 20059961 or [L4_ID] = 20059961 or
                                        [Hiring Manager EID] = 11574889 or [L4_ID] = 11574889 or
                                        [Hiring Manager EID] = 11705657 or [L4_ID] = 11705657 or
                                        [Hiring Manager EID] = 21458596 or [L4_ID] = 21458596
                                    )
                                    ),
    FilteredReqContainsExternal = Table.SelectRows(FilteredMultipleFilters, each Text.Contains([Req Posting Recommendation], "External")),
    AddedLatestFilledDateFiscalYr = Table.AddColumn(FilteredReqContainsExternal, "Latest_Filled_Date_FiscalYr", each #"Get FY"([Latest Filled Date], 3), Int64.Type),
    AddedCurrentFiscalYr = Table.AddColumn(AddedLatestFilledDateFiscalYr, "CurrentFiscalYr", each #"Get FY"([Report Date], 3), Int64.Type),
    AddedLatestFilledDate_IsCurrentFY = Table.AddColumn(AddedCurrentFiscalYr, "LatestFilledDate_IsCurrentFY", each Value.Equals([Latest_Filled_Date_FiscalYr], [CurrentFiscalYr]), type logical),
    FilteredFilledOpenClosed = Table.SelectRows(AddedLatestFilledDate_IsCurrentFY, each (
                                    (
                                    [LatestFilledDate_IsCurrentFY] = true and 
                                        [Requisition Status] = "Filled" and
                                            (Text.Contains([Inbound Staffing Process Completed], "Hire") or Text.Contains([Inbound Staffing Process Completed], "masked"))
                                    ) 
                                    or 
                                    [Requisition Status] = "Open"
                                    or
                                    [Requisition Status] = "Closed"
                                    )
                                ),
    AddedHireOffer_StartDate = Table.AddColumn(FilteredFilledOpen, "HireOffer_StartDate", each 
                                    if  [Requisition Status] = "Filled"
                                        then [Latest Filled Date]
                                    else
                                        if ([Requisition Status] = "Open" and ([Req Offer Status] = "Offer Accepted" or [Req Offer Status] = "Offer Extended"))
                                        then   
                                            if [Latest Filled Date] <> null then [Latest Filled Date]
                                            else if [Revised Target Hire Date Proposed] <> null then [Revised Target Hire Date Proposed]
                                            else if [Revised Target Hire Date Proposed] = null then [Target Hire Date Proposed]
                                            else null
                                    else
                                    null,
                                    type date
                                    ),
    #"Replaced Value" = Table.ReplaceValue(AddedHireOffer_StartDate," Accepted","",Replacer.ReplaceText,{"Req Offer Status"}),
    #"Replaced Value1" = Table.ReplaceValue(#"Replaced Value"," Extended","",Replacer.ReplaceText,{"Req Offer Status"}),
    #"Grouped Rows" = Table.Group(#"Replaced Value1", {"Country", "Requisition Status", "Req Offer Status", "L4_ID", "HireOffer_StartDate", "Report Date"}, {{"Count_of_Reqs", each Table.RowCount(_), Int64.Type}}),
    #"Merged Columns" = Table.CombineColumns(#"Grouped Rows",{"Requisition Status", "Req Offer Status"},Combiner.CombineTextByDelimiter(" ", QuoteStyle.None),"Requisition Status"),
    #"Appended Query" = Table.Combine({#"Merged Columns", Labor_Plan}),
    AddQuarter = Table.AddColumn(#"Appended Query", "Quarter", each 
                                                    if [HireOffer_StartDate] = null then "No HireOffer Date"
                                                    else if Date.IsInCurrentQuarter([HireOffer_StartDate]) then "Current Q"
                                                    else if Date.IsInPreviousQuarter([HireOffer_StartDate]) then "Current -1 Q"
                                                    else if Date.IsInNextQuarter([HireOffer_StartDate]) then "Current +1 Q"
                                                    else if Date.IsInPreviousNQuarters([HireOffer_StartDate], 3) and not Date.IsInPreviousQuarter([HireOffer_StartDate]) then "Current -2 Q"
                                                    else "Other Q",
                                                    type text)
in
    AddQuarter

// EMEA GEO REPORT v.3

let
    Source = SharePoint.Files("https://dxcportal.sharepoint.com/sites/GIDCEEReportAutomation", [ApiVersion = 15]),
    #"EMEA GEO report 8 September xlsx_https://dxcportal sharepoint com/sites/GIDCEEReportAutomation/Shared Documents/Reports/" = Source{[Name="EMEA_GEO_Report.xlsx",#"Folder Path"="https://dxcportal.sharepoint.com/sites/GIDCEEReportAutomation/Shared Documents/Reports/"]}[Content],
    #"Imported Excel Workbook" = Excel.Workbook(#"EMEA GEO report 8 September xlsx_https://dxcportal sharepoint com/sites/GIDCEEReportAutomation/Shared Documents/Reports/"),
    Sheet1_Sheet = #"Imported Excel Workbook"{[Item="Export",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(Sheet1_Sheet, [PromoteAllScalars=true]),
    RemovedColumns2 = Table.SelectColumns(#"Promoted Headers",{"Report Date", "Requisition Number", "Req Offer Status", "Job Profile", "Req Posting Recommendation", "PPMC Position ID (Demand ID)", "Hiring Manager", "Hiring Manager EID", "HM L4 Mngr Name", "Latest Filled Date", "P&L Org L1", "WMA ID", "Job Type", "Target Hire Date Proposed", "Revised Target Hire Date Proposed", "Inbound Staffing Process Completed", "Requisition Status", "Country"}),
    MergedQueriesGradTracker = Table.NestedJoin(RemovedColumns2, {"WMA ID"}, GIDC_Grad_Tracker, {"WMA"}, "GradTracker", JoinKind.LeftAnti),
    #"Split Column by Character Transition" = Table.SplitColumn(MergedQueriesGradTracker, "HM L4 Mngr Name", Splitter.SplitTextByCharacterTransition((c) => not List.Contains({"0".."9"}, c), {"0".."9"}), {"HM L4 Mngr Name.1", "L4"}),
    #"Split Column by Character Transition1" = Table.SplitColumn(#"Split Column by Character Transition", "L4", Splitter.SplitTextByCharacterTransition({"0".."9"}, (c) => not List.Contains({"0".."9"}, c)), {"L4.1", "L4.2"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Split Column by Character Transition1",{{"L4.1", Int64.Type}, {"Hiring Manager EID", Int64.Type}}),
    AddedL4ID = Table.AddColumn(#"Changed Type", "L4_ID", each if [L4.1] = null then [Hiring Manager EID] else [L4.1]),
    #"Removed Columns" = Table.RemoveColumns(AddedL4ID,{"L4.2", "L4.1", "HM L4 Mngr Name.1"}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Removed Columns",{{"L4_ID", Int64.Type}, {"Hiring Manager EID", Int64.Type}}),
    FilteredMultipleFilters = Table.SelectRows(#"Changed Type1", each 
                                    (
                                        [Country] = "Bulgaria" or [Country] = "Poland" or [Country] = "Slovakia"
                                    ) and
                                    (
                                        [Job Type] <> "Graduate Job"                                                      
                                    ) and
                                    (
                                        [Job Profile] <> "00442D - Graduate Development Program"
                                    ) and
                                    (
                                        [Requisition Status] = "Open" or
                                        [Requisition Status] = "Filled" or 
                                        [Requisition Status] = "Closed"
                                    ) and
                                    (
                                        [Hiring Manager EID] = 20001326 or [L4_ID] = 20001326 or
                                        [Hiring Manager EID] = 21680395 or [L4_ID] = 21680395 or
                                        [Hiring Manager EID] = 20255800 or [L4_ID] = 20255800 or
                                        [Hiring Manager EID] = 11701587 or [L4_ID] = 11701587 or
                                        [Hiring Manager EID] = 21393104 or [L4_ID] = 21393104 or
                                        [Hiring Manager EID] = 20059961 or [L4_ID] = 20059961 or
                                        [Hiring Manager EID] = 20010813 or [L4_ID] = 20010813 or
                                        [Hiring Manager EID] = 11705657 or [L4_ID] = 11705657 or
                                        [Hiring Manager EID] = 21458596 or [L4_ID] = 21458596
                                    )
                                    ),
    FilteredReqContainsExternal = Table.SelectRows(FilteredMultipleFilters, each Text.Contains([Req Posting Recommendation], "External")),
    AddedLatestFilledDateFiscalYr = Table.AddColumn(FilteredReqContainsExternal, "Latest_Filled_Date_FiscalYr", each #"Get FY"([Latest Filled Date], 3), Int64.Type),
    AddedCurrentFiscalYr = Table.AddColumn(AddedLatestFilledDateFiscalYr, "CurrentFiscalYr", each #"Get FY"([Report Date], 3), Int64.Type),
    AddedLatestFilledDate_IsCurrentFY = Table.AddColumn(AddedCurrentFiscalYr, "LatestFilledDate_IsCurrentFY", each Value.Equals([Latest_Filled_Date_FiscalYr], [CurrentFiscalYr]), type logical),
    FilteredFilledOpenClosed = Table.SelectRows(AddedLatestFilledDate_IsCurrentFY, each (
                                    (
                                    [LatestFilledDate_IsCurrentFY] = true and 
                                        [Requisition Status] = "Filled" and
                                            (Text.Contains([Inbound Staffing Process Completed], "Hire") or Text.Contains([Inbound Staffing Process Completed], "masked"))
                                    ) 
                                    or 
                                    [Requisition Status] = "Open"
                                    or
                                    [Requisition Status] = "Closed"
                                    )
                                ),
    AddedHireOffer_StartDate = Table.AddColumn(FilteredFilledOpenClosed, "HireOffer_StartDate", each 
                                    if  [Requisition Status] = "Filled"
                                        then [Latest Filled Date]
                                    else
                                        if ([Requisition Status] = "Open" and ([Req Offer Status] = "Offer Accepted" or [Req Offer Status] = "Offer Extended"))
                                        then   
                                            if [Latest Filled Date] <> null then [Latest Filled Date]
                                            else if [Revised Target Hire Date Proposed] <> null then [Revised Target Hire Date Proposed]
                                            else if [Revised Target Hire Date Proposed] = null then [Target Hire Date Proposed]
                                            else null
                                    else
                                    null,
                                    type date
                                    ),
    #"Replaced Value" = Table.ReplaceValue(AddedHireOffer_StartDate," Accepted","",Replacer.ReplaceText,{"Req Offer Status"}),
    #"Replaced Value1" = Table.ReplaceValue(#"Replaced Value"," Extended","",Replacer.ReplaceText,{"Req Offer Status"}),
    #"Grouped Rows" = Table.Group(#"Replaced Value1", {"Country", "Requisition Status", "Req Offer Status", "L4_ID", "HireOffer_StartDate", "Report Date"}, {{"Count_of_Reqs", each Table.RowCount(_), Int64.Type}}),
    #"Merged Columns" = Table.CombineColumns(#"Grouped Rows",{"Requisition Status", "Req Offer Status"},Combiner.CombineTextByDelimiter(" ", QuoteStyle.None),"Requisition Status"),
    #"Appended Query" = Table.Combine({#"Merged Columns", Labor_Plan}),
    AddQuarter = Table.AddColumn(#"Appended Query", "Quarter", each 
                                                    if [HireOffer_StartDate] = null then "No HireOffer Date"
                                                    else if Date.IsInCurrentQuarter([HireOffer_StartDate]) then "Current Q"
                                                    else if Date.IsInPreviousQuarter([HireOffer_StartDate]) then "Current -1 Q"
                                                    else if Date.IsInNextQuarter([HireOffer_StartDate]) then "Current +1 Q"
                                                    else if Date.IsInPreviousNQuarters([HireOffer_StartDate], 3) and not Date.IsInPreviousQuarter([HireOffer_StartDate]) then "Current -2 Q"
                                                    else "Other Q",
                                                    type text)
in
    AddQuarter

// EXPORT TABLE

    let
    Source = SharePoint.Files("https://dxcportal.sharepoint.com/sites/GIDCEEReportAutomation", [ApiVersion = 15]),
    #"EMEA GEO report 8 September xlsx_https://dxcportal sharepoint com/sites/GIDCEEReportAutomation/Shared Documents/Reports/" = Source{[Name="EMEA_GEO_Report.xlsx",#"Folder Path"="https://dxcportal.sharepoint.com/sites/GIDCEEReportAutomation/Shared Documents/Reports/"]}[Content],
    #"Imported Excel Workbook" = Excel.Workbook(#"EMEA GEO report 8 September xlsx_https://dxcportal sharepoint com/sites/GIDCEEReportAutomation/Shared Documents/Reports/"),
    Sheet1_Sheet = #"Imported Excel Workbook"{[Item="Export",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(Sheet1_Sheet, [PromoteAllScalars=true]),
    RemovedColumns2 = Table.SelectColumns(#"Promoted Headers",{"Age", "Age Group", "Candidate ID", "Candidate Is Internal", "Candidate Source", "City", "Client Project Name (*Workday)", "Country", "DXC Job Levels", "Employee Hire Date", "Employee ID", "First Name", "Hiring Manager", "Hiring Manager EID", "Hiring Manager Supervisor Name", "HM L1 Mngr Name", "HM L2 Mngr Name", "HM L3 Mngr Name", "HM L4 Mngr Name", "HM L5 Mngr Name", "Inbound Staffing Process Completed", "Job Application Source", "Job Code", "Job Profile", "Job Type", "Last Name", "Latest Filled Date", "Latest Offer Accepted", "Latest Offer Extended", "Major Offering (*PPMC)", "Management Level", "Number Candidates Accepted", "Number Candidates Offered ALL", "Offer Accepted Date", "Offer Extended date", "P&L Org L3", "P&L Region L1", "Position Status (WPN)", "PPMC Position ID (Demand ID)", "Primary Recruiter Name", "Reason Position Needed", "reasonDetail", "Report Date", "Req Creation Date", "Req Legacy Company", "Req Offer Status", "Req Posting Recommendation", "Requisition Number", "Requisition Posting Title", "Requisition Status", "Revised Target Hire Date Proposed", "Submission Is Internal", "Target Hire Date Proposed", "Target Start Date", "Technology Stack", "WMA ID", "WMA Req Position Reason"}),
    MergedQueriesGradTracker = Table.NestedJoin(RemovedColumns2, {"WMA ID"}, GIDC_Grad_Tracker, {"WMA"}, "GradTracker", JoinKind.LeftAnti),
    #"Split Column by Character Transition" = Table.SplitColumn(MergedQueriesGradTracker, "HM L4 Mngr Name", Splitter.SplitTextByCharacterTransition((c) => not List.Contains({"0".."9"}, c), {"0".."9"}), {"HM L4 Mngr Name.1", "L4"}),
    #"Split Column by Character Transition1" = Table.SplitColumn(#"Split Column by Character Transition", "L4", Splitter.SplitTextByCharacterTransition({"0".."9"}, (c) => not List.Contains({"0".."9"}, c)), {"L4.1", "L4.2"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Split Column by Character Transition1",{{"L4.1", Int64.Type}, {"Hiring Manager EID", Int64.Type}}),
    AddedL4ID = Table.AddColumn(#"Changed Type", "L4_ID", each if [L4.1] = null then [Hiring Manager EID] else [L4.1]),
    #"Removed Columns" = Table.RemoveColumns(AddedL4ID,{"L4.2", "L4.1", "HM L4 Mngr Name.1"}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Removed Columns",{{"L4_ID", Int64.Type}}),
    FilteredMultipleFilters = Table.SelectRows(#"Changed Type1", each 
                                    (
                                        [Country] = "Bulgaria" or [Country] = "Poland" or [Country] = "Slovakia"
                                    ) and
                                    (
                                        [Job Type] <> "Graduate Job"                                                      
                                    ) and
                                    (
                                        [Job Profile] <> "00442D - Graduate Development Program"
                                    ) and
                                    (
                                        [Requisition Status] = "Open" or
                                        [Requisition Status] = "Filled" or 
                                        [Requisition Status] = "Closed"
                                    ) and
                                    (
                                        [Hiring Manager EID] = 20001326 or [L4_ID] = 20001326 or
                                        [Hiring Manager EID] = 21680395 or [L4_ID] = 21680395 or
                                        [Hiring Manager EID] = 20255800 or [L4_ID] = 20255800 or
                                        [Hiring Manager EID] = 11701587 or [L4_ID] = 11701587 or
                                        [Hiring Manager EID] = 21393104 or [L4_ID] = 21393104 or
                                        [Hiring Manager EID] = 20059961 or [L4_ID] = 20059961 or
                                        [Hiring Manager EID] = 11574889 or [L4_ID] = 11574889 or
                                        [Hiring Manager EID] = 11705657 or [L4_ID] = 11705657 or
                                        [Hiring Manager EID] = 21458596 or [L4_ID] = 21458596
                                    )
                                    ),
    FilteredReqContainsExternal = Table.SelectRows(FilteredMultipleFilters, each Text.Contains([Req Posting Recommendation], "External")),
    AddedLatestFilledDateFiscalYr = Table.AddColumn(FilteredReqContainsExternal, "Latest_Filled_Date_FiscalYr", each #"Get FY"([Latest Filled Date], 3), Int64.Type),
    AddedCurrentFiscalYr = Table.AddColumn(AddedLatestFilledDateFiscalYr, "CurrentFiscalYr", each #"Get FY"([Report Date], 3), Int64.Type),
    AddedLatestFilledDate_IsCurrentFY = Table.AddColumn(AddedCurrentFiscalYr, "LatestFilledDate_IsCurrentFY", each Value.Equals([Latest_Filled_Date_FiscalYr], [CurrentFiscalYr]), type logical),
    FilteredFilledOpenClosed = Table.SelectRows(AddedLatestFilledDate_IsCurrentFY, each (
                                    (
                                    [LatestFilledDate_IsCurrentFY] = true and 
                                        [Requisition Status] = "Filled" and
                                            (Text.Contains([Inbound Staffing Process Completed], "Hire") or Text.Contains([Inbound Staffing Process Completed], "masked"))
                                    ) or 
                                    [Requisition Status] = "Open") or
                                    [Requisition Status] = "Closed"
                                ),
    AddedHireOffer_StartDate = Table.AddColumn(FilteredFilledOpenClosed, "HireOffer_StartDate", each 
                                    if  [Requisition Status] = "Filled"
                                        then [Latest Filled Date]
                                    else
                                        if ([Requisition Status] = "Open" and ([Req Offer Status] = "Offer Accepted" or [Req Offer Status] = "Offer Extended"))
                                        then   
                                            if [Latest Filled Date] <> null then [Latest Filled Date]
                                            else if [Revised Target Hire Date Proposed] <> null then [Revised Target Hire Date Proposed]
                                            else if [Revised Target Hire Date Proposed] = null then [Target Hire Date Proposed]
                                            else null
                                    else
                                    null,
                                    type date
                                    ),
    InsertFiscalYear = Table.AddColumn(AddedHireOffer_StartDate, "FiscalYear", each #"Get FY"([HireOffer_StartDate], 3)),
    InsertFiscalQuarter = Table.AddColumn(InsertFiscalYear, "FiscalQuarter", each try  #"Get Fiscal Qtr"([HireOffer_StartDate], 3) otherwise null),
    InsertFiscalYrQuarter = Table.AddColumn(InsertFiscalQuarter, "FiscalQuarterYear", each [FiscalQuarter] & " " & [FiscalYear]),
    #"Merged Queries" = Table.NestedJoin(InsertFiscalYrQuarter, {"L4_ID"}, L4_Services, {"L4_ID"}, "L4_Services", JoinKind.LeftOuter),
    #"Expanded L4_Services" = Table.ExpandTableColumn(#"Merged Queries", "L4_Services", {"L4_Service"}, {"Service"}),
    RemoveColumns = Table.RemoveColumns(#"Expanded L4_Services", {"L4_ID", "GradTracker", "Latest_Filled_Date_FiscalYr", "CurrentFiscalYr", "LatestFilledDate_IsCurrentFY", "Report Date", "Revised Target Hire Date Proposed"})
in
    RemoveColumns