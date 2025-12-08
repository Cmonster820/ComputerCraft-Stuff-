--for pocket computers or whatever they're called, requires wireless or ender modem version, requires advanced version for touchscreen
h,w = term.native().getSize()
main = term.native()
m = peripheral.find("modem")
log = window.create(term.current(),math.round(w*0.6),2,math.round(w-math.round(w*0.6))-1,math.round(h*0.2))
oldbg = scr.getBackgroundColor()
oldfg = scr.getTextColor()
main.setBackgroundColor(0xFFFFFF)
main.setTextColor(0xFFFFFF)
main.clear()
term.redirect(log)
print("Establishing connection with host")
m.open(62)
m.transmit(47,62,"Connection request")
print("Message transmitted on channel 47: \"Connection request\"\nAwaiting reply on channel 62...")
event,side,channel,replyChan,message,dist
repeat
    event,side,channel,replyChan,message,dist = os.pullEvent("modem_message")
until channel == 62
print("")