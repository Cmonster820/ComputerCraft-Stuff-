#this is the server for "TTS.lua"
#it receives the websocket message, parses it, and then sends it to a tts website, downloading the audio
#and converting it to dfpwm, before sending it back to the computer on the minecraft server
#Google cloud TTS API
import asyncio
import websockets
from google.cloud import texttospeech
import ffmpeg
async def synthesize_message(text):
    client = texttospeech.TextToSpeechClient()
    sythIn = texttospeech.SynthesisInput(text = text)
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
        input=synthesis_input, voice=voice, audio_config=audio_config
    )
    with open("C:/CCTTS/"+text+".mp3","wb") as out:
        out.write(response.audio_content)
    print(f"Audio written to: C:/CCTTS/{text}.mp3")
    #differs from google ai here because it didn't have conversion to dfpwm in the same file
    return response
#voice choice decoder goes here, not implemented yet
async def convertMP3DfPWM(audioMP3,filename):
    try:
        (
            ffmpeg
            .input(audioMP3)
            .output(filename)
        )
async def websocket_listener():
    uri = ""#haven't set this up yet
    async with websockets.connect(uri) as websocket:
        print("Waiting for message...")
        async for message in websocket:
            print(f"Received message: {message}")
            audioMP3 = await synthesize_message(message)
            audioDfPWM = await convertMP3DfPWM(audioMP3,"C:/CCTTS/"+message+".dfpwm")