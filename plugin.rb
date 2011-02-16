Plugin.define do
  name    "Markup Preview"
  version "0.1b"
  file    "lib", "markup_preview"
  object  "Redcar::MarkupPreview::MarkupPreview"
  dependencies "redcar",    ">0",
               "HTML View", ">0"
end
