Plugin.define do
  name    "Cocoa"
  version "0.1"
  file    "lib", "Cocoa"
  object  "Redcar::Cocoa"
  dependencies "HTML View", ">0",
                "runnables", ">0"
end
