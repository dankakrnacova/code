= Table.AddColumn(Source, "Status", each try if [A] = "a" or [A] "aa" then "Super" else "Nie tak super" otherwise null)
= Table.AddColumn(Source, "Status", each if Text.StartsWith([A], "K") then "Super start" else "Nie tak super start")
= Table.AddColumn(Source, "Status", each if Text.StartsWith([A], "G") then [Status]&"1" else [Status])
