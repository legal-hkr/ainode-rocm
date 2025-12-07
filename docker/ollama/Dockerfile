FROM archlinux

ARG USER_UID
ARG USER_GID
ARG RENDER_GID
ARG VIDEO_GID

# Ollama specific
ENV HOME="/home/user"
ENV OLLAMA_HOST="0.0.0.0"
ENV OLLAMA_NOHISTORY=true
ENV OLLAMA_TMPDIR="/home/user/tmp"

WORKDIR /home/user

# Fix GIDs for groups to match host
RUN groupmod -g ${USER_GID} users
RUN groupmod -g ${RENDER_GID} render
RUN groupmod -g ${VIDEO_GID} video

# Add a user
RUN useradd -u ${USER_UID} -r -g users -G render,video -s /sbin/nologin -m -c "User" user

# Install dependencies
RUN pacman -Syu --noconfirm && pacman -S --noconfirm ollama-rocm rocm-core vim

# Update paths to include ROCm
ENV ROCM_PATH="/opt/rocm"
ENV PATH="${PATH}:/opt/rocm/bin"

# Prepare the runtime environment
RUN chown -R user:users /home/user

USER user

ENTRYPOINT ["ollama"]
CMD ["serve"]
