--this is probably the worst idea I've ever had
local main = {} --create library table returned when this is required
local io = require("io")
local fs = require("fs")
local math = require("math") 
local bit32 = require("bit32")
local lshift(), rshift() = bit32.lshift(), bit32.rshift()
local function parseStreamInfo(Block)
    local minSize = tonumber(string.sub(Block, 1,2))
    local maxSize = tonumber(string.sub(Block, 3,4))
    local minFrameSize = tonumber(string.sub(Block,5,7))
    local maxFrameSize = tonumber(string.sub(Block,8,10))
    local rate = rshift(tonumber(string.sub(Block,11,13)),4)
    local channels = rshift(lshift(tonumber(string.sub(Block,13,13)),4),5)
    local bitsPsample = ((tonumber(string.sub(Block,13,13))%2)*16)+(rshift(tonumber(string.sub(Block,14,14)),4))
    
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