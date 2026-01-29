--Objective: calculate an artillery trajectory to a target inputted into the terminal
--CONNECT ELEVATION TO MODEM FIRST, THEN AZIMUTH
--CONNECT FIRING TO TOP
--ENSURE THAT POSITIVE AZIMUTH IS COUNTERCLOCKWISE AND THAT POSITIVE ELEVATION IS UP
--this assumes you have an autoloader that resets the angle after each shot and that it takes 5 seconds to go
--SET UP AZIMUTH WITH 8:1 RATIO
--^^^^^ might already be that way
math = require("math")
local sin(), cos(), tan(), asin(), acos(), atan(), rad(), abs(), sqrt(), deg(), floor(), ceil() = math.sin(), math.cos(), math.tan(), math.asin(), math.acos(), math.atan(), math.rad(), math.abs(), math.sqrt(), math.deg(), math.floor(), math.ceil()
local function round(n)
    if ceil(n)-n>abs(floor(n)) then
        return floor(n)
    end
    return ceil(n)
end
print("Scanning for data file")
if fs.exists("/data/artillery.txt") then
    print("File found")
    datafile = io.open("/data/artillery.txt","r+")
    x = tonumber(datafile:read("l"))
    print(x)
    y = tonumber(datafile:read("l"))
    print(y)
    z = tonumber(datafile:read("l"))
    print(z)
    length = tonumber(datafile:read("l"))
    print(length)
    v = tonumber(datafile:read("l"))
    print(v)
    datafile:close()
    goto datadone
end
::reask::
print("What is the X co-ordinate of the cannon's elevation actuation point?")
x = tonumber(read())
print("What is the Y co-ordinate of the cannon's elevation actuation point?")
y = tonumber(read())
print("What is the Z co-ordinate of the cannon's elevation actuation point?")
z = tonumber(read())
print("The co-ordinates of the cannon's elevation actuation point is ("..x..","..y..","..z.."). Is this correct? (Y/N)")
answer = read()
::recorrect::
if answer == "N" then
    goto reask
elseif answer ~="Y" then
    print("Invalid response, please use Y or N")
    answer = read()
    goto recorrect
end
print("What is the length of the cannon's barrel?")
local length = tonumber(read())
local v = 0
print("How many brass cartridge thingies are in use?")
local v=tonumber(read())*120+v
print("How many powder things are in use")
local v=tonumber(read())*40+v
print("Understood. Writing data to file.")
datafile = io.open("/data/artillery.txt","w")
datafile:write(x.."\n")
datafile:write(y.."\n")
datafile:write(z.."\n")
datafile:write(length.."\n")
datafile:write((v/20).."\n")
datafile:close()
local v = v/20
print("Datafile generated and data stored")
::datadone::
local azimuth = peripheral.wrap("Create_SequencedGearshift_1")
local elevation = peripheral.wrap("Create_SequencedGearshift_0")
print("System ready")
::systemready::
print("Please input the co-ordinates of the target")
print("X")
local tx = tonumber(read())
print("Y")
local ty = tonumber(read())
print("Z")
local tz = tonumber(read())
local tvx = tx-x
local tvy = ty-y
local tvz = tz-z
print("Vector from cannon elevation actuation point to target: \u{27E8}"..tvx..","..tvy..","..tvz.."\u{27E9}")
print("Beginning simulation")
local dist = math.ceil(math.sqrt(tvx^2+tvz^2))
print("Distance: "..dist.." blocks, rounded to nearest integer")
print("Trajectory projected to 2 dimensions")
local theta = 0
local gravity = -1 --(I think this is blocks/tick/tick idk)
--calulate maximum height using air resistanceless math
local maxheight = ((v*sin(1/2*asin((dist*20*gravity)/(v^2))))^2)/(2*20*gravity)
local Cd = 0.99 --velocity remaining after each tick (%)
local oldendx = 0
local oldendy = 0
local endx = 0
local endy = 0
for thetas=0,rad(90),rad(0.125) do
    local startx = cos(thetas)*length
    local starty = sin(thetas)*length
    local projx = startx
    local projy = starty
    local projv = v
    local prevthetas = thetas-0.125
    local projang = thetas
    while true do
        local projvx = projv*cos(projang)
        local projvy = projv*sin(projang)
        projx = projx + projvx
        projy = projy + projvy
        projvy = projvy+gravity
        projvx = projvx*(Cd*abs(cos(projang)))
        projvy = projvy*(Cd*abs(sin(projang)))
        projv = sqrt(projvy^2+projvx^2)
        projang = atan(projvy/projvx)
        print("vx: "..projvx.."\nvy: "..projvy.."\nx: "..projx.."\ny: "..projy.."\nv: "..projv.."\n\u{03b8}p: "..projang.."\n\u{03b8}: "..thetas.."\n")
        if projx>=dist then
            endx=projx
            exdy=projy
            break
        end
        if projy<=tvy then
            endy=projy
            endx=projx
            break
        end
        if projy>=maxheight then
            endy=projy
            endx=projx
            break
        end
        os.queueEvent("yield") --yield to prevent error
        os.pullEvent("yield") --resume immediately
    end
    if (endx==dist and endy == tvy) then
        theta = thetas
        print("Firing solution found for \u{03b8} = "..deg(theta))
        break
    end
    if (oldendx<dist and dist<endx) then
        if (dist-oldendx<dist-endx and tvy-oldendy<tvy-endy) then
            theta = prevthetas
            print("Firing solution found for \u{03b8} = "..deg(theta).."\nWARNING: Firing solution not exact")
            break
        end
        if (dist-oldendx>dist-endx and tvy-oldendy>tvy-endy) then
            theta = thetas
            print("Firing solution found for \u{03b8} = "..deg(theta).."\nWARNING: Firing solution not exact")
            break
        end
    end
    oldendy = endy
    oldendx = endx
end
print("Calculating \u{03d6}")
phi = 0
if tvx>0 then
    phi = atan(tvz/tvx)
else
    phi = atan(tvz/tvx)+rad(180)
end
if phi<0 then
    phi = phi+rad(360)
end
print("\u{03d6} = "..deg(phi))
print("Firing solution (\u{03d6},\u{03b8}): ("..(phi)..","..(theta)..")")
print("Aiming.")
azimuth.rotate(math.floor(8*deg(phi)),2)
elevation.rotate(math.floor(8*deg(theta)),2)
while azimuth.isRunning() and elevation.isRunning() do
    os.sleep(0.1)
end
print("Aiming Complete, firing")
redstone.setOutput("top",true)
os.sleep(1)
redstone.setOutput("top",false)
print("Firing Complete, awaiting autoloading")
os.sleep(10)
print("Autoloading timer complete, ready for reuse")
goto systemready