Plugin.define do
  name    "markdown"
  version "0.1b"
  file    "lib", "markdown"
  object  "Redcar::Markdown"
  dependencies "redcar",    ">0",  
               "HTML View", ">0"              
end
