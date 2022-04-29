= Table.ExpandListColumn(Table.TransformColumns(Source, {{"classes", Splitter.SplitTextByDelimiter(",", QuoteStyle.None), let itemType = (type nullable text) meta [Serialized.Text = true] in type {itemType}}}), "classes")

// ked je v stlpci classes: table, chair, blanket - splitne to a da do jedneho stlpca, resp. unpivotne