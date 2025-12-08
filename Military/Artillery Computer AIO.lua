--Objective: calculate an artillery trajectory to a target inputted into the terminal
--this requires a gps constellation already set up
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
v+=read().tonumber()*
print("How many powder things are in use")
v+=read().tonumber()*
print("Understood. Writing data to file.")
datafile = io.open("/data/artillery.txt","a")
datafile:write(x+"\n")
datafile:write(y+"\n")
datafile:write(z+"\n")
datafile:close()
print("Datafile generated and data stored")
::datadone::
