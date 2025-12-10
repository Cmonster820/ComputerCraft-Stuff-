--objective: create a request to a tts website to say words and then convert that to dfpwm, then say it
--new idea: connect to a server hosted on my spare computer in real life, which receives a message with the text (and maybe some other data) and then uses that to generate a tts file, downloads it, uses ffmpeg to convert to dfpwm, and sends the file to the computer
local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
local decoder = dfpwm.make_decoder()

for chunk in io.lines("data/audio.dfpwm",16*1024) do
    local buffer = decoder(chunk)
    while not speaker.playAudio(buffer) do
        os.pullEvent("speaker_audio_empty")
    end
end