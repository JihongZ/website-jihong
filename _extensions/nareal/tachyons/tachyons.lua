
function Pandoc(doc)
  quarto.doc.add_html_dependency({
    name = "tachyons",
    version = "4.12.0",
    stylesheets = { "css/tachyons.min.css" }
  })
end
