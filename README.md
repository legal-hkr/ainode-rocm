# ainode-rocm

## Description

A self-contained privacy-focused AI stack for interacting with LLMs and Stable Diffusion, leveraging AMD's ROCm toolkit.

## Components

This repository contains Docker configuration files and source code for setting up the following components:

*   **Open WebUI:** A versatile web interface for interacting with various AI models. Includes both the default and amnesic (forgetful) instances.
*   **Ollama:** A backend for Large Language Models (LLMs), providing a simple and efficient way to run and manage models.
*   **ComfyUI:** A node-based UI for Stable Diffusion, allowing for complex workflows and customization.
*   **ChromaDB:** A vector database for storing and retrieving embeddings, enabling efficient retrieval-augmented generation (RAG).
*   **Kokoro FastAPI:** A backend for Text-to-Speech (TTS), providing high-quality voice generation.
*   **Nginx:** A reverse proxy server, managing incoming requests and routing them to the appropriate backend services.

## Repository Structure
The repository is organized as follows:

*   `data` - Directory for storing data used by the stack.
*   `docker` - Contains Dockerfiles for all stack components.
*   `ssl` - Contains the SSL certificate and key for the Nginx reverse proxy server.

## Prerequisites

*   System with AMD ROCm toolkit installed, the stack was built and tested on Linux.
*   Docker and Docker Compose installed, Podman should work, too.
## Getting Started

Follow these steps to get your PrivadoAI stack up and running:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/legal-hkr/ainode-rocm.git ainode
    ```
    This command will download the repository to your local machine. Make sure you have Git installed.

2.  **Place SSL certificates:**
    Copy the `server.crt` and `server.key` files into the `ssl` directory. These files are used for secure communication via HTTPS. You can generate your own self-signed certificates or use a certificate from a trusted Certificate Authority (CA).

3.  **Review and configure Docker Compose files:**
    Examine the `compose.yml` and `Dockerfile` files to understand the stack's configuration, mainly the reverse proxy configuration in the `data/reverseproxy/sites-enabled` directory. The `compose.yml` file defines the services (containers) that make up the stack and how they interact. The `Dockerfile` contains instructions for building the Docker images for each service. Example configuration will be provided in the future to simplify the setup process.

4.  **Build and run the stack:**
    Navigate to the repository directory and start the Docker containers:
    ```bash
    cd ainode && docker compose up -d
    ```
    The `-d` flag runs the containers in detached mode (in the background). It is highly suggested to run the stack without `-d` at first to monitor the startup process.

5.  **Access the interfaces:**
    *   The standard Open WebUI interface will be accessible via port `443` (HTTPS).
    *   The Amnesic Open WebUI interface will be accessible via port `8443` (HTTPS).
    *   The Ollama API will be accessible on the standard port `11434`.

    You can access these interfaces using your web browser or with tools like `curl` or `Postman`.
