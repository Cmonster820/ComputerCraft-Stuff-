--this is probably the worst idea I've ever had
local main = {} --create library table returned when this is required
local io = require("io")
local fs = require("fs")
local math = require("math") 
local bit32 = require("bit32")
local function parseStreamInfo(blockHeader)

end
local function parseBlockHeader(header)

end
local function main.convertFile(pathIn, pathOut)
    local fileIn = io.open(pathIn, "r+")
    local signature = fileIn:read(4)
    assert(signature=="fLaC", "Not of type fLaC") --Check file signature for correct thing
    local info = fileIn:read(34)
end
return main