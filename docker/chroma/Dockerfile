FROM debian:trixie-slim

ARG user_uid
ARG user_gid

# Chroma-specific. ChromaDB has to be the same version as in Open WebUI
ARG REBUILD_HNSWLIB
ARG PROTOBUF_VERSION="28.2"
ARG CHROMADB_VERSION="0.6.3"

# Disable telemetry
ENV ANONYMIZED_TELEMETRY=false

# Set as persistent
ENV IS_PERSISTENT=true
ENV PERSIST_DIRECTORY="/home/user/app/chroma"

WORKDIR /home/user

# Fix GIDs for groups to match host
RUN groupmod -g $user_gid users

RUN useradd -u $user_uid -r -g users -s /sbin/nologin -m -c "User" user

RUN apt-get update && apt-get dist-upgrade -y && apt-get install --no-install-recommends -y build-essential curl git gnupg python3-dev python3-venv python3-pip unzip vim

# Install Protobuf compiler at version required by ChromaDB
WORKDIR /tmp
RUN curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip
RUN unzip /tmp/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip -d /usr/local/
RUN chmod +x /usr/local/bin/protoc
RUN rm /tmp/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip

# Prepare the runtime environment
RUN chown -R user:users /home/user

USER user

# Setup venv
RUN python3 -m venv /home/user/venv
ENV PATH="/home/user/venv/bin:$PATH"
RUN pip3 install virtualenv
RUN pip3 install --upgrade pip setuptools GitPython --no-cache-dir

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain stable
ENV PATH="/home/user/.cargo/bin:$PATH"

# Get ChromaDB
RUN git clone https://github.com/chroma-core/chroma.git /home/user/app
WORKDIR /home/user/app
# Latest version at the moment is 1.1.3
RUN git checkout ${CHROMADB_VERSION}

# Install ChromaDB's dependencies
RUN pip3 install cffi fastapi maturin opentelemetry-instrumentation opentelemetry-instrumentation-fastapi patchelf
RUN pip3 install -r /home/user/app/requirements.txt
RUN if [ "$REBUILD_HNSWLIB" = "true" ]; then pip3 install --no-binary :all: --force-reinstall chroma-hnswlib; fi
RUN pip3 install grpcio grpcio-tools

# Install ChromaDB
RUN make -C idl proto_python
#RUN python3 -m maturin build
RUN pip3 uninstall chromadb -y
RUN pip3 install --find-links target/wheels/ chromadb

# Even with anonymized telemetry disabled, set the user_id to zeros, just in case
RUN mkdir -p /home/user/app/.cache/chroma
RUN echo -n 00000000-0000-0000-0000-000000000000 > /home/user/app/.cache/chroma/telemetry_user_id

ENTRYPOINT ["uvicorn", "chromadb.app:app"]
CMD ["--workers", "1", "--host", "0.0.0.0", "--port", "8000", "--proxy-headers", "--reload", "--log-config", "/home/user/app/chromadb/log_config.yml", "--timeout-keep-alive", "30"]
