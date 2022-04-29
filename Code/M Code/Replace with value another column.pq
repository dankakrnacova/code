#"Replaced Value" = Table.ReplaceValue(#"Filtered Rows1","",null,Replacer.ReplaceValue,{"People Mgr L6 Chief"}),
Custom1 = Table.ReplaceValue(#"Replaced Value", null, each _[People Mgr L5 Chief], Replacer.ReplaceValue, {"People Mgr L6 Chief"})
    // every null replace with value from _[COLUMN], in column {XY}