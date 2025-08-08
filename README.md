# openwebui-stack-rocm

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

[Information on how to run the stack will go here]

## Contributing

[Information on how to contribute to the project will go here]
