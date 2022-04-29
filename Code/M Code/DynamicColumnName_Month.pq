// Date Now
let
    Source = Excel.Workbook(File.Contents("C:\Users\dkrnacova\OneDrive - DXC Production\Documents\Internal\PPMC\DXC_Resource_Allocation_and_Availability_from_03_JUNE_2021_vs_HCs_GIDC_EE_L4s.xlsb"), null, true),
    Data1 = Source{[Name="Data"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(Data1, [PromoteAllScalars=true]),
    #"Replaced Value Decimal" = Table.ReplaceValue(#"Promoted Headers",",",".",Replacer.ReplaceText,{"Sum of Current Month -1", "Sum of Current Month", "Sum of Current Month +1", "Sum of Current Month +2", "Sum of Current Month +3", "Sum of Current Month +4", "Sum of Current Month +5", "Sum of Current Month +6"}),
    #"Changed Type Date>Int" = Table.TransformColumnTypes(#"Replaced Value Decimal",{{"Latest Assignment End Date", Int64.Type}, {"Latest Position End Date", Int64.Type}}),
    #"Added Custom > Position Date" = Table.AddColumn(#"Changed Type Date>Int", "Latest_Position_End_Date", each Date.From([Latest Position End Date])),
    #"Added Custom > Assign Date" = Table.AddColumn(#"Added Custom > Position Date", "Latest_Assignment_End_Date", each Date.From([Latest Assignment End Date])),
    #"Added Custom > Report Week" = Table.AddColumn(#"Added Custom > Assign Date", "Report_Week", each "3.6.2021"),
    #"Changed Type" = Table.TransformColumnTypes(#"Added Custom > Report Week",{{"L4", type text}, {"EID", Int64.Type}, {"Position ID", Int64.Type}, {"PLM ID", Int64.Type}, {"Emp Name", type text}, {"Emp Email", type text}, {"Emp Type", type text}, {"Last Employee_Status", type text}, {"Availability", type text}, {"Allocation %", type text}, {"PPM Account Roll-Off", type text}, {"Financial Client", type text}, {"Financial Client ID", Int64.Type}, {"Demand Type", type text}, {"Last Billable Type", type text}, {"Max of Position Job Level", Int64.Type}, {"Position Create Date", Int64.Type}, {"Position Start Date", Int64.Type}, {"Latest Position End Date", Int64.Type}, {"Latest Assignment Create Date", Int64.Type}, {"Latest Assignment Start Date", Int64.Type}, {"Latest Assignment End Date", Int64.Type}, {"Last x From Bench", type text}, {"TT Account", type text}, {"Workforce Utilization Prev Month", type number}, {"Max of Billability Prev Month 1", type number}, {"Max of Billability Prev Month 2", type number}, {"Max of Billability Prev Month 3", type number}, {"Time Type", type text}, {"Average of Workday FTE", Int64.Type}, {"Sum of Current Month -3", type number}, {"Sum of Current Month -2", type number}, {"Sum of Current Month -1", type number}, {"Sum of Current Month", type number}, {"Sum of Current Month +1", type number}, {"Sum of Current Month +2", type number}, {"Sum of Current Month +3", type number}, {"Sum of Current Month +4", type number}, {"Sum of Current Month +5", type number}, {"Sum of Current Month +6", type number}, {"Sum of Current Month +7", type number}, {"Sum of Current Month +8", type number}, {"Sum of Current Month +9", type number}, {"Sum of Current Month +10", type number}, {"Sum of Current Month +11", type number}, {"OrgUnit2 Email", type text}, {"OrgUnit3 Email", type text}, {"OrgUnit4 Email", type text}, {"OrgUnit5 Email", type text}, {"OrgUnit6 Email", type text}, {"OrgUnit7 Email", type text}, {"Job Family Desc", type text}, {"Job Family Group", type text}, {"Job Level", Int64.Type}, {"Job Title", type text}, {"Emp Mgt Level", type text}, {"Manager Email", type text}, {"Last WD.Manager Emp ID", Int64.Type}, {"P&L Region", type text}, {"P&L Sub-Region", type text}, {"BSDHI L1", type text}, {"BSDHI L3", type text}, {"Primary Skill", type text}, {"Offering", type text}, {"SubOffering", type text}, {"Last Country Group", type text}, {"Work Region", type text}, {"Work Country", type text}, {"Work City", type text}, {"Project Owning Country", type text}, {"First Project ID", Int64.Type}, {"Project Name", type text}, {"Project Manager", type text}, {"Primary Project Manager", type text}, {"Position Name", type text}, {"Last Primary_RB", type text}, {"Employee Resource Pool Manager List", type text}, {"Employee Resource Pool Name", type text}, {"Position Resource Pool Manager List", type text}, {"Position Resource Pool Name", type text}, {"Opportunity ID", type text}, {"Position Service Offering", type text}, {"Position Service Type", type text}, {"AE Delegate", type text}, {"Fulfilled By", type text}, {"Fulfillment Date", Int64.Type}, {"Position Offering Family", type text}, {"Current Total Month FTE", type number}, {"Last Demand Owning Region", type text}, {"New Client Name", type text}, {"Last Update", type text}, {"Column92", Int64.Type}, {"Latest_Position_End_Date", type date}, {"Latest_Assignment_End_Date", type date}, {"Report_Week", type date}}),
    #"Filtered Rows Peter Mrazik" = Table.SelectRows(#"Changed Type", each ([OrgUnit4 Email] = "peter.mrazik@dxc.com")),
    #"Removed Other Columns" = Table.SelectColumns(#"Filtered Rows Peter Mrazik",{"EID", "Position ID", "PLM ID", "Availability", "Allocation %", "PPM Account Roll-Off", "Financial Client", "Financial Client ID", "Demand Type", "Last Billable Type", "Max of Position Job Level", "Sum of Current Month -1", "Sum of Current Month", "Sum of Current Month +1", "Sum of Current Month +2", "Sum of Current Month +3", "Sum of Current Month +4", "Sum of Current Month +5", "Sum of Current Month +6", "Project Owning Country", "Project Name", "Primary Project Manager", "Position Name", "Position Service Offering", "Position Service Type", "Latest_Position_End_Date", "Latest_Assignment_End_Date", "Report_Week"}),
    #"Inserted Month" = Table.AddColumn(#"Removed Other Columns", "Month", each Date.Month([Report_Week]), Int64.Type),
    #"Renamed Columns" = Table.RenameColumns(#"Inserted Month", { 
            {
                "Sum of Current Month", 
                let 
                    currentDateTime = DateTimeZone.LocalNow(),
                    currentMonth =  Date.MonthName( currentDateTime )
                in  currentMonth 
            } 
        } 
    )
in
    #"Renamed Columns"

// Addressing value in date column


    #"Added Custom > Report Week" = Table.AddColumn(#"Added Custom > Assign Date", "Report_Week", each "3.6.2021"),
    #"Inserted Month" = Table.AddColumn(#"Removed Other Columns", "Month", each Date.MonthName([Report_Week]), Int64.Type)

              #"Renamed Columns" = Table.RenameColumns(#"Removed Other Columns", {
        {
                "Sum of Current Month", 
                let 
                    currentMonth =  Date.MonthName(#"Removed Other Columns"[Report_Week]{1}) 

                in  currentMonth 
            } 
     }
    )
in
    #"Renamed Columns"

// Addressing Variable

let
    Source = Excel.Workbook(File.Contents("C:\Users\dkrnacova\OneDrive - DXC Production\Documents\Internal\PPMC\DXC_Resource_Allocation_and_Availability_from_03_JUNE_2021_vs_HCs_GIDC_EE_L4s.xlsb"), null, true),
    ReportCreated = Date.From("3.6.2021"),
    CurrentMonth = Date.Month(ReportCreated),
    Data1 = Source{[Name="Data"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(Data1, [PromoteAllScalars=true]),
    #"Replaced Value Decimal" = Table.ReplaceValue(#"Promoted Headers",",",".",Replacer.ReplaceText,{"Sum of Current Month -1", "Sum of Current Month", "Sum of Current Month +1", "Sum of Current Month +2", "Sum of Current Month +3", "Sum of Current Month +4", "Sum of Current Month +5", "Sum of Current Month +6"}),
    #"Changed Type Date>Int" = Table.TransformColumnTypes(#"Replaced Value Decimal",{{"Latest Assignment End Date", Int64.Type}, {"Latest Position End Date", Int64.Type}}),
    #"Added Custom > Position Date" = Table.AddColumn(#"Changed Type Date>Int", "Latest_Position_End_Date", each Date.From([Latest Position End Date])),
    #"Added Custom > Assign Date" = Table.AddColumn(#"Added Custom > Position Date", "Latest_Assignment_End_Date", each Date.From([Latest Assignment End Date])),
    #"Changed Type" = Table.TransformColumnTypes(#"Added Custom > Assign Date",{{"L4", type text}, {"EID", Int64.Type}, {"Position ID", Int64.Type}, {"PLM ID", Int64.Type}, {"Emp Name", type text}, {"Emp Email", type text}, {"Emp Type", type text}, {"Last Employee_Status", type text}, {"Availability", type text}, {"Allocation %", type text}, {"PPM Account Roll-Off", type text}, {"Financial Client", type text}, {"Financial Client ID", Int64.Type}, {"Demand Type", type text}, {"Last Billable Type", type text}, {"Max of Position Job Level", Int64.Type}, {"Position Create Date", Int64.Type}, {"Position Start Date", Int64.Type}, {"Latest Position End Date", Int64.Type}, {"Latest Assignment Create Date", Int64.Type}, {"Latest Assignment Start Date", Int64.Type}, {"Latest Assignment End Date", Int64.Type}, {"Last x From Bench", type text}, {"TT Account", type text}, {"Workforce Utilization Prev Month", type number}, {"Max of Billability Prev Month 1", type number}, {"Max of Billability Prev Month 2", type number}, {"Max of Billability Prev Month 3", type number}, {"Time Type", type text}, {"Average of Workday FTE", Int64.Type}, {"Sum of Current Month -3", type number}, {"Sum of Current Month -2", type number}, {"Sum of Current Month -1", type number}, {"Sum of Current Month", type number}, {"Sum of Current Month +1", type number}, {"Sum of Current Month +2", type number}, {"Sum of Current Month +3", type number}, {"Sum of Current Month +4", type number}, {"Sum of Current Month +5", type number}, {"Sum of Current Month +6", type number}, {"Sum of Current Month +7", type number}, {"Sum of Current Month +8", type number}, {"Sum of Current Month +9", type number}, {"Sum of Current Month +10", type number}, {"Sum of Current Month +11", type number}, {"OrgUnit2 Email", type text}, {"OrgUnit3 Email", type text}, {"OrgUnit4 Email", type text}, {"OrgUnit5 Email", type text}, {"OrgUnit6 Email", type text}, {"OrgUnit7 Email", type text}, {"Job Family Desc", type text}, {"Job Family Group", type text}, {"Job Level", Int64.Type}, {"Job Title", type text}, {"Emp Mgt Level", type text}, {"Manager Email", type text}, {"Last WD.Manager Emp ID", Int64.Type}, {"P&L Region", type text}, {"P&L Sub-Region", type text}, {"BSDHI L1", type text}, {"BSDHI L3", type text}, {"Primary Skill", type text}, {"Offering", type text}, {"SubOffering", type text}, {"Last Country Group", type text}, {"Work Region", type text}, {"Work Country", type text}, {"Work City", type text}, {"Project Owning Country", type text}, {"First Project ID", Int64.Type}, {"Project Name", type text}, {"Project Manager", type text}, {"Primary Project Manager", type text}, {"Position Name", type text}, {"Last Primary_RB", type text}, {"Employee Resource Pool Manager List", type text}, {"Employee Resource Pool Name", type text}, {"Position Resource Pool Manager List", type text}, {"Position Resource Pool Name", type text}, {"Opportunity ID", type text}, {"Position Service Offering", type text}, {"Position Service Type", type text}, {"AE Delegate", type text}, {"Fulfilled By", type text}, {"Fulfillment Date", Int64.Type}, {"Position Offering Family", type text}, {"Current Total Month FTE", type number}, {"Last Demand Owning Region", type text}, {"New Client Name", type text}, {"Last Update", type text}, {"Column92", Int64.Type}, {"Latest_Position_End_Date", type date}, {"Latest_Assignment_End_Date", type date}}),
    #"Filtered Rows Peter Mrazik" = Table.SelectRows(#"Changed Type", each ([OrgUnit4 Email] = "peter.mrazik@dxc.com")),
    #"Removed Other Columns" = Table.SelectColumns(#"Filtered Rows Peter Mrazik",{"EID", "Position ID", "PLM ID", "Availability", "Allocation %", "PPM Account Roll-Off", "Financial Client", "Financial Client ID", "Demand Type", "Last Billable Type", "Max of Position Job Level", "Sum of Current Month -1", "Sum of Current Month", "Sum of Current Month +1", "Sum of Current Month +2", "Sum of Current Month +3", "Sum of Current Month +4", "Sum of Current Month +5", "Sum of Current Month +6", "Project Owning Country", "Project Name", "Primary Project Manager", "Position Name", "Position Service Offering", "Position Service Type", "Latest_Position_End_Date", "Latest_Assignment_End_Date"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Other Columns", { 
            {
                "Sum of Current Month -1", 
                let 
                    currentMonth =  Text.From(CurrentMonth -1) 
                in  currentMonth 
            } 
        } 
    )
in
    #"Renamed Columns"

// Year and Month - Date Now

    #"Renamed Columns" = Table.RenameColumns(#"Changed Type", { 
            {
                "Year", 
                let 
                    currentDateTime = DateTimeZone.LocalNow(),
                    currentYear = Number.ToText( Date.Year( currentDateTime ) ),
                    currentMonth =  Date.MonthName( currentDateTime ) 

                in  currentYear & "-" & currentMonth 
            } 
        } 
    )
in
    #"Renamed Columns"