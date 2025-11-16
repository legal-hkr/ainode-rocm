FROM archlinux

ARG user_uid
ARG user_gid

# Configuration
## Chroma-specific. ChromaDB has to be the same version as in Open WebUI
ARG REBUILD_HNSWLIB
ARG PROTOBUF_VERSION="28.2"
ARG CHROMADB_VERSION="0.6.3"

## Disable telemetry
ENV ANONYMIZED_TELEMETRY="false"

## Set as persistent
ENV IS_PERSISTENT="true"
ENV PERSIST_DIRECTORY="/home/user/app/chroma"

WORKDIR /home/user

# Fix GIDs for groups to match host
RUN groupmod -g $user_gid users

# Add a user
RUN useradd -u $user_uid -r -g users -s /sbin/nologin -m -c "User" user

# Install dependencies
RUN pacman -Syu --noconfirm && pacman -S --noconfirm base-devel git protobuf python-pipenv rust unzip vim

# Prepare the runtime environment
RUN chown -R user:users /home/user

USER user

# Setup venv
RUN python -m venv /home/user/venv
ENV PATH="/home/user/venv/bin:$PATH"
RUN pip install virtualenv --no-cache-dir
RUN pip install --upgrade pip setuptools GitPython --no-cache-dir

# Get ChromaDB
RUN git clone https://github.com/chroma-core/chroma.git /home/user/app
WORKDIR /home/user/app
RUN git checkout ${CHROMADB_VERSION}

# Install ChromaDB's dependencies
RUN pip install cffi fastapi maturin opentelemetry-instrumentation opentelemetry-instrumentation-fastapi patchelf --no-cache-dir
RUN pip install -r /home/user/app/requirements.txt --no-cache-dir
RUN if [ "$REBUILD_HNSWLIB" = "true" ]; then pip install --no-binary :all: --force-reinstall chroma-hnswlib --no-cache-dir; fi
RUN pip install grpcio grpcio-tools --no-cache-dir

# Install ChromaDB
RUN make -C idl proto_python
#RUN python -m maturin build
RUN pip uninstall chromadb -y
RUN pip install --find-links target/wheels/ chromadb --no-cache-dir

# Even with anonymized telemetry disabled, set the user_id to zeros, just in case
RUN mkdir -p /home/user/app/.cache/chroma
RUN echo -n 00000000-0000-0000-0000-000000000000 > /home/user/app/.cache/chroma/telemetry_user_id

ENTRYPOINT ["uvicorn", "chromadb.app:app"]
CMD ["--workers", "1", "--host", "0.0.0.0", "--port", "8000", "--proxy-headers", "--reload", "--log-config", "/home/user/app/chromadb/log_config.yml", "--timeout-keep-alive", "30"]
