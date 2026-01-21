#this is the server for "TTS.lua"
#it receives the websocket message, parses it, and then sends it to a tts website, downloading the audio
#and converting it to dfpwm, before sending it back to the computer on the minecraft server
#Google cloud TTS API
import asyncio
import json
import websockets
from google.cloud import texttospeech
import ffmpeg
from websockets.asyncio.server import serve
async def synthesize_message(text):
    client = texttospeech.TextToSpeechClient()
    synthIn = texttospeech.SynthesisInput(text = text)
    #the following 3 blocks are copypasted from google ai (like the rest of this program because I haven't used Python for a real project yet)
    voice = texttospeech.VoiceSelectionParams(
        language_code="en-US", 
        ssml_gender=texttospeech.SsmlVoiceGender.NEUTRAL
    )
    audio_config = texttospeech.AudioConfig(
        audio_encoding=texttospeech.AudioEncoding.MP3
    )
    #synth response
    response = client.synthesize_speech(
        input=synthIn, voice=voice, audio_config=audio_config
    )
    with open("C:/CCTTS/"+text+".mp3","wb") as out:
        out.write(response.audio_content)
    print(f"Audio written to: C:/CCTTS/{text}.mp3")
    #differs from google ai here because it didn't have conversion to dfpwm in the same file
    return "C:/CCTTS/"+text+".mp3"
#voice choice decoder goes here, not implemented yet
async def convertMP3DfPWM(audioMP3path,filename):
    ffmpeg.input(audioMP3path).output(filename,ac=1,acodec='dfpwm',ar='48k').run()
    print(f"Audio conversion complete, output written to:\n {filename}")
    with open(filename,"rb") as infile:
        DfPWM = infile.read()
    return DfPWM
#handle websocket
async def websocket_handler(websocket):
    async for message in websocket:
        if isinstance(message, str):
            jmess = json.loads(message,object_hook=lambda d: SimpleNamespace(**d))
            content = jmess.content
            ctype = jmess.ctype
            print(f"Received message: {content}")
            audioMP3path = await synthesize_message(content)
            audioDfPWM = await convertMP3DfPWM(audioMP3path,"C:/CCTTS/"+content+".dfpwm")
            websocket.send(audioDfPWM)
        elif isinstance(message,bytes):
            pass
#websocket server:
async def main():
    async with serve(websocket_handler, "0.0.0.0", 2460) as server:
        await server.wait_closed()
if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("Server terminated by user.")