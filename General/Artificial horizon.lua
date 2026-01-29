--Objective: make an artificial horizon display thingy like that one screen in carrier command 2
--oh god quaternions
--how the hell am I gonna do this
--this is gonna be cursed
--could prob use eulerangles instead of quats but I need to figure out how to use quats anyway and I trust them more
local math = require("math")
--remaining imports
local sin(),cos(),tan(),asin(),acos(),atan(),rad(),deg(), atan2() = math.sin(), math.cos(), math.tan(), math.asin(), math.acos(), math.atan(), math.rad(), math.deg(), math.atan2()
-- ^ lua is faster with locals than globals, even though math is a local here this skips the step of searching the math table, which also slows it down
while true do --this seems cursed but here it's fine
    --get quat (I don't have the documentation for the api I'm using here but I'll change this later)
    -- form: qw, qx, qy, qz
    local heading = atan2(2*(y*z+w*x),(w^2)-(x^2)-(y^2)+(z^2))
    local attitude = asin(-2*(x*z-w*y))
    local bank = atan2(2*(x*y+w*z),(w^2)+(x^2)-(y^2)-(z^2))
    print("Heading: "..deg(heading).."\nAttitude: "..deg(attitude).."\nBank: "..deg(bank))
    os.queueEvent("yield")
    os.pullEvent("yield")
end