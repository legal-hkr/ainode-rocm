FROM debian:bookworm-slim

ARG user_uid
ARG user_gid
ARG render_gid
ARG video_gid

WORKDIR /home/user

# Fix GIDs for groups to match host
RUN groupmod -g $user_gid users
RUN groupadd -g $render_gid render
RUN groupmod -g 14 sudo
RUN groupmod -g $video_gid video

RUN useradd -u $user_uid -r -g users -G render,video -s /sbin/nologin -m -c "User" user

RUN apt-get update && apt-get dist-upgrade -y && apt-get install --no-install-recommends -y build-essential curl git gnupg python3-dev python3-venv python3-pip vim

# Add ROCm repository
RUN mkdir --parents --mode=0755 /etc/apt/keyrings
RUN curl -sL https://repo.radeon.com/rocm/rocm.gpg.key | gpg --dearmor | tee /etc/apt/keyrings/rocm.gpg > /dev/null
RUN echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/amdgpu/6.4.2/ubuntu jammy main" | tee /etc/apt/sources.list.d/amdgpu.list
RUN echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/6.4.2 jammy main" | tee --append /etc/apt/sources.list.d/rocm.list
RUN echo 'Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600' | tee /etc/apt/preferences.d/rocm-pin-600

# Install ROCm
RUN apt-get update && apt-get install --no-install-recommends -y rocm-dev rocm-libs

# Install Ollama
RUN curl -fsSL https://ollama.com/download/ollama-linux-amd64.tgz | tar zx -C /usr
RUN curl -fsSL https://ollama.com/download/ollama-linux-amd64-rocm.tgz | tar zx -C /usr
RUN chmod +x /usr/bin/ollama

# Prepare the runtime environment
RUN chown -R user:users /home/user

ENV HOME="/home/user"
ENV OLLAMA_HOST="0.0.0.0"
ENV OLLAMA_NOHISTORY=true
ENV OLLAMA_TMPDIR="/home/user/tmp"

USER user

ENTRYPOINT ["ollama"]
CMD ["serve"]
