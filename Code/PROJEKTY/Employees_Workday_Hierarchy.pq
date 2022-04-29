let
    Source = SharePoint.Files("https://dxcportal.sharepoint.com/sites/GIDCEEITO_CloudFinancedata", [ApiVersion = 15]),
    #"Filtered Rows" = Table.SelectRows(Source, each Text.Contains([Name], "Workday") and Text.Contains([Name], "actual_month")),
    #"Filtered Hidden Files1" = Table.SelectRows(#"Filtered Rows", each [Attributes]?[Hidden]? <> true),
    #"Invoke Custom Function1" = Table.AddColumn(#"Filtered Hidden Files1", "Transform File (3)", each #"Transform File (3)"([Content])),
    #"Renamed Columns1" = Table.RenameColumns(#"Invoke Custom Function1", {"Name", "Source.Name"}),
    #"Removed Other Columns1" = Table.SelectColumns(#"Renamed Columns1", {"Source.Name", "Transform File (3)"}),
    #"Expanded Table Column1" = Table.ExpandTableColumn(#"Removed Other Columns1", "Transform File (3)", Table.ColumnNames(#"Transform File (3)"(#"Sample File (3)"))),
    #"Removed Top Rows" = Table.Skip(#"Expanded Table Column1", 1),
    #"Promoted Headers" = Table.PromoteHeaders(#"Removed Top Rows", [PromoteAllScalars=true]),
    #"Filtered Rows1" = Table.SelectRows(#"Promoted Headers", each ([People Mgr L4 Email] = "peter.mrazik@dxc.com")),
    #"Removed Other Columns" = Table.SelectColumns(#"Filtered Rows1",{"Employee ID", "Employee Name", "Email", "People Mgr Employee ID"}),
    RenamedColumns = Table.RenameColumns(#"Removed Other Columns",{{"Employee ID", "EID"}, {"Employee Name", "Employee_Name"}, {"Email", "Employee_Email"}, {"People Mgr Employee ID", "People_Mgr_EID"}}),
    ChangedType = Table.TransformColumnTypes(RenamedColumns,{{"EID", Int64.Type}, {"Employee_Name", type text}, {"Employee_Email", type text}, {"People_Mgr_EID", Int64.Type}}),
    Added_L4_Row = Table.InsertRows(ChangedType, 0 , {[EID = 20059961, Employee_Name = "Mrazik,Peter", Employee_Email = "peter.mrazik@dxc.com", People_Mgr_EID = null]}),
    Merged1 = Table.NestedJoin(Added_L4_Row, {"People_Mgr_EID"}, Added_L4_Row, {"EID"}, "ExpandTable1", JoinKind.LeftOuter),
    Expanded1 = Table.ExpandTableColumn(Merged1, "ExpandTable1", {"People_Mgr_EID"}, {"People_Mgr_EID_1"}),
    Merged2 = Table.NestedJoin(Expanded1, {"People_Mgr_EID_1"}, Expanded1, {"EID"}, "ExpandTable2", JoinKind.LeftOuter),
    Expanded2 = Table.ExpandTableColumn(Merged2, "ExpandTable2", {"People_Mgr_EID"}, {"People_Mgr_EID_2"}),
    #"Added_L5" = Table.AddColumn(Expanded2, "L5_EID", each
                                                            if [People_Mgr_EID] = null then null 
                                                            else if [People_Mgr_EID_1] = null then 20059961 
                                                            else if [People_Mgr_EID_2] = 20059961 then [People_Mgr_EID_1]
                                                            else if [People_Mgr_EID_2] = null then [People_Mgr_EID]
                                                            else null,
                                                            Int64.Type
                                                        ),
    #"Added_L6" = Table.AddColumn(#"Added_L5", "L6_EID", each
                                                            if [People_Mgr_EID] <> null then [People_Mgr_EID]
                                                            else null,
                                                            Int64.Type
                                                        ),
    Removed_PeopleMgr = Table.RemoveColumns(Added_L6,{"People_Mgr_EID", "People_Mgr_EID_1", "People_Mgr_EID_2"}),
    Merged3 = Table.NestedJoin(Removed_PeopleMgr, {"L5_EID"}, Removed_PeopleMgr, {"EID"}, "Removed_PeopleMgr", JoinKind.LeftOuter),
    Expanded3 = Table.ExpandTableColumn(Merged3, "Removed_PeopleMgr", {"Employee_Name", "Employee_Email"}, {"L5_Name", "L5_Email"}),
    Merged4 = Table.NestedJoin(Expanded3, {"L6_EID"}, Expanded3, {"EID"}, "Expanded3", JoinKind.LeftOuter),
    Expanded4 = Table.ExpandTableColumn(Merged4, "Expanded3", {"Employee_Name", "Employee_Email"}, {"L6_Name", "L6_Email"})
in
    Expanded4