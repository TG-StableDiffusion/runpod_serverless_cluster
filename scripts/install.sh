#!/usr/bin/env bash
echo "Deleting Automatic1111 Web UI"
rm -rf /workspace/stable-diffusion-webui

echo "Deleting venv"
rm -rf /workspace/venv

echo "Cloning A1111 repo to /workspace"
cd /workspace
git clone --depth=1 https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

echo "Installing Ubuntu updates"
apt update
apt -y upgrade

echo "Installing bc and aria2 Ubuntu packages"
apt -y install bc aria2

echo "Creating and activating venv"
cd stable-diffusion-webui
python3 -m venv /workspace/venv
source /workspace/venv/bin/activate

echo "Installing Torch"
pip3 install --no-cache-dir torch==2.1.2+cu118 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

echo "Installing xformers"
pip3 install --no-cache-dir xformers==0.0.23.post1 --index-url https://download.pytorch.org/whl/cu118

echo "Installing A1111 Web UI"
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-a1111/main/install-automatic.py
python3 -m install-automatic --skip-torch-cuda-test

echo "Installing RunPod Serverless dependencies"
cd /workspace/stable-diffusion-webui
pip3 install huggingface_hub runpod

echo "Downloading AAM XL Model"
cd /workspace/stable-diffusion-webui/models/Stable-diffusion
aria2c -o aam.safetensors https://civitai.com/api/download/models/303526?type=Model&format=SafeTensor&size=full&fp=fp16

echo "Downloading Juggernaut XL Model"
cd /workspace/stable-diffusion-webui/models/Stable-diffusion
aria2c -o juggernaut.safetensors https://civitai.com/api/download/models/782002?type=Model&format=SafeTensor&size=full&fp=fp16

echo "Downloading DreamShaper XL Model"
cd /workspace/stable-diffusion-webui/models/Stable-diffusion
aria2c -o dreamshaper.safetensors https://civitai.com/api/download/models/351306?type=Model&format=SafeTensor&size=full&fp=fp16

echo "Downloading ArtUniverse Model"
cd /workspace/stable-diffusion-webui/models/Stable-diffusion
aria2c -o artuniverse.safetensors https://civitai.com/api/download/models/968318?type=Model&format=SafeTensor&size=full&fp=fp16

echo "Downloading Upscalers"
mkdir -p /workspace/stable-diffusion-webui/models/ESRGAN
cd /workspace/stable-diffusion-webui/models/ESRGAN
aria2c -o 4x-UltraSharp.pth https://huggingface.co/ashleykleynhans/upscalers/resolve/main/4x-UltraSharp.pth
aria2c -o lollypop.pth https://huggingface.co/ashleykleynhans/upscalers/resolve/main/lollypop.pth

echo "Creating log directory"
mkdir -p /workspace/logs

echo "Installing config files"
cd /workspace/stable-diffusion-webui
rm webui-user.sh config.json ui-config.json
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-a1111/main/webui-user.sh
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-a1111/main/config.json
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-a1111/main/ui-config.json

echo "Starting A1111 Web UI"
deactivate
export HF_HOME="/workspace"
cd /workspace/stable-diffusion-webui
./webui.sh -f
