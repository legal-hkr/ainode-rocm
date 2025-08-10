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

# Add ROCm repository
RUN mkdir --parents --mode=0755 /etc/apt/keyrings
RUN curl -sL https://repo.radeon.com/rocm/rocm.gpg.key | gpg --dearmor | tee /etc/apt/keyrings/rocm.gpg > /dev/null
RUN echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/amdgpu/6.4.3/ubuntu jammy main" | tee /etc/apt/sources.list.d/amdgpu.list
RUN echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/6.4.3 jammy main" | tee --append /etc/apt/sources.list.d/rocm.list
RUN echo 'Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600' | tee /etc/apt/preferences.d/rocm-pin-600

# Install ROCm
RUN apt-get update && apt-get install --no-install-recommends -y rocm-dev rocm-libs

# Install required dependencies
RUN apt-get install --no-install-recommends -y espeak-ng espeak-ng-data ffmpeg libsndfile1

# Make sure eSpeakNG data is visible in '/usr/share'
RUN mkdir -p /usr/share/espeak-ng-data
RUN ln -s /usr/lib/*/espeak-ng-data/* /usr/share/espeak-ng-data/

RUN chown -R user:users /home/user

# Kokoro has somewhere hardcoded path to the app, temporary workaround
RUN ln -s /home/user/app /app

USER user

# Prepare Python virtual environment
RUN python3 -m venv /home/user/venv
ENV PATH="/home/user/venv/bin:$PATH"
RUN pip3 install virtualenv --no-cache-dir
RUN pip3 install --upgrade pip setuptools GitPython --no-cache-dir

#Install Kokoro FastAPI dependencies
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.4

# Clone Kokoro FastAPI repository and copy scripts requied to run in Docker to the /app directory
RUN git clone https://github.com/remsky/Kokoro-FastAPI.git /home/user/app
RUN cp docker/scripts/* ./
RUN chmod +x ./*.sh

# Kokoro FastAPI uses UV
RUN pip3 install uv --no-cache-dir
RUN uv venv --python 3.10
RUN uv sync --extra cpu
#RUN uv sync --extra gpu

ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/home/user/app:/home/user/app/api
ENV UV_LINK_MODE=copy
ENV USE_GPU=false

# Download voice model
ENV DOWNLOAD_MODEL=true
RUN if [ "$DOWNLOAD_MODEL" = "true" ]; then \
        pip3 install loguru && \
        python3 ./download_model.py --output api/src/models/v1_0; \
    fi

# Set the target device (gpu|cpu)
ENV DEVICE="cpu"

# Default port is 8880
CMD ["bash", "./entrypoint.sh"]
