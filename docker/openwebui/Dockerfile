FROM debian:bookworm-slim

ARG user_uid
ARG user_gid

## Settings
ENV ENV=prod
ENV WEBUI_SECRET_KEY=""
ENV HF_HOME="/home/user/app/backend/data/embedding/models"
ENV SENTENCE_TRANSFORMERS_HOME="/home/user/app/backend/data/embedding/models"
ENV TIKTOKEN_ENCODING_NAME="cl100k_base"
ENV TIKTOKEN_CACHE_DIR="/home/user/app/backend/data/cache/tiktoken"

# LLM Backend
ENV OLLAMA_BASE_URL="http://ainode-ollama:11434"
ENV OPENAI_API_BASE_URL=""
ENV OPENAI_API_KEY=""

# Telemetry, mostly for dependencies
ENV SCARF_NO_ANALYTICS=true
ENV DO_NOT_TRACK=true
ENV ANONYMIZED_TELEMETRY=false

# Whisper
ENV WHISPER_MODEL="base"
ENV WHISPER_MODEL_DIR="/home/user/app/backend/data/whisper/models"

# RAG
#ENV RAG_EMBEDDING_ENGINE="http://ainode-ollama:11434"
ENV RAG_EMBEDDING_MODEL="sdadas/stella-pl-retrieval"
ENV RAG_RERANKING_MODEL="sdadas/polish-reranker-roberta-v2"

# ChromaDB, we're going to use separate instance of ChromaDB
ENV CHROMA_HTTP_HOST="ainode-chroma"
ENV CHROMA_HTTP_PORT="8000"
ENV CHROMA_HTTP_HEADERS="User-Agent=OpenWebUI"
ENV CHROMA_HTTP_SSL=false

# Disable authentication
ENV DEFAULT_USER_ROLE="admin"
ENV ENABLE_SIGNUP=false
ENV WEBUI_AUTH=true

WORKDIR /home/user/app

# Fix GIDs for groups to match host
RUN groupmod -g $user_gid users
RUN useradd -u $user_uid -r -g users -s /sbin/nologin -m -c "User" user

RUN apt-get update && apt-get dist-upgrade -y && apt-get install --no-install-recommends -y build-essential curl git python3-dev python3-venv python3-pip vim

# Install Open WebUI dependencies. 'apache2-utils' and 'sqlite3' are required for account recovery
RUN apt-get install --no-install-recommends -y apache2-utils ffmpeg libpq-dev sqlite3

# Install NodeJS
RUN apt-get install --no-install-recommends -y gpg
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update && apt-get install -y --no-install-recommends nodejs

# Prepare the runtime environment
RUN chown -R user:users /home/user

USER user

RUN git clone https://github.com/open-webui/open-webui /home/user/app

# Even with anonymized telemetry disabled, set the user_id to zeros, just in case
RUN mkdir -p /home/user/app/.cache/chroma
RUN echo -n 00000000-0000-0000-0000-000000000000 > /home/user/app/.cache/chroma/telemetry_user_id

# Prepare Python virtual environment
RUN python3 -m venv /home/user/venv
ENV PATH="/home/user/venv/bin:$PATH"
RUN pip3 install virtualenv --no-cache-dir
RUN pip3 install --upgrade pip setuptools GitPython --no-cache-dir

# Install backend dependencies
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu --no-cache-dir
RUN pip3 install -r /home/user/app/backend/requirements.txt --no-cache-dir
RUN pip3 install hf_xet
RUN python3 -c "import os; from sentence_transformers import SentenceTransformer; SentenceTransformer(os.environ['RAG_EMBEDDING_MODEL'], device='cpu')"
RUN python3 -c "import os; from faster_whisper import WhisperModel; WhisperModel(os.environ['WHISPER_MODEL'], device='cpu', compute_type='int8', download_root=os.environ['WHISPER_MODEL_DIR'])"
RUN python3 -c "import os; import tiktoken; tiktoken.get_encoding(os.environ['TIKTOKEN_ENCODING_NAME'])"

# Build frontend
# "--force" is a workaround for the dependency resolving issue, see https://github.com/open-webui/open-webui/issues/15880
RUN npm ci --force
RUN npm run build

CMD ["bash", "./backend/start.sh"]
