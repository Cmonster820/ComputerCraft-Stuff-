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
    From = name,
    DestID = 0,
    FromID = ID,
    message = "",
    fileExtension = ""
}
function sendFile(dest,destn)
    print("Understood, please type the file path:\n")
    local input = read()
    print("You have selected: "..input.."\nI would ask if this is correct but I don't want to write another confirmation thing so here we go")
    local extensionparser = {}
    for thing in string.gmatch(input,"([^%.]+)") do
        table.insert(extensionparser,thing)
    end
    local extension = extensionparser[2]
    print("Extension isolated: "..extension)
    print("Constructing packet...")
    packet.Destination = destn
    packet.DestID = dest
    local file = io.open(input,"r")
    packet.message = file:read("*a")
    file:close()
    packet.fileExtension = extension
    rednet.send(dest,textutils.serialize(packet),"FAX")
    rednet.send(primarch,textutils.serialize(packet),"FAXADMN")
    packet.fileExtension = ""
    packet.message = ""
    packet.destID = 0
    packet.Destination = ""
end
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
            goto reconfirm
        end
    end
    ::reconf2::
    print("Would you like to send a file or type a message? (1/2)")
    local input = read()
    if input == "1" then
        sendFile(dest,destn)
    elseif input == "2" then
        typeThing(dest,destn)
    else
        print("invalid")
        goto reconf2
    end
end
function parseMessage(message,from)
end
function listener()
end
