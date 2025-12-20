#!/bin/bash

set -euo pipefail

gcs() {
    git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules "$@"
}

echo "########################################"
echo "[INFO] Downloading ComfyUI & Nodes..."
echo "########################################"

mkdir -p /default-comfyui-bundle
cd /default-comfyui-bundle
git clone 'https://github.com/comfyanonymous/ComfyUI.git'
cd /default-comfyui-bundle/ComfyUI
# [修改] 版本控制逻辑
if [ -z "$COMFYUI_VERSION" ] || [ "$COMFYUI_VERSION" = "latest" ]; then
    echo "[INFO] COMFYUI_VERSION is 'latest' or empty. Using the default behavior (Stable Release)."
    # 原有的逻辑：锁定最新的 v* 标签
    git reset --hard "$(git tag | grep -e '^v' | sort -V | tail -1)"
elif [ "$COMFYUI_VERSION" = "master" ]; then
    echo "[INFO] COMFYUI_VERSION is 'master'. Using the latest development code."
    git checkout master
else
    echo "[INFO] Checking out specified version: $COMFYUI_VERSION"
    # 尝试检出指定的 Tag 或 Commit Hash
    git checkout "$COMFYUI_VERSION"
fi

cd /default-comfyui-bundle/ComfyUI/custom_nodes
gcs https://github.com/Comfy-Org/ComfyUI-Manager.git

# Force ComfyUI-Manager to use PIP instead of UV
mkdir -p /default-comfyui-bundle/ComfyUI/user/__manager

cat <<EOF > /default-comfyui-bundle/ComfyUI/user/__manager/config.ini
[default]
use_uv = False
security_level = weak
EOF

echo "########################################"
echo "[INFO] Downloading Models..."
echo "########################################"

# VAE Models
cd /default-comfyui-bundle/ComfyUI/models/vae

aria2c 'https://github.com/madebyollin/taesd/raw/refs/heads/main/taesdxl_decoder.pth'
aria2c 'https://github.com/madebyollin/taesd/raw/refs/heads/main/taesd_decoder.pth'
aria2c 'https://github.com/madebyollin/taesd/raw/refs/heads/main/taesd3_decoder.pth'
aria2c 'https://github.com/madebyollin/taesd/raw/refs/heads/main/taef1_decoder.pth'
