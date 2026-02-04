--basic class to read bits like file reader
local bit32 = require("bit32")
local math = require("math")
local abs() = math.abs()
local shl(), shr(), bor() = bit32.lshift(), bit32.rshift(), bit32.bor()
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
    local offset = abs(self.curBit-8)
    local outB = 0
    for i = 1, bits do
        outB = bor(outB, shr(shl(self.curByte,(i%8)-1),7))
        self.curBit = self.curBit+1
        if self.curBit == 9 then
            self.curBit = 1
            self.curByte = self.file:read(1):byte(1,1)
        end
    end
    return outB
end