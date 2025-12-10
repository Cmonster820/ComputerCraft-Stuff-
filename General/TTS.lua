--objective: create a request to a tts website to say words and then convert that to dfpwm, then say it
--uses some free tts service I can find
local dfpwm = require("cc.audio.dfpwm")
local speaker = peripheral.find("speaker")
local decoder = dfpwm.make_decoder()

for chunk in io.lines("data/audio.dfpwm",16*1024) do
    local buffer = decoder(chunk)
    while not speaker.playAudio(buffer) do
        os.pullEvent("speaker_audio_empty")
    end
end