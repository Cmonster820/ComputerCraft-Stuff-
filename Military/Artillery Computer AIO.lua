--Objective: calculate an artillery trajectory to a target inputted into the terminal
--this requires a gps constellation already set up
--CONNECT AZIMUTH TO RIGHT
--CONNECT ELEVATION TO LEFT
--CONNECT FIRING TO TOP
--ENSURE THAT POSITIVE AZIMUTH IS COUNTERCLOCKWISE AND THAT POSITIVE ELEVATION IS UP
--this assumes you have an autoloader that resets the angle after each shot and that it takes 5 seconds to go
math = require("math")
print("Scanning for data file")
if fs.exists("/data/artillery.txt") then
    print("File found")
    datafile = io.open("/data/artillery.txt","r")
    x = datafile:read("l").tonumber()
    y = datafile:read("l").tonumber()
    z = datafile:read("l").tonumber()
    length = datafile:read("l").tonumber()
    v = datafile:read("l").tonumber()
    datafile:close()
    goto datadone
end
::reask::
print("What is the X co-ordinate of the cannon's elevation actuation point?")
x = read().tonumber()
print("What is the Y co-ordinate of the cannon's elevation actuation point?")
y = read().tonumber()
print("What is the Z co-ordinate of the cannon's elevation actuation point?")
z = read().tonumber()
print("The co-ordinates of the cannon's elevation actuation point is ("..x..","..y..","..z.."). Is this correct? (Y/N)")
answer = read()
::recorrect::
if answer = "N" then
    goto reask
elseif answer ~="Y" then
    print("Invalid response, please use Y or N")
    answer = read()
    goto recorrect
end
print("What is the length of the cannon's barrel?")
length = read().tonumber()
v = 0
print("How many brass cartridge thingies are in use?")
v+=read().tonumber()*120
print("How many powder things are in use")
v+=read().tonumber()*40
print("Understood. Writing data to file.")
datafile = io.open("/data/artillery.txt","a")
datafile:write(x+"\n")
datafile:write(y+"\n")
datafile:write(z+"\n")
datafile:write(length+"\n")
datafile:write(v+"\n")
datafile:close()
print("Datafile generated and data stored")
::datadone::
azimuth = peripheral.wrap("right")
elevation = peripheral.wrap("left")
fire = peripheral.wrap("top")
print("System ready")
::systemready::
print("Please input the co-ordinates of the target")
print("X")
tx = read().tonumber()
print("Y")
ty = read().tonumber()
print("Z")
tz = read().tonumber()
tvx = tx-x
tvy = ty-y
tvz = tz-z
print("Vector from cannon elevation actuation point to target:〈"..tvx..","..tvy..","..tvz.."〉")
print("Beginning simulation")
dist = math.ceil(math.sqrt(tvx^2+tvz^2))
print("Distance: "..dist.." blocks, rounded to nearest integer")
