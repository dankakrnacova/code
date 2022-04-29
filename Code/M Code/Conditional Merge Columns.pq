    #"Split Column by Delimiter" = Table.SplitColumn(#"Trimmed Text", "Offer accepted - Candidate name ", Splitter.SplitTextByDelimiter(" ", QuoteStyle.Csv), {"Name.1", "Name.2", "Name.3"}),
    AddCandidateName = Table.AddColumn(#"Split Column by Delimiter", "Candidate_Name", 
                                                                each if [Name.3] <> null then [Name.3] & "," & [Name.1]
						                                        else [Name.2] & "," & [Name.1])