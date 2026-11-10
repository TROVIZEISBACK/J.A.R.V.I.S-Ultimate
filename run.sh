#!/bin/zsh
# Launch JARVIS Mk II. First run creates the virtualenv.
cd "${0:A:h}"
if [ ! -x .venv/bin/python ]; then
  echo "Setting up JARVIS (first run)..."
  if command -v uv >/dev/null; then
    uv venv --managed-python --python 3.12 .venv && uv pip install --python .venv/bin/python -r requirements.txt
  else
    python3 -m venv .venv && .venv/bin/pip install -r requirements.txt
  fi
fi
[ -f .env ] || cp .env.example .env
# JARVIS's voice: Kokoro neural TTS model (~120 MB, first run only). Without it, macOS `say` is used.
if [ ! -s models/voices-v1.0.bin ] || [ ! -s models/kokoro-v1.0.int8.onnx ]; then
  echo "Downloading JARVIS's voice model..."
  mkdir -p models
  for f in kokoro-v1.0.int8.onnx voices-v1.0.bin; do
    [ -s "models/$f" ] || curl -fL --retry 3 -o "models/$f.part" \
      "https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/$f" && mv "models/$f.part" "models/$f"
  done
fi
exec .venv/bin/python -m jarvis.main
