--for pocket computers or whatever they're called, requires wireless or ender modem version, requires advanced version for touchscreen
g = require("graphbasic")
h,w = term.native().getSize()
artyPacket = 
{
    name="admin",
    type = "",
    secret = "",
    target = {},
    data = ""
}
main = term.native()
m = peripheral.find("modem")
log = window.create(term.current(),math.floor(w*0.6),2,math.floor(w-math.floor(w*0.6))-1,math.floor(h*0.2))
oldbg = scr.getBackgroundColor()
oldfg = scr.getTextColor()
if fs.exists("/data/artillery.txt") then
    datafile = io.open("/data/artillery.txt","r+")
    host = datafile:read("l")
    hostID = tonumber(datafile:read("l"))
    datafile:close()
    goto datadone
end
print("What is the name of your artillery host?")
host = read()
main.setPaletteColor(colors.white,0xFFFFFF)
main.setPaletteColor(colors.red,0xFF0000)
main.setPaletteColor(colors.green,0x00FF00)
main.setBackgroundColor(colors.white)
main.setTextColor(colors.white)
main.clear()
term.redirect(log)
print("Establishing connection with host")
rednet.open(m)
print("Finding host")
hostID = rednet.lookup("Arty", host)
print("Found, Host ID: "..hostID)
print("Connecting...")
artyPacket.data = "connect"
rednet.send(hostID,textutils.serialize(artyPacket),"arty")
artyPacket.data = ""
_,message = rednet.receive("arty")
message = textutils.unserialize(message)
if message.data == "Allowed" then
    print("Granted")
else
    error("Denied")
end
datafile = io.open("/data/artillery.txt","w")
datafile:write(host.."\n")
datafile:write(hostID.."\n")
datafile:close()
::datadone::
term.redirect(main)
term.setCursorBlink(false)
main.setBackgroundColor(colors.red)
main.setTextColor(colors.red)
g.fill(w//4,h//2-1,w//4-1,3," ")
label = "Where would you like to target?"
main.setTextColor(colors.black)
main.setBackgroundColor(colors.white)
g.set(w//2-(#label)//2,h//2-3,label,false)
main.setTextColor(colors.green)
main.setTextColor(colors.green)
g.fill(3*w//4+1,h//2-1,w//4-1,3," ")
main.setTextColor(colors.white)
label = "Coord Input"
g.set(((3*w//4+1)+(w//4-1)//2)-(#label//2),h//2,label)
label = "On my position"
main.setBackgroundColor(colors.red)
g.set((w//4+(w//4-1)//2)-(#label//2),h//2,label)
mx, my
function processMyPos()
    term.redirect(log)
    print("Multiple types not yet implemented")
    x,y,z = gps.locate()
    artyPacket.type = "St"
    artyPacket.target = {x,y,z}
    rednet.send(hostID,textutils.serialize(artyPacket),"arty")
    print("sent")
    artyPacket.target = {}
    artyPacket.type = ""
    term.redirect(main)
    goto datadone
end
function processTypePos()
    main.setTextColor(colors.white)
    main.setBackgroundColor(colors.black)
    g.fill(w//4,h//2-1,w//2,3," ")
    term.setCursorPos(w//4+1,h//2)
    term.setCursorBlink(true)
    local posString = read()
    posString = string.gsub(posString," ","")
    local parseTable = {}
    for n in string.gmatch(posString,"([^,]+)") do
        table.insert(parseTable,tonumber(n))
    end
    artyPacket.target = parseTable
    artyPacket.type = "St"
    term.redirect(log)
    print("sending command")
    rednet.send(hostID,textutils.serialize(artyPacket),"arty")
    artyPacket.target = {}
    artyPacket.type = ""
    print("sent")
    term.redirect(main)
end
repeat
    _,_,mx,my=os.pullEvent("mouse_click")
    if not(((w//4<=mx and mx<=(w//2-1)) or (3*w//4<=mx and mx<=(w-1)))and(h//2-1<=my and my<=h//2+2)) then
        term.redirect(log)
        print("Invalid position")
        term.redirect(main)
    end
until ((w//4<=mx and mx<=(w//2-1)) or (3*w//4<=mx and mx<=(w-1)))and(h//2-1<=my and my<=h//2+2)
if w//4<=mx and mx<=(w//2-1) then
    term.redirect(log)
    print("Selected:\nOn your position\n\nwhy.")
    term.redirect(main)
    main.setBackgroundColor(colors.white)
    main.clear()
    processMyPos()
else
    term.redirect(log)
    print("Please type your coordinates, in the form X,Y,Z")
    term.redirect(main)
    main.setBackgroundcolor(colors.white)
    main.clear()
    processTypePos()
end