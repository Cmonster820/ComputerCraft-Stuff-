p = peripheral.find("printer")
m = peripheral.find("modem")
name = "end1"
rednet.host("FAX",name)
rednet.host("FAXint",name)
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
    local selected = false
    local dest = 0
    local destn = ""
    while not selected do
        print("Where do you want to send a message")
        print(rednet.lookup("FAX"))
        local input = tonumber(read())
        rednet.send(input,"Name?","FAXint")
        local source,message = rednet.receive("FAXint")
        if source~=input then
            error("Something's wrong, security compromised")
        end
        ::reconfirm::
        print("You have selected: "..message.."\nIs this correct? (Y/N)")
        local conf = read()
        if conf=="N" then
            print("Resetting...")
        elseif conf == "Y" then
            print("Confirmed")
            selected = true
            dest = input
            destn = message
        else
            print("Invalid response, retrying")
        end
    end
    
end
function parseMessage(message,from)
end
function listener()
end
