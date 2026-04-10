local main = {}
local io = require("io")
local fs = require("fs")
local math = require("math") 
local bit32 = require("bit32")
local dfpwm = require("cc.audio.dfpwm")



local function convert(pathIn, pathOut)
    local fileIn = io.open(pathIn,"rb")
    local fileOut = io.open(pathOut, "wb")
    local encoder = dfpwm.make_encoder()
    local header = 
end

return main