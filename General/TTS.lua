--objective: create a request to a tts website to say words and then convert that to dfpwm, then say it
--new idea: connect to a server hosted on my spare computer in real life, which receives a message with the text (and maybe some other data) and then uses that to generate a tts file, downloads it, uses ffmpeg to convert to dfpwm, and sends the file to the computer
local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
local decoder = dfpwm.make_decoder()
local ID = rednet.getIdentifier()
local ctype = tonumber(read())
local packet = {
    content = "",
    ctype = 0
}
--Connect to websocket and send message
function sendWsMessage(content, ctype)
    local ws = assert(http.websocket(--[[add in the websocket later]],--[[{message = "Connecting, ID: "..ID}]]), "Websocket unavailable") --ensure websocket is there
    --[[local message,bin = ws.receive()
    assert(bin == false, "Binary response received, not supported")
    assert(message == "Accepted", "Connection declined by server")]]
    print("Sending packet")
    packet.content = content
    packet.ctype = ctype
    ws.send(textutils.serializeJSON(packet))
    print("Done")
    print("Awaiting response")
    local message, bin
    repeat
        message,bin= ws.receive()
    until bin==true
    local file = io.open("data/audio.dfpwm","w+")
    file:write(message)
    file:close()
    packet.content = ""
    packet.ctype = 0
    ws.close()
end
function playFile()
    for chunk in io.lines("data/audio.dfpwm",16*1024) do
        local buffer = decoder(chunk)
        while not speaker.playAudio(buffer) do
            os.pullEvent("speaker_audio_empty")
        end
    end
end
--obtain message
::newthing::
print("What would you like to say?")
local content = read()
print("How would you like it said? (number, 0 for default)")
--types will be added later
local ctype = read()
sendWsMessage(content,ctype)
playFile()
goto newthing