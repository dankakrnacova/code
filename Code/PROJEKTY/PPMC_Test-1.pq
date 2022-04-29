// PPMC  One report
let
    Source = Excel.Workbook(File.Contents("C:\Users\dkrnacova\OneDrive - DXC Production\Documents\Internal\PPMC\Azure\DXC_Resource_Allocation_and_Availability_from_16_March_2022_vs_HCs_GIDC_EE_L4s.xlsx"), null, true),
    Data_Sheet = Source{[Item="Data",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(Data_Sheet, [PromoteAllScalars=true]),
    #"Filtered Rows Peter Mrazik" = Table.SelectRows(#"Promoted Headers", each ([OrgUnit4 Email] = "peter.mrazik@dxc.com")),
    #"Removed Columns" = Table.RemoveColumns(#"Filtered Rows Peter Mrazik",{"L4"}),
    #"Changed Type Date>Int" = Table.TransformColumnTypes(#"Removed Columns",{{"Latest Assignment Start Date", Int64.Type}, {"Latest Assignment End Date", Int64.Type}, {"Latest Position End Date", Int64.Type}, {"Position Start Date", Int64.Type}, {"Column94", Int64.Type}, {"Position Create Date", Int64.Type}}),
    #"Added Custom > Position End Date" = Table.AddColumn(#"Changed Type Date>Int", "Latest_Position_End_Date", each Date.From([Latest Position End Date])),
    #"Added Custom > Assign End Date" = Table.AddColumn(#"Added Custom > Position End Date", "Latest_Assignment_End_Date", each Date.From([Latest Assignment End Date])),
    #"Added Custom > Assign Start Date" = Table.AddColumn(#"Added Custom > Assign End Date", "Latest_Assignment_Start_Date", each Date.From([Latest Assignment Start Date])),
    #"Added Custom > Pos Start Date" = Table.AddColumn(#"Added Custom > Assign Start Date", "Position_Start_Date", each Date.From([Position Start Date])),
    #"Added Custom > Last Update" = Table.AddColumn(#"Added Custom > Pos Start Date", "Last_Update", each Date.From([Column94])),
    #"Added Custom > Pos Create Date" = Table.AddColumn(#"Added Custom > Last Update", "Position_Create_Date", each Date.From([Position Create Date])),
    #"Removed Other Columns" = Table.SelectColumns(#"Added Custom > Pos Create Date",{"EID", "Position ID", "PLM ID", "Availability", "Allocation %", "PPM Account Roll-Off", "Financial Client", "Financial Client ID", "Demand Type", "Last Billable Type", "Max of Position Job Level", "Sum of Current Month -3", "Sum of Current Month -2", "Sum of Current Month -1", "Sum of Current Month", "Sum of Current Month +1", "Sum of Current Month +2", "Sum of Current Month +3", "Sum of Current Month +4", "Sum of Current Month +5", "Sum of Current Month +6", "Project Owning Country", "Project Name", "Primary Project Manager", "Last Primary_RB", "Position Name", "Position Service Offering", "Position Service Type", "Position_Start_Date", "Latest_Position_End_Date", "Latest_Assignment_End_Date", "Latest_Assignment_Start_Date", "New Client Name", "Last_Update"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Removed Other Columns",{{"EID", Int64.Type}, {"Position ID", Int64.Type}, {"PLM ID", Int64.Type}, {"Availability", type text}, {"Allocation %", type text}, {"PPM Account Roll-Off", type text}, {"Financial Client", type text}, {"Financial Client ID", Int64.Type}, {"Demand Type", type text}, {"Last Billable Type", type text}, {"Max of Position Job Level", Int64.Type}, {"Sum of Current Month -3", type number}, {"Sum of Current Month -2", type number}, {"Sum of Current Month -1", type number}, {"Sum of Current Month", type number}, {"Sum of Current Month +1", type number}, {"Sum of Current Month +2", type number}, {"Sum of Current Month +3", type number}, {"Sum of Current Month +4", type number}, {"Sum of Current Month +5", type number}, {"Sum of Current Month +6", type number}, {"Project Owning Country", type text}, {"Project Name", type text}, {"Primary Project Manager", type text}, {"Position Name", type text}, {"Last Primary_RB", type text},  {"Position Service Offering", type text}, {"Position Service Type", type text},  {"New Client Name", type text}, {"Last_Update", type date}, {"Latest_Position_End_Date", type date}, {"Latest_Assignment_End_Date", type date}, {"Latest_Assignment_Start_Date", type date}, {"Position_Start_Date", type date}}),
    #"Added Report Date" = Table.AddColumn(#"Changed Type", "Report_Date", each Date.FromText("16.3.2022")),
    #"Renamed Months in Columns" = Table.RenameColumns(#"Added Report Date", 
        {   
            {
                "Sum of Current Month -3", 
                let 
                    currentMonth =  Text.From(Date.AddMonths(Date.StartOfMonth(#"Added Report Date"[Report_Date]{1}), -3)) 
                in  currentMonth 
            },
            {
                "Sum of Current Month -2", 
                let 
                    currentMonth =  Text.From(Date.AddMonths(Date.StartOfMonth(#"Added Report Date"[Report_Date]{1}), -2)) 
                in  currentMonth 
            },
            {
                "Sum of Current Month -1", 
                let 
                    currentMonth =  Text.From(Date.AddMonths(Date.StartOfMonth(#"Added Report Date"[Report_Date]{1}), -1)) 
                in  currentMonth 
            },
            {
                "Sum of Current Month", 
                let 
                    currentMonth =  Text.From(Date.StartOfMonth(#"Added Report Date"[Report_Date]{1})) 
                in  currentMonth 
            },
            {
                "Sum of Current Month +1", 
                let 
                    currentMonth =  Text.From(Date.AddMonths(Date.StartOfMonth(#"Added Report Date"[Report_Date]{1}), +1)) 
                in  currentMonth 
            },
            {
                "Sum of Current Month +2", 
                let 
                    currentMonth =  Text.From(Date.AddMonths(Date.StartOfMonth(#"Added Report Date"[Report_Date]{1}), +2)) 
                in  currentMonth 
            },
            {
                "Sum of Current Month +3", 
                let 
                    currentMonth =  Text.From(Date.AddMonths(Date.StartOfMonth(#"Added Report Date"[Report_Date]{1}), +3)) 
                in  currentMonth 
            },
            {
                "Sum of Current Month +4", 
                let 
                    currentMonth =  Text.From(Date.AddMonths(Date.StartOfMonth(#"Added Report Date"[Report_Date]{1}), +4)) 
                in  currentMonth 
            },
            {
                "Sum of Current Month +5", 
                let 
                    currentMonth =  Text.From(Date.AddMonths(Date.StartOfMonth(#"Added Report Date"[Report_Date]{1}), +5)) 
                in  currentMonth 
            },
            {
                "Sum of Current Month +6", 
                let 
                    currentMonth =  Text.From(Date.AddMonths(Date.StartOfMonth(#"Added Report Date"[Report_Date]{1}), +6)) 
                in  currentMonth 
            }
        } 
    ),
    #"Unpivoted Other Columns" = Table.UnpivotOtherColumns(#"Renamed Months in Columns", {"EID", "Position ID", "PLM ID", "Availability", "Allocation %", "PPM Account Roll-Off", "Financial Client", "Financial Client ID", "Demand Type", "Last Billable Type", "Max of Position Job Level", "Project Owning Country", "Project Name", "Primary Project Manager", "Last Primary_RB", "Position Name", "Position Service Offering", "Position Service Type", "Position_Start_Date", "Latest_Position_End_Date", "Latest_Assignment_Start_Date", "Latest_Assignment_End_Date", "New Client Name", "Last_Update", "Report_Date"}, "Forecast_Date", "FTE")
in
    #"Unpivoted Other Columns"

// PPMC_ALL
let
    Source = Table.Combine({#"PPMC_Assign_W_2022-01-06", #"PPMC_Assign_W_2021-12-23", #"PPMC_Assign_W_2021-12-16"}),
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"Report_Date", type date}, {"Forecast_Date", type date},{"Position_Start_Date", type date}}),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"Position ID", "Position_ID"}, {"PLM ID", "PLM_ID"}, {"Allocation %", "Allocation_%"}, {"PPM Account Roll-Off", "PPM_Account_Roll-Off"}, {"Financial Client", "Financial_Client"}, {"Financial Client ID", "Financial_Client_ID"}, {"Demand Type", "Demand_Type"}, {"Last Billable Type", "Last_Billable_Type"}, {"Max of Position Job Level", "Max_Position_Job_Level"}, {"Project Owning Country", "Project_Owning_Country"}, {"Project Name", "Project_Name"}, {"Primary Project Manager", "Primary_Project_Manager"}, {"Last Primary_RB", "Last_Primary_RB"}, {"Position Name", "Position_Name"}, {"Position Service Offering", "Position_Service_Offering"}, {"Position Service Type", "Position_Service_Type"},{"New Client Name", "New_Client_Name"}}),
    #"Inserted Week of Year" = Table.AddColumn(#"Renamed Columns", "Week of Year", each Date.WeekOfYear([Report_Date]), Int64.Type),
    #"Inserted Year" = Table.AddColumn(#"Inserted Week of Year", "Year", each Date.Year([Report_Date]), Int64.Type),
    #"Inserted Month" = Table.AddColumn(#"Inserted Year", "Month_ReportDate", each Text.PadStart(Number.ToText(Date.Month([Report_Date])),2,"0")),
    #"Inserted WeekOfYearKey" = Table.AddColumn(#"Inserted Month", "WeekOfYearKey", each Text.Combine({Text.From([Year], "en-150"), Text.From([Week of Year], "en-150")}), type text),
    #"Inserted YearMonthKey_ReportDate" = Table.AddColumn(#"Inserted WeekOfYearKey", "YearMonthKey_ReportDate", each Text.Combine({Text.From([Year], "en-150"), Text.From([Month_ReportDate], "en-150")}), type text),
    #"Added Year_ForecastDate" = Table.AddColumn(#"Inserted YearMonthKey_ReportDate", "Year_ForecastDate", each Date.Year([Forecast_Date])),
    #"Added Month_ForecastDate" = Table.AddColumn(#"Added Year_ForecastDate", "Month_ForecastDate", each Text.PadStart(Number.ToText(Date.Month([Forecast_Date])),2,"0")),
    #"Added YearMonthKey_ForecastDate" = Table.AddColumn(#"Added Month_ForecastDate", "YearMonthKey_ForecastDate", each Text.Combine({Text.From([Year_ForecastDate], "en-150"), Text.From([Month_ForecastDate], "en-150")}), type text),
    #"Changed Type1" = Table.TransformColumnTypes(#"Added YearMonthKey_ForecastDate",{{"WeekOfYearKey", Int64.Type}, {"YearMonthKey_ForecastDate", Int64.Type}, {"YearMonthKey_ReportDate", Int64.Type}}),
    #"Position End > Assign Date" = Table.AddColumn(#"Changed Type1", "Position_End_>_Assign_Date", each [Latest_Position_End_Date] > [Latest_Assignment_End_Date]),
    #"Position End < Assign Date" = Table.AddColumn(#"Position End > Assign Date", "Position_End_<_Assign_Date", each [Latest_Position_End_Date] < [Latest_Assignment_End_Date]),
    #"Position End = Assign Date" = Table.AddColumn(#"Position End < Assign Date", "Position_End_=_Assign_Date", each [Latest_Position_End_Date] = [Latest_Assignment_End_Date]),
    #"Replaced New Client Name" = Table.ReplaceValue(#"Position End = Assign Date","New Client", each "New Client: " & " " & Text.From([New_Client_Name]), Replacer.ReplaceText,{"Financial_Client"}),
    #"Added IsInPrevCurrNext_Month" = Table.AddColumn(#"Replaced New Client Name", "Forecast_IsIn_PrevCurrNext_Month", each 
                                                                                                                            if (
                                                                                                                            Date.IsInNextMonth([Forecast_Date]) or 
                                                                                                                            Date.IsInPreviousMonth([Forecast_Date]) or  
                                                                                                                            Date.IsInCurrentMonth([Forecast_Date]))
                                                                                                                            then "True"
                                                                                                                            else "False"
                                                                                                                            )
in
    #"Added IsInPrevCurrNext_Month"