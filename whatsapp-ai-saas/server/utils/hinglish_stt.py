# import io
# import traceback
# import os
# import librosa
# import numpy as np
# import soundfile as sf
# import torch
# from transformers import Wav2Vec2ForCTC, Wav2Vec2Processor

# print("[STT] Loading Hindi Wav2Vec2 model (first load may take ~30s)...")
# HF_TOKEN = os.getenv("HUGGINGFACE_HUB_TOKEN")

# print("[STT] Loading Hindi Wav2Vec2 model (first load may take ~30s)...")
# try:
#     processor = Wav2Vec2Processor.from_pretrained(
#         "ai4bharat/indicwav2vec-hindi",
#         token=HF_TOKEN
#     )
#     model = Wav2Vec2ForCTC.from_pretrained(
#         "ai4bharat/indicwav2vec-hindi",
#         token=HF_TOKEN
#     )
#     model.eval()  # good practice for inference
#     if torch.cuda.is_available():
#         model = model.to("cuda")
#         print("[STT] Model moved to GPU")
# except Exception as e:
#     print(f"[STT] ❌ Failed to load model: {e}")
#     traceback.print_exc()
#     processor = None
#     model = None
# # processor = Wav2Vec2Processor.from_pretrained("ai4bharat/indicwav2vec-hindi")
# # model = Wav2Vec2ForCTC.from_pretrained("ai4bharat/indicwav2vec-hindi")


# def transcribe_hinglish(audio_bytes: bytes) -> str:
#     """
#     Convert raw audio bytes (ogg, mp3, wav, etc.) to text using Wav2Vec2.
#     This version avoids saving any file to disk.
#     """
#     try:
#         audio_buffer = io.BytesIO(audio_bytes)
#         speech, rate = librosa.load(audio_buffer, sr=16000, mono=True)

#         print(f"[STT] Audio loaded: {len(speech)} samples at {rate} Hz")

#         # Model inference
#         input_values = processor(speech, sampling_rate=16000, return_tensors="pt", padding=True).input_values
#         with torch.no_grad():
#             logits = model(input_values).logits

#         predicted_ids = torch.argmax(logits, dim=-1)
#         text_dev = processor.batch_decode(predicted_ids)[0].strip()

#         print(f"[STT] Transcription (DEV): {text_dev}")

#         return text_dev

#     except Exception as e:
#         print(f"[STT] Unexpected error: {e}")
#         traceback.print_exc()
#         return ""
