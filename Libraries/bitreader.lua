--basic class to read bits like file reader
local main = {}
local bitreader_MT = {
    file = nil,
    curBit = 0,
    curByte = 0
}
main.bitreader = bitreader_MT
local function bitreader_MT.new(file)
    local o = {}
    o.file = file
    o.curBit = 0
    o.curByte = 0
    return setmetatable(o, main.bitreader_MT)
end
local function bitreader_MT:read(bits)
    local bits = bits or 1
    local amtBytes = bits//8
    local remainderBits = bits%8
    local firstBytes = self.file:read(amtBytes) and amtBytes>0 or 0
    
end