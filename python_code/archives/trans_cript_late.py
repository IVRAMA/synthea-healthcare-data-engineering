# import whisper
from faster_whisper import WhisperModel
import yaml
import tqdm  # pip install tqdm
from pathlib import Path
import time

# with open("audio_config.yaml", "r") as f:
#     config = yaml.safe_load(f)

# model = whisper.load_model("base")
# result = model.transcribe(config["paths"]["audio_file"])
# print(result["text"])

# with open(config["paths"]["dest_file"], "w", encoding="utf-8") as f:
#     f.write(result["text"])


with open("audio_config.yaml", "r") as f:
    config = yaml.safe_load(f)

model = WhisperModel("base", device="cpu", compute_type="int8")  # Fastest CPU
segments, info = model.transcribe(config["paths"]["audio_file"], language="te", beam_size=1)

text = ""
for segment in segments:
    text += segment.text + " "

print(text)

with open(config["paths"]["dest_file"], "w", encoding="utf-8") as f:
    f.write(text)