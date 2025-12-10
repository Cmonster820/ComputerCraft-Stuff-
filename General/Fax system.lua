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
    ::reconf3::
    print("Understood, please type the file path:\n")
    local input = read()
    ::fixconf::
    print("You have selected: "..input.."\nIs this correct? (Y/N)")
    local conf = read()
    if conf == "N" then
        goto reconf3
    elseif conf == "Y" then
        print("Understood")
    else
        print("Invalid response, please respond with either Y or N")
        goto reconf3
    end
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
function typeThing(dest,destn)
    ::redotype::
    print("You have selected:\nType message")
    print("The message will be terminated with the word \"STOP\" in all caps on its own line")
    local strOut = ""
    local done = false
    repeat
        local input = read()
        strOut = strOut.."\n"..input
        if input=="STOP" then
            done = true
        end
    until done
    ::reconf4::
    print("The message is:\n"..strOut.."\nIs this correct?(Y/N)")
    local input = read()
    if input == "N" then
        print("Understood.")
        goto redotype
    elseif input~="Y" then
        print("Invalid response, please input either Y or N")
        goto reconf4
    end
    packet.message = strOut
    packet.Destination = destn
    packet.destID = dest
    packet.fileExtension = "N/A"
    rednet.send(primarch,textutils.serialize(packet),"FAXADMN")
    rednet.send(dest,textutils.serialize(packet),"FAX")
    packet.message = ""
    packet.Destination = ""
    packet.destID = 0
    packet.fileExtension = ""
    print("Message sent")
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
            break
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
function wrapParse(str)
    local lines = {}
    for line in str:gmatch("([^\n]*)\n?") do
        local curline = ""
        for word in line:gmatch("(%S+)") do
            if #curline+#word+(#curline>0 and 1 or 0)>w then
                lines:insert(curline)
            else
                if #curline==0 then
                    curline = word
                else
                    curline = curline.." "..word
                end
            end
        end
    end
    return lines:concat("\n")
end
function wrapPages(str)
    local _,numnewlines = string.gsub(str,"\n")
    local numlines = numnewlines+1
    local curStr = ""
    local count = 1
    local pages = {}
    for line in str:gmatch("([^\n]*)\n?") do
        count = count+1
        if count>h then
            pages:insert(curStr)
            curStr=""
            count = 1
        end
        if #curStr==0 then
            curStr = line
        else
            curStr = curStr.."\n"..line
        end
    end
    return pages
end
function printMD(str)
    --I'm gonna parse it into html using a separate library and then print that out.
end
function parseMessage(message,from)
    message = textutils.unserialize(message)
    print(("Got a message from %d"):format(from))
    if not p.newPage() then
        error("Insufficient ink or paper")
    end
    if message.fileExtension~=".md" then
        local str = wrapParse(message.data)
        local pages = wrapPages(str)
        local pcount = 1
        for _,page in ipairs(pages) do
            if not p.newPage() then
                repeat
                    print("Insufficient paper or ink")
                until p.newPage()
            end
            p.setPageTitle(os.date().." "..pcount)
            p.write(page)
        end
    else
        printMD(message.data)
    end
end
function listener()
end