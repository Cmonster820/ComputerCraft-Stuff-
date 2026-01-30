--this is probably the worst idea I've ever had
local main = {} --create library table returned when this is required
local io = require("io")
local fs = require("fs")
local math = require("math") 
local bit32 = require("bit32")
local function parseFileHeader(header)
    
end
local function parseMetadataBlockHeader(header)

end
local function main.convertFile(pathIn, pathOut)
    local fileIn = io.open(pathIn, "r+")

end
return main