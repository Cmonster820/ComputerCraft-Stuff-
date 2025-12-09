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
packet.data = "connect"
rednet.send(hostID,textutils.serialize(packet),"arty")
packet.data = ""
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