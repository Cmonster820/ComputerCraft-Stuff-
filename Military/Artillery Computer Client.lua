--for pocket computers or whatever they're called, requires wireless or ender modem version, requires advanced version for touchscreen
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
log = window.create(term.current(),math.round(w*0.6),2,math.round(w-math.round(w*0.6))-1,math.round(h*0.2))
oldbg = scr.getBackgroundColor()
oldfg = scr.getTextColor()
print("What is the name of your artillery host?")
host = read()
main.setBackgroundColor(0xFFFFFF)
main.setTextColor(0xFFFFFF)
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
