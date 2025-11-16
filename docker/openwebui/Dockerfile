FROM archlinux

ARG user_uid
ARG user_gid

# Settings
ENV ENV="prod"
ENV WEBUI_SECRET_KEY=""
ENV HF_HOME="/home/user/app/backend/data/embedding/models"
ENV SENTENCE_TRANSFORMERS_HOME="/home/user/app/backend/data/embedding/models"
ENV TIKTOKEN_ENCODING_NAME="cl100k_base"
ENV TIKTOKEN_CACHE_DIR="/home/user/app/backend/data/cache/tiktoken"

## LLM Backend
ENV OLLAMA_BASE_URL="http://ainode-ollama:11434"
ENV OPENAI_API_BASE_URL=""
ENV OPENAI_API_KEY=""

## Telemetry, mostly for dependencies
ENV SCARF_NO_ANALYTICS="true"
ENV DO_NOT_TRACK="true"
ENV ANONYMIZED_TELEMETRY="false"

## Whisper
ENV WHISPER_MODEL="base"
ENV WHISPER_MODEL_DIR="/home/user/app/backend/data/whisper/models"

## RAG
#ENV RAG_EMBEDDING_ENGINE="http://ainode-ollama:11434"
ENV RAG_EMBEDDING_MODEL="sdadas/stella-pl-retrieval"
ENV RAG_RERANKING_MODEL="sdadas/polish-reranker-roberta-v2"

## ChromaDB, we're going to use separate instance of ChromaDB
ENV CHROMA_HTTP_HOST="ainode-chroma"
ENV CHROMA_HTTP_PORT="8000"
ENV CHROMA_HTTP_HEADERS="User-Agent=OpenWebUI"
ENV CHROMA_HTTP_SSL=false

## Disable authentication
ENV DEFAULT_USER_ROLE="admin"
ENV ENABLE_SIGNUP="false"
ENV WEBUI_AUTH="true"

WORKDIR /home/user/app

# Fix GIDs for groups to match host
RUN groupmod -g $user_gid users

# Add a user
RUN useradd -u $user_uid -r -g users -s /sbin/nologin -m -c "User" user

# Install dependencies
RUN pacman -Syu --noconfirm && pacman -S --noconfirm apache ffmpeg git npm python-pipenv sqlite vim

# Prepare the runtime environment
RUN chown -R user:users /home/user

USER user

RUN git clone https://github.com/open-webui/open-webui /home/user/app

# Even with anonymized telemetry disabled, set the user_id to zeros, just in case
RUN mkdir -p /home/user/app/.cache/chroma
RUN echo -n 00000000-0000-0000-0000-000000000000 > /home/user/app/.cache/chroma/telemetry_user_id

# Prepare Python virtual environment
RUN python -m venv /home/user/venv
ENV PATH="/home/user/venv/bin:$PATH"
RUN pip install virtualenv --no-cache-dir
RUN pip install --upgrade pip setuptools GitPython --no-cache-dir

# Install backend dependencies
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu --no-cache-dir
## Fix matching distribution error for rapidocr-onnxruntime
RUN sed -i 's/rapidocr-onnxruntime==1.4.4/rapidocr-onnxruntime/g' /home/user/app/backend/requirements.txt
RUN pip install -r /home/user/app/backend/requirements.txt --no-cache-dir
## Fix audioop missing (deprecated as of Python 3.13), see https://github.com/jiaaro/pydub/issues/725#issuecomment-2439291764
RUN pip install audioop-lts hf_xet --no-cache-dir
RUN python -c "import os; from sentence_transformers import SentenceTransformer; SentenceTransformer(os.environ['RAG_EMBEDDING_MODEL'], device='cpu')"
RUN python -c "import os; from faster_whisper import WhisperModel; WhisperModel(os.environ['WHISPER_MODEL'], device='cpu', compute_type='int8', download_root=os.environ['WHISPER_MODEL_DIR'])"
RUN python -c "import os; import tiktoken; tiktoken.get_encoding(os.environ['TIKTOKEN_ENCODING_NAME'])"

# Build frontend
## "--force" is a workaround for the dependency resolving issue, see https://github.com/open-webui/open-webui/issues/15880
RUN npm ci --force
RUN npm run build

CMD ["sh", "./backend/start.sh"]
