# AINode (ROCm)

## Description

A self-contained privacy-focused AI stack for interacting with LLMs and Stable Diffusion, leveraging AMD's ROCm toolkit.

## Highlights

A privacy-focused approach is implemented as follows:

*   Telemetry across all components is disabled.
*   Only the primary instance of Open WebUI is authorized to persistently store generated text and images. These can be located within the `data/openwebui/data` directory.
*   The amnesic approach utilizes `tmpfs` for mounting input, output, and cache directories. This configuration necessitates periodic container restarts to prevent excessive RAM consumption.

## Components

This repository contains Docker configuration files for setting up the following components:

*   **Open WebUI:** A versatile web interface for interacting with various AI models. Includes both the default and amnesic (forgetful) instances.
*   **Ollama:** A backend for Large Language Models (LLMs), providing a simple and efficient way to run and manage models.
*   **ComfyUI:** A node-based UI for Stable Diffusion, allowing for complex workflows and customization.
*   **ChromaDB:** A vector database for storing and retrieving embeddings, enabling efficient retrieval-augmented generation (RAG).
*   **Kokoro FastAPI:** A backend for Text-to-Speech (TTS), providing high-quality voice generation.
*   **Nginx:** A reverse proxy server, managing incoming requests and routing them to the appropriate backend services.

## Repository Structure

The repository is organized as follows:

*   `docker` - Contains Dockerfiles for all stack components.
*   `examples` - Contains configuration examples.
*   `compose.yml` - Docker Compose configuration file.

## Prerequisites

*   System with AMD ROCm toolkit installed, the stack was built and tested on Linux.
*   Docker and Docker Compose installed, Podman should work, too.

## Getting Started

Follow these steps to get your AINode stack up and running:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/legal-hkr/ainode-rocm.git ainode
    ```
    This command will download the repository to your local machine. Make sure you have Git installed.

2.  **Create the data directory structure:**
    ```bash
    mkdir -p data/{chroma,comfyui/config,comfyui/custom_nodes,common/models,desktop/home,desktop/home_i3,ollama,openwebui/data,reverseproxy/sites_enabled} ssl
    ```

3.  **Place SSL certificates:**
    Copy the `ainode.crt` and `ainode.key` files into the `ssl` directory. These files are used for secure communication via HTTPS. You can generate your own self-signed certificates or use a certificate from a trusted Certificate Authority (CA), example on how to do that can be found in the `examples/ssl` directory.

4.  **Review and configure Docker Compose files:**
    The `compose.yml` file defines the services (containers) that make up the stack and how they interact. The `Dockerfile` files in `docker/*` directories contain instructions for building the Docker images for each service. Examine the `compose.yml` and `Dockerfile` files to understand the stack's configuration, mainly the reverse proxy configuration in the `data/reverseproxy/sites-enabled` directory. Some examples can be found in the `examples/reverseproxy` directory. You should also set UIDs and GIDs in the `compose.yml` according to your environment. Also, make sure that `ENABLE_SIGNUP` in the `docker/openwebui/Dockerfile` is initially set to `true` so you can create the admin account. You can change it to `false` afterwards.

5.  **Build and run the stack:**
    Navigate to the repository directory and start the Docker containers:
    ```bash
    cd ainode && docker compose up -d
    ```
    The `-d` flag runs the containers in detached mode (in the background). It is highly suggested to run the stack without `-d` at first to monitor the startup process.

6.  **Access the interfaces:**
    *   The standard Open WebUI interface will be accessible via port `443` (HTTPS).
    *   The Amnesic Open WebUI interface will be accessible via port `8443` (HTTPS).
    *   The Ollama API will be accessible on the standard port `11434`.
    
    You can access these interfaces using your web browser or with tools like `curl` or `Postman`.

    To access ComfyUI and Kokoro FastAPI WebUI, you must properly set your DNS configuration or `/etc/hosts` file to reflect the configuration in the `data/reverseproxy/sites-enabled` directory. If you're running AINode on localhost, you can add the following to your `/etc/hosts` file:
    ```configuration
    127.0.0.1   comfyui.localdomain             comfyui
    127.0.0.1   ollama.localdomain              ollama
    127.0.0.1   openwebui.localdomain           openwebui
    127.0.0.1   openwebui-amnesic.localdomain   openwebui-amnesic
    127.0.0.1   kokoro-fastapi.localdomain      kokoro-fastapi
    ```
    With this setup, you can access the components by using the specified hostname in your URL, e.g., `https://comfyui`, `https://openwebui`, etc.
