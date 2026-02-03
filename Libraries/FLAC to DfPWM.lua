--this is probably the worst idea I've ever had
local main = {} --create library table returned when this is required
local io = require("io")
local fs = require("fs")
local math = require("math") 
local bit32 = require("bit32")
local lshift(), rshift(), bor(), band() = bit32.lshift(), bit32.rshift(), bit32.bor(), bit32.band()
local function getbytes(str, start, endi)
    local bytes = {string.byte(str,start,endi)}
    local out = 0
    for i = 1, #bytes-1 do
        out = bor(out,lshift(bytes[i],8))
    end
    out = bor(out,bytes[#bytes])
    return out
end
local function parseStreamInfo(Block)
    local minSize = getbytes(Block, 1,2)
    local maxSize = getbytes(Block, 3,4)
    local minFrameSize = getbytes(Block,5,7)
    local maxFrameSize = getbytes(Block,8,10)
    local rate = rshift(getbytes(Block,11,13),4)
    local channels = rshift(lshift(getbytes(Block,13,13),4),5)+1
    local bitsPsample = ((getbytes(Block,13,13)%2)*16)+(rshift(getbytes(Block,14,14),4))+1
    local totalInterchannelSamples = band(getbytes(Block, 14, 18), 0x0FFFFFFFFF)
    local MD5Checksum = string.sub(Block,19,34)
    return minSize,maxSize,minFrameSize,maxFrameSize,rate,channels,bitsPsample,totalInterchannelSamples,MD5Checksum
end
local function parseBlockHeader(header)

end
local function main.convertFile(pathIn, pathOut)
    local fileIn = io.open(pathIn, "r+")
    local signature = fileIn:read(4)
    assert(signature=="fLaC", "Not of type fLaC") --Check file signature for correct thing
    local StreamInfo = fileIn:read(34)
    local minSize, maxSize, minFrameSize, maxFrameSize, rate, channels, bitsPsample, totalInterchannelSamples, MD5Checksum =parseStreamInfo(StreamInfo)
end
return main