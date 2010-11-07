Plugin.define do
  name    "markup_viewer"
  version "0.1b"
  file    "lib", "markup_viewer"
  object  "Redcar::MarkupViewer"
  dependencies "redcar",    ">0",
               "HTML View", ">0"
end
