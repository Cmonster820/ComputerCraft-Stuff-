p = peripheral.find("printer")
m = peripheral.find("modem")
rednet.host("FAX","end1")
ID = rednet.getIdentifier()
w,h = p.getPageSize()
if not rednet.isOpen(m) then
    rednet.open(m)
end
primarch = rednet.lookup("FAXADMN","Primarch")
packet = 
{
    Destination = "",
    From = "",
    DestID = 0,
    FromID = ID,
    message = ""
}
function main()
end
function parseMessage(message,from)
end