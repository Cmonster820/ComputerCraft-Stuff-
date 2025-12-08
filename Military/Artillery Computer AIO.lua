--Objective: calculate an artillery trajectory to a target inputted into the terminal
--this requires a gps constellation already set up
--CONNECT AZIMUTH TO RIGHT
--CONNECT ELEVATION TO LEFT
--CONNECT FIRING TO TOP
--ENSURE THAT POSITIVE AZIMUTH IS COUNTERCLOCKWISE AND THAT POSITIVE ELEVATION IS UP
--this assumes you have an autoloader that resets the angle after each shot and that it takes 5 seconds to go
--SET UP AZIMUTH WITH 8:1 RATIO
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
v=read().tonumber()*120+v
print("How many powder things are in use")
v=read().tonumber()*40+v
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
print("Trajectory projected to 2 dimensions")
theta = 0
gravity = -1 --(I think this is blocks/tick/tick idk)
Cd = 0.99 --velocity remaining after each tick (%)
for thetas,math.rad(90),math.rad(0.125) do
    startx = math.cos(thetas)*length
    starty = math.sin(thetas)*length
    oldendx = 0
    oldendy = 0
    endx = 0
    endy = 0
    projx = startx
    projy = starty
    projv = v
    prevprojy = starty
    prevthetas = thetas-0.125
    projang = theta
    while true do
        projvx = projv*math.cos(projang)
        projvy = projv*math.sin(projang)
        projx = projx + projvx
        projy = projy + projvy
        projvy = projvy+gravity
        projvx = projvx*(Cd*math.cos(projang))
        projvy = projvy*(Cd*math.sin(projang))
        projv = math.sqrt(projvy^2+projvx^2)
        projang = math.arctan(projvy/projvx)
        print("vx: "..projvx.." vy: "..projvy.." x: "..projx.." y: "..projy.." v: "..projv.." θp: "..projang.." θ: "..thetas)
        if projx>=dist then
            endx=projx
            break
        end
        if projy<=tvy and projx>=dist then
            endy=projy
            break
        end
    end
    if (endx==dist and endy == tvy) then
        theta = thetas
        print("Firing solution found for θ = "..math.deg(theta))
        break
    end
    if (dist-oldendx<dist-endx and tvy-oldendy<tvy-endy) then
        theta = prevthetas
        print("Firing solution found for θ = "..math.deg(theta).."\nNOTE: Firing solution not exact")
        break
    end
    oldendy = endy
    oldendx = endx
end
print("Calculating φ")
phi = 0
if tvx>0 then
    phi = math.arctan(tvz/tvx)
else
    phi = math.arctan(tvz/tvx)+math.rad(180)
end
if phi<0 then
    phi = phi+math.rad(360)
end
print("φ = "..math.deg(phi))
print("Firing solution (φ,θ): ("..phi..","..theta..")")
print("Aiming.")
azimuth.rotate(math.round(8*math.deg(phi)))
elevation.rotate(math.round(8*math.deg(theta)))
while azimuth.isRunning() and elevation.isRunning do
    os.sleep(0.1)
end
print("Aiming Complete, firing")
redstone.setOutput("top",1)
os.sleep(1)
redstone.setOutput("top",0)
print("Firing Complete, awaiting autoloading")
os.sleep(10)
print("Autoloading timer complete, ready for reuse")
goto systemready