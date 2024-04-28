import whisper
import torch
import warnings

def transcribe(audio, model, device):
    if not torch.cuda.is_available():
        device = "cpu"
        warnings.warn("GPU not available. Selecting device = \"cpu\"")
    return whisper.load_model(model, device=device).transcribe(audio)
