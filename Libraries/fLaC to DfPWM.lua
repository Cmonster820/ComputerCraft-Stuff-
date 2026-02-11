--this is probably the worst idea I've ever had
local main = {} --create library table returned when this is required
local bitReader = require("bitreader")
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
local function getBit(byte,bit)
    return rshift(lshift(byte,bit-1),7)
end
local function decodeRice(file, k)
    local zeroCount = 0
    
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
local function skipToAudio(file)
    local isLast = false
    while not isLast do
        local header = file:read(4)
        if not header then break end
        local b1,b2,b3,b4 = string.bytes(header,1,4)
        isLast = b1>=128
        local bType = b1%128
        local length = (b2*65536)+(b3*256)+b4
        file:seek("cur",length) --I don't know what this means but Google AI says so and it seems to make sense
        os.queueEvent("yield")
        os.pullEvent("yield")
    end
end
local function constant(bitReader, bitsPsample)
end
local function verbatim(bitReader, bitsPsample, size, rate)
end
local function fixed(bitReader, bitsPsample, size, rate)
end
local function LPC(bitReader, bitsPsample, size, rate)
end
local function readFrame(file, channels, bitsPsample, minSize, maxSize, minFrameSize, maxFrameSize, totalInterchannelSamples, rate)
    local headerBytes = file:read(2)
    local b1, b2 = string.byte(headerBytes,1,2)
    assert(b1 == 0xFF and band(b2, 0xFC) == 0xF8, "Error, sync lost. Conversion failure.")
    local b3 = file:read(1):byte()
    local strat = rshift(b3,7)
    local blockSizeIdx = rshift(band(b3,0x73),3)
    local sampleRateIdx = band(b3,0x0F)
    local sample = ""
    local reader = bitreader.new(file)
    for i=1,channels do
        local subFheader = file:read(1):byte()
        assert(getBit(subFheader,1)==0, "Error: I genuinely don't know how this can happen but something's up with the audio\nverbose:\nsubframe header padding bit is 1")
        local typecode = rshift(lshift(subFheader,1),2)
        local wasted = getBit(subFheader,8)
        local sFtype = ""
        if typecode == 0 then
            sFtype = "const"
        elseif typecode == 1 then
            sFtype = "verbatim"
        elseif 8 <= typecode and typecode <= 12 then
            sFtype = "fixed"
            local typeOrder = typecode-8
        elseif 32 <= typecode and typecode <= 63 then
            sFtype = "LPC"
            local typeOrder = typecode-31
        else
            error("Invalid subframe type code: "..tostring(typecode))
        end
    end
end
local function main.convertFile(pathIn, pathOut)
    local fileIn = io.open(pathIn, "r+")
    local signature = fileIn:read(4)
    assert(signature=="fLaC", "Not of type fLaC") --Check file signature for correct thing
    local StreamInfo = fileIn:read(34)
    local minSize, maxSize, minFrameSize, maxFrameSize, rate, channels, bitsPsample, totalInterchannelSamples, MD5Checksum =parseStreamInfo(StreamInfo)
    skipToAudio(fileIn)
    local fileOut = fs.open(pathOut, "wb")
    while do
        local encoder = dfpwm.make_encoder()
        local data = readFrame(file, channels, bitsPsample, minSize, maxSize, minFrameSize, maxFrameSize, totalInterchannelSamples, rate)
        local fileOut.write(encoder(data))
        os.queueEvent("yield")
        os.pullEvent("yield")
    end
    
end
return main