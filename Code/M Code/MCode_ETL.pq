// za Navigation a pred Promoted Headers
= Table.Skip(Sheet1_Sheet ,2)

and
                                    (
                                        [Requisition_Status] = "Open"
                                    )
or 
([Requisition_Status] = "Filled" and [IsMax_Latest_Filled_Date_FiscalYr] = true)

/////

 let
    Source = Excel.Workbook(File.Contents("C:\Users\dkrnacova\OneDrive - DXC Production\Documents\Internal\Georgieva\DXC WDR ALL Requisitions - Daily Extract 08-13-2021.xlsx"), null, true),
    Sheet1_Sheet = Source{[Item="Sheet1",Kind="Sheet"]}[Data],
    #"Removed Top Rows" = Table.Skip(Sheet1_Sheet ,2),
    #"Promoted Headers" = Table.PromoteHeaders(#"Removed Top Rows", [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Report_Date", type date}, {"Requisition_Number", type text}, {"PPMC Position ID (Demand ID)", type text}, {"Req_Offer_Status", type text}, {"Requisition_Posting_Title", type text}, {"Job_Profile", type text}, {"Requisition_Status", type text}, {"Req_Posting_Recommendation", type text}, {"Geo Region", type text}, {"Country", type text}, {"State_Province", type text}, {"City", type text}, {"Secondary_Locations", type text}, {"Business_Group_L1", type text}, {"Business_Unit_L2", type text}, {"Business_L3_OrgUnit", type text}, {"Business_L4_MRU", type text}, {"Cost_Center", type text}, {"SCS_Code", type text}, {"Position_Cost_Center", type text}, {"Job_Code", type text}, {"Job_Family_Group", type text}, {"Job_Family", type text}, {"Management_Level", type text}, {"Job_Grade", type text}, {"Reason_Position_Needed", type text}, {"Replaced_Worker_EID", Int64.Type}, {"Replaced_Worker_Name", type text}, {"Position_ID (WPN)", Int64.Type}, {"Position_Status (WPN)", type text}, {"Position_Worker_Type", type text}, {"Worker_Sub_Type_Hiring_Requirement", type text}, {"Overtime_Status", Int64.Type}, {"Primary_Recruiter_Name", type text}, {"Recruiter_EID", Int64.Type}, {"Recruiter_Email", type text}, {"Hiring_Manager", type text}, {"Hiring_Manager_EID", Int64.Type}, {"Hiring_Manager_Email", type text}, {"Hiring_Manager_Supervisor_Name", type text}, {"HM_L1_Mngr_Name", type text}, {"HM_L2_Mngr_Name", type text}, {"HM_L3_Mngr_Name", type text}, {"HM_L4_Mngr_Name", type text}, {"HM_L5_Mngr_Name", type text}, {"HM_L6_Mngr_Name", type text}, {"Req_Creation_Date", type date}, {"Req_Approved_Date", type date}, {"Req_Posting_Date", type date}, {"Req_Latest_Reactivation_Date", type date}, {"Target_Start_Date", type date}, {"Days_Job_Req_Open_by_Date_Req_Entered", Int64.Type}, {"First_Sourced_Date", type date}, {"Days_Job_Req_Open_by_Recruiting_Start_Date", Int64.Type}, {"On_Hold_Date", type date}, {"On_Hold_Days", Int64.Type}, {"Days_Job_Req_Open_by_Req_Completed_Date", Int64.Type}, {"Number_Openings_Total", Int64.Type}, {"Number_Openings_Left_to_Fill", Int64.Type}, {"Number_External_Candidates", Int64.Type}, {"Number_Internal_Candidates", Int64.Type}, {"Number_Candidates_Matched", Int64.Type}, {"Number_Candidates_Shortlisted", Int64.Type}, {"Number_Candidates_Interviewed", Int64.Type}, {"Number_Candidates_Offered", type text}, {"Number_Candidates_Accepted", type text}, {"Number_External_Candidates_ALL", Int64.Type}, {"Number_Internal_Candidates_ALL", Int64.Type}, {"Number_Candidates_Matched_ALL", Int64.Type}, {"Number_Candidates_Shortlisted_ALL", Int64.Type}, {"Number_Candidates_Interviewed_ALL", Int64.Type}, {"Number_Candidates_Offered_ALL", Int64.Type}, {"Number_Candidates_Accepted_ALL", Int64.Type}, {"Number_Candidates_Declined_Rejected_ALL", Int64.Type}, {"Latest_Filled_Date", type date}, {"Labor_Category", type text}, {"reasonDetail", type text}, {"Latest_Cancellation_Date", type date}, {"Recruiter_Type", type text}, {"Employee_ID", Int64.Type}, {"Rev_Region_L1", type text}, {"Rev_Region_L2", type text}, {"Rev_Region_L3", type text}, {"BSDHI_L1", type text}, {"BSDHI_L2", type text}, {"BSDHI_L3", type text}, {"WMA ID", type text}, {"WMA Status", type text}, {"Last_Name", type text}, {"First_Name", type text}, {"Employee_Hire_Date", type date}, {"Age", type text}, {"Age Group", type text}, {"eidToken", type text}, {"Candidate_ID", type text}, {"Billable_NonBillable", type text}, {"Job_Type", type text}, {"Target_Hire_Date_Proposed", type date}, {"Revised_Target_Hire_Date_Proposed", type date}, {"Req_Legacy_Company", type text}, {"DXC Job Levels", Int64.Type}, {"Client_Project_Name (*Workday)", type text}, {"Client Name_Normalized", type text}, {"Client_ID", type text}, {"Offering Family (*PPMC)", type text}, {"Major Offering (*PPMC)", type text}, {"Industry (*PPMC)", type text}, {"Country_CD", type text}, {"Candidate_Is_Internal", type text}, {"Submission_Is_Internal", type text}, {"Job_Application_Source", type text}, {"Candidate_Source", type text}, {"Referred_by", type text}, {"Screen_Date", type date}, {"Hiring_Manager_Submittal_Date", type date}, {"Interview_Date", type date}, {"Offer_Approval_Date", type date}, {"Offer_Extended_date", type date}, {"Offer_Accepted_Date", type date}, {"Latest_Offer_Accepted", type text}, {"Latest_Offer_Extended", type text}, {"Inbound_Staffing_Process_Completed", type text}, {"latest_External_job_posting_Start_date", type date}, {"latest_External_job_posting_End_date", type date}, {"latest_Internal_job_posting_Start_date", type date}, {"latest_Internal_job_posting_End_date", type date}, {"Special Project", type text}, {"MIGRATIONID", type text}, {"WMA Req Position Reason", type text}, {"PPM Position Status", type text}, {"Country Group", type text}}),
    MergedQueriesGradTracker = Table.NestedJoin(#"Changed Type", {"WMA ID"}, GradTracker, {"WMA"}, "GradTracker", JoinKind.LeftAnti),
    RemovedColumns = Table.RemoveColumns(MergedQueriesGradTracker,{"GradTracker"}),
    FilteredMultipleFilters = Table.SelectRows(RemovedColumns, each 
                                    (
                                        [Country] = "Bulgaria" or [Country] = "Poland" or [Country] = "Slovakia"
                                    ) and
                                    (  
                                        [BSDHI_L1] = "DELIVER"
                                    ) and
                                    (
                                        [Job_Type] <> "Graduate Job"                                                      
                                    ) and
                                    (
                                        [Job_Profile] <> "00442D - Graduate Development Program"
                                    ) and
                                    (
                                        [HM_L4_Mngr_Name] = "Bartosz Drucis (20001326)" or
                                        [HM_L4_Mngr_Name] = "Hristo Hristov (21680395)" or
                                        [HM_L4_Mngr_Name] = "Kamen Dobrev (20255800)" or
                                        [HM_L4_Mngr_Name] = "Nikolay Dragiev Dragiev (Ð#(#)(009D)Ð¸ÐºÐ¾Ð»Ð°Ð¹ Ð”Ñ€Ð°Ð³Ð¸ÐµÐ²) (11701587)" or
                                        [HM_L4_Mngr_Name] = "Oliver Berks (21393104)" or
                                        [HM_L4_Mngr_Name] = "Peter Mrazik (20059961)" or
                                        [HM_L4_Mngr_Name] = "Sergey Kuznetsov (11574889)" or 
                                        [HM_L4_Mngr_Name] = "STILIAN TOMOV (11705657)" or
                                        [Hiring_Manager] = "Bartosz Drucis (20001326)" or
                                        [Hiring_Manager] = "Hristo Hristov (21680395)" or
                                        [Hiring_Manager] = "Kamen Dobrev (20255800)" or
                                        [Hiring_Manager] = "Nikolay Dragiev Dragiev (Ð#(#)(009D)Ð¸ÐºÐ¾Ð»Ð°Ð¹ Ð”Ñ€Ð°Ð³Ð¸ÐµÐ²) (11701587)" or
                                        [Hiring_Manager] = "Oliver Berks (21393104)" or              
                                        [Hiring_Manager] = "Peter Mrazik (20059961)" or 
                                        [Hiring_Manager] = "Sergey Kuznetsov (11574889)" or
                                        [Hiring_Manager] = "STILIAN TOMOV (11705657)"
                                    )
                                    ),
    FilteredReqContainsExternal = Table.SelectRows(FilteredMultipleFilters, each Text.Contains([Req_Posting_Recommendation], "External") or Text.Contains([Req_Posting_Recommendation], "external")),
    FilteredHireMasked = Table.SelectRows(FilteredReqContainsExternal, each Text.Contains([Inbound_Staffing_Process_Completed], "Hire") or Text.Contains([Inbound_Staffing_Process_Completed], "masked")),
    AddedLatestFilledDateFiscalYr = Table.AddColumn(FilteredHireMasked, "Latest_Filled_Date_FiscalYr", each #"Get FY"([Latest_Filled_Date], 3), Int64.Type),
    AddedMaxLatestFilledDateFiscalYr = Table.AddColumn(AddedLatestFilledDateFiscalYr, "Max_Latest_Filled_Date_FiscalYr", each if [Latest_Filled_Date_FiscalYr] <> null then List.Max(#"AddedLatestFilledDateFiscalYr"[Latest_Filled_Date_FiscalYr]) else null, Int64.Type),
    AddedIsMaxLatestFilledDateFiscalYr = Table.AddColumn(AddedMaxLatestFilledDateFiscalYr, "IsMax_Latest_Filled_Date_FiscalYr", each if [Latest_Filled_Date_FiscalYr] <> null then [Latest_Filled_Date_FiscalYr] = [Max_Latest_Filled_Date_FiscalYr] else null),
    FilteredOpenFilled = Table.SelectRows(AddedIsMaxLatestFilledDateFiscalYr, each 
                                    (
                                        [Requisition_Status] = "Open"
                                    ) or 
                                    (
                                        [Requisition_Status] = "Filled" and [IsMax_Latest_Filled_Date_FiscalYr] = true
                                    )
                                    ),
    #"Duplicated Column" = Table.DuplicateColumn(FilteredOpenFilled, "HM_L4_Mngr_Name", "HM_L4_Mngr_Name - Copy"),
    SplitColumnL4ID = Table.SplitColumn(#"Duplicated Column", "HM_L4_Mngr_Name - Copy", Splitter.SplitTextByEachDelimiter({"("}, QuoteStyle.Csv, false), {"HM_L4_Mngr_Name - Copy.1", "HM_L4_Mngr_Name - Copy.2"}),
    #"Changed Type1" = Table.TransformColumnTypes(SplitColumnL4ID,{{"HM_L4_Mngr_Name - Copy.1", type text}, {"HM_L4_Mngr_Name - Copy.2", type text}}),
    #"Replaced Value" = Table.ReplaceValue(#"Changed Type1",")","",Replacer.ReplaceText,{"HM_L4_Mngr_Name - Copy.2"}),
    #"Removed Columns" = Table.RemoveColumns(#"Replaced Value",{"HM_L4_Mngr_Name - Copy.1"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"HM_L4_Mngr_Name - Copy.2", "L4_ID"}})
in
    #"Renamed Columns"


\


//////
    AddedHireOffer_StartDate = Table.AddColumn(LatestFilledDate_IsCurrentFY, "HireOffer_StartDate", each 
                                    if List.Contains({"Filled"}, [Requisition_Status])
                                        then [Latest_Filled_Date]
                                    else if 
                                    List.Contains({"Open"}, [Requisition_Status]) 
                                    and 
                                    (
                                        List.Contains({"Accepted"}, [Req_Offer_Status]) 
                                        or 
                                        List.Contains({"Extended"}, [Req_Offer_Status])
                                    )
                                    and
                                    [Latest_Filled_Date] <> null
                                        then [Latest_Filled_Date] 
                                    else if
                                    List.Contains({"Open"}, [Requisition_Status]) 
                                    and 
                                    (
                                        List.Contains({"Accepted"}, [Req_Offer_Status]) 
                                        or 
                                        List.Contains({"Extended"}, [Req_Offer_Status])
                                    )
                                    and
                                    [Latest_Filled_Date] = null
                                    and 
                                    [Revised_Target_Hire_Date_Proposed] <> null
                                        then [Revised_Target_Hire_Date_Proposed]
                                    else if
                                    List.Contains({"Open"}, [Requisition_Status]) 
                                    and 
                                    (
                                        List.Contains({"Accepted"}, [Req_Offer_Status]) 
                                        or 
                                        List.Contains({"Extended"}, [Req_Offer_Status])
                                    )
                                    and
                                    [Latest_Filled_Date] = null
                                    and 
                                    [Revised_Target_Hire_Date_Proposed] = null
                                        then [Target_Hire_Date_Proposed]
                                    else
                                    null,
                                    type date
                                    ),

// nove 

 AddedHireOffer_StartDate = Table.AddColumn(FilteredFilledOpen, "HireOffer_StartDate", each 
                                    if  [Requisition_Status] = "Filled"
                                        then [Latest_Filled_Date]
                                    else
                                        if ([Requisition_Status] = "Open" and ([Req_Offer_Status] = "Offer Accepted" or [Req_Offer_Status] = "Offer Extended"))
                                        then   
                                            if [Latest_Filled_Date] <> null then [Latest_Filled_Date]
                                            else if [Revised_Target_Hire_Date_Proposed] <> null then [Revised_Target_Hire_Date_Proposed]
                                            else if [Revised_Target_Hire_Date_Proposed] = null then [Target_Hire_Date_Proposed]
                                            else null
                                    else
                                    null,
                                    type date
                                    )