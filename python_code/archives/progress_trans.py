import whisper
import yaml
from pathlib import Path

print("🚀 **Pipeline Started**")
with open("audio_config.yaml", "r") as f:
    config = yaml.safe_load(f)

audio_path = config["paths"]["audio_file"]  # String path!
dest_file = config["paths"]["dest_file"]
print(f"📁 Audio: {Path(audio_path).name} ({Path(audio_path).stat().st_size/1e6:.1f} MB)")

print("\n📊 **1. Model Load** ⏳")
model = whisper.load_model("base")
print("✅ Model ready!")

print("\n📊 **2. Transcription** [FFmpeg + Whisper] ⏳")
result = model.transcribe(audio_path, language="te", fp16=False, verbose=True)
print("✅ Telugu transcript generated!")

print(f"\n📊 **3. Stats** [{len(result['text'])} chars, {len(result['segments'])} segments] ✅")

print("\n📊 **4. UTF-8 Save** ⏳")
with open(dest_file, "w", encoding="utf-8") as f:
    f.write(result["text"])
print(f"✅ Saved {dest_file}")

print("\n🎯 **PREVIEW** (first 1000 chars):")
print(result["text"][:1000] + "..." if len(result["text"]) > 1000 else result["text"])

print("\n📤 **Paste above for English translation!**")