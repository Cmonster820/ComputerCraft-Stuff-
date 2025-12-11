#this is the server for "TTS.lua"
#it receives the websocket message, parses it, and then sends it to a tts website, downloading the audio
#and converting it to dfpwm, before sending it back to the computer on the minecraft server
#Google cloud TTS API
import asyncio
import websockets
from google.cloud import texttospeech
import ffmpeg
#no time to actually write this right now I'll do it later