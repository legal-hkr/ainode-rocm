FROM debian:bookworm-slim

ARG user_uid
ARG user_gid
ARG render_gid
ARG video_gid

WORKDIR /home/user/app

# Fix GIDs for groups to match host
RUN groupmod -g $user_gid users
RUN groupadd -g $render_gid render
RUN groupmod -g 14 sudo
RUN groupmod -g $video_gid video

RUN useradd -u $user_uid -r -g users -G render,video -s /sbin/nologin -m -c "User" user

RUN apt-get update && apt-get dist-upgrade -y && apt-get install --no-install-recommends -y build-essential curl git gnupg libopencv-dev python3-dev python3-venv python3-pip vim

# ComfyUI requires LFS support for Git and ffmpeg to render videos
RUN apt-get install --no-install-recommends -y ffmpeg git-lfs

# Add ROCm repository
RUN mkdir --parents --mode=0755 /etc/apt/keyrings
RUN curl -sL https://repo.radeon.com/rocm/rocm.gpg.key | gpg --dearmor | tee /etc/apt/keyrings/rocm.gpg > /dev/null
RUN echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/amdgpu/6.4.2/ubuntu jammy main" | tee /etc/apt/sources.list.d/amdgpu.list
RUN echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/6.4.2 jammy main" | tee --append /etc/apt/sources.list.d/rocm.list
RUN echo 'Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600' | tee /etc/apt/preferences.d/rocm-pin-600

# Install ROCm
RUN apt-get update && apt-get install --no-install-recommends -y rocm-dev rocm-libs

# bitsandbytes requires 'cmake' for building with ROCm support
RUN apt-get install --no-install-recommends -y cmake

RUN chown -R user:users /home/user

USER user

# Make sure Git supports LFS
RUN git lfs install

# Prepare Python virtual environment
RUN python3 -m venv /home/user/venv
ENV PATH="/home/user/venv/bin:$PATH"
RUN pip3 install virtualenv --no-cache-dir
RUN pip3 install --upgrade pip setuptools GitPython --no-cache-dir

# Install PyTorch for ROCm
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.4

# Install ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /home/user/app

# Install ComfyUI dependencies
RUN pip3 install -r /home/user/app/requirements.txt --no-cache-dir

# Install some dependencies required by ComfyUI nodes
RUN pip3 install insightface --no-cache-dir
RUN pip3 install --use-pep517 facexlib --no-cache-dir
RUN pip3 install filterpy --no-cache-dir
RUN pip3 install onnxruntime onnxruntime-gpu --no-cache-dir
RUN pip3 install opencv-python opencv-python-headless --no-cache-dir
RUN pip3 install ffmpeg ffmpeg-python --no-cache-dir
RUN pip3 install accelerate boto3 diffusers dill fal_client ftfy gguf imageio-ffmpeg piexif pykalman redis replicate segment_anything surrealist timm ultralytics --no-cache-dir
RUN pip3 install matplotlib pydantic==2.* --no-cache-dir
RUN pip3 install color-matcher --no-cache-dir
RUN pip3 install bitsandbytes huggingface-hub transformers --no-cache-dir
RUN pip3 install pywavelets sageattention --no-cache-dir

# Build and install 'bitsandbytes' with ROCm support
# See https://huggingface.co/docs/bitsandbytes/main/en/installation#multi-backend
RUN pip3 install "transformers>=4.45.1" --no-cache-dir
RUN git clone https://github.com/bitsandbytes-foundation/bitsandbytes.git /home/user/bitsandbytes
WORKDIR /home/user/bitsandbytes
RUN cmake -DCOMPUTE_BACKEND=hip -DBNB_ROCM_ARCH="gfx1100" -S .
RUN make
RUN pip3 install .
RUN rm -rf /home/user/bitsandbytes
WORKDIR /home/user/app

# Using CPU instead of GPU for VAE decoding on a 9950X with RX 7900 XTX makes the decoding 30% faster (sic!)
# If you have a slow CPU, remove "--cpu-vae"

CMD ["python3", "./main.py", "--listen", "--temp-directory", "/tmp", "--preview-method", "auto", "--use-pytorch-cross-attention", "--cpu-vae"]
