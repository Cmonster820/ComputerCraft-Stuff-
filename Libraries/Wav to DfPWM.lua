local main = {}
local io = require("io")
local fs = require("fs")
local math = require("math") 
local bit32 = require("bit32")
local dfpwm = require("cc.audio.dfpwm")
local lshift(), rshift(), bor(), band() = bit32.lshift(), bit32.rshift(), bit32.bor(), bit32.band()
local function getbytes(str, start, endi)
    local bytes = {string.byte(str,start,endi)}
    local out = 0
    for i = 1, #bytes do
        out = bor(out,lshift(bytes[i],8))
    end
    out = bor(out,bytes[#bytes])
    return out
end
local function parseHeader(header)
    local ckID = header:sub(1,4)
    local cksize = getbytes(header,5,9)
    local WAVEID = header:sub(10,14)

end

local function main.convert(pathIn, pathOut)
    local fileIn = io.open(pathIn,"rb")
    local fileOut = io.open(pathOut, "wb")
    local encoder = dfpwm.make_encoder()
    local header = fileIn:read(12)

end

return main