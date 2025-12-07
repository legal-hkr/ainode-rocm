FROM archlinux

ARG USER_UID
ARG USER_GID
ARG RENDER_GID
ARG VIDEO_GID

WORKDIR /home/user/app

# Fix GIDs for groups to match host
RUN groupmod -g ${USER_GID} users
RUN groupmod -g ${RENDER_GID} render
RUN groupmod -g ${VIDEO_GID} video

# Add a user
RUN useradd -u ${USER_UID} -r -g users -G render,video -s /sbin/nologin -m -c "User" user

# Install dependencies
RUN pacman -Syu --noconfirm && pacman -S --noconfirm base-devel ffmpeg git git-lfs python-pipenv rocm-hip-sdk vim

# Update paths to include ROCm
ENV ROCM_PATH="/opt/rocm"
ENV PATH="${PATH}:/opt/rocm/bin"

RUN chown -R user:users /home/user

USER user

# Make sure Git supports LFS
RUN git lfs install

# Prepare Python virtual environment
RUN python -m venv /home/user/venv
ENV PATH="/home/user/venv/bin:${PATH}"
RUN pip install virtualenv --no-cache-dir
RUN pip install --upgrade pip setuptools GitPython --no-cache-dir

# Install PyTorch for ROCm
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.4 --no-cache-dir

# Install ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /home/user/app

# Install ComfyUI dependencies
RUN pip install -r /home/user/app/requirements.txt --no-cache-dir

# Install some dependencies required by ComfyUI nodes
RUN pip install insightface --no-cache-dir
RUN pip install --use-pep517 facexlib --no-cache-dir
RUN pip install filterpy --no-cache-dir
RUN pip install onnxruntime onnxruntime-gpu --no-cache-dir
RUN pip install opencv-python opencv-python-headless --no-cache-dir
RUN pip install ffmpeg ffmpeg-python --no-cache-dir
RUN pip install accelerate boto3 diffusers dill fal_client ftfy gguf imageio-ffmpeg piexif pykalman redis replicate segment_anything surrealist timm ultralytics --no-cache-dir
RUN pip install matplotlib pydantic==2.* --no-cache-dir
RUN pip install color-matcher --no-cache-dir
RUN pip install huggingface-hub transformers --no-cache-dir
RUN pip install git+https://github.com/facebookresearch/sam2 --no-cache-dir
RUN pip install pywavelets --no-cache-dir

# Sageattention can't find the torch module, skipping the module for now
#RUN pip install sageattention --no-cache-dir

# Build and install bitsandbytes with ROCm support
# See https://huggingface.co/docs/bitsandbytes/main/en/installation#multi-backend
WORKDIR /home/user/bitsandbytes
RUN git clone https://github.com/bitsandbytes-foundation/bitsandbytes.git /home/user/bitsandbytes
RUN HIPCXX="$(hipconfig -l)/clang" HIP_PATH="$(hipconfig -R)" cmake -S . -DCOMPUTE_BACKEND=hip -DBNB_ROCM_ARCH="gfx1100"
RUN make
RUN pip install .
RUN rm -rf /home/user/bitsandbytes
WORKDIR /home/user/app

# ROCm supports bfloat16 since version 6.4.1
# See https://github.com/kasper93/ComfyUI/commit/8d3e5acda351f140fc2b653ffe71bdb14e72e045
RUN sed -i 's/and (not is_amd()) //g' /home/user/app/comfy/model_management.py

# See https://github.com/ROCm/ROCm/issues/4742
ENV MIOPEN_FIND_MODE="2"
ENV TORCH_ROCM_AOTRITON_ENABLE_EXPERIMENTAL="1"

CMD ["python", "./main.py", "--listen", "0.0.0.0", "--port", "8188", "--temp-directory", "/tmp", "--preview-method", "auto"]
