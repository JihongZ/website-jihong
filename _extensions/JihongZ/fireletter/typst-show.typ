// Typst custom formats typically consist of a 'typst-template.typ' (which is
// the source code for a typst template) and a 'typst-show.typ' which calls the
// template's function (forwarding Pandoc metadata values as required)
//
// This is an example 'typst-show.typ' file (based on the default template  
#show: FireLetter.with(
$if(title)$
  title: [$title$],
$endif$
$if(from-details)$
  from-details: [$from-details$],
$endif$
$if(to-details)$
  to-details: [$to-details$],
$endif$
)