= Table.Group(#"Previous Step", {"Key"}, {{"Name", each Text.Combine([Name],"|")},{"Country Code",each List.Distinct([Country Code])}})
= Table.Group(#"Changed Type", {"SERVER"}, {{"APPLICATION", each Text.Combine(List.Distinct([APPLICATION]),"|")},{"SOFTWARE",each List.Distinct([SOFTWARE])}})
