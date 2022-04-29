= Table.ReplaceValue(
     #"Changed Type",
     each [Offices],
     each if [Offices] = null then [Sources.Name] else [Offices] ,
     Replacer.ReplaceValue,{"Offices"}
 )