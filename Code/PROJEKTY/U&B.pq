= Table.AddColumn(#"Expanded Expanded Expanded Filtered Rows1", "L5_EID", each
    if [People_Mgr_EID] = null then null 
    else if [People_Mgr_EID_1] = null then 20059961 
    else if [People_Mgr_EID_2] = null then [People_Mgr_EID_1] 
    else [People_Mgr_EID_2],
    Int64.Type
    )


    = Table.ReplaceValue(#"Expanded Expanded Expanded Filtered Rows1",0,null,Replacer.ReplaceValue,{"People_Mgr_EID", "Filtered Rows1.People_Mgr_EID", "Expanded Filtered Rows1.People_Mgr_EID"})

    = Table.ReplaceValue(#"Expanded Expanded Expanded Filtered Rows1",null,1,Replacer.ReplaceValue,{"People_Mgr_EID", "People_Mgr_EID_1", "People_Mgr_EID_2"})