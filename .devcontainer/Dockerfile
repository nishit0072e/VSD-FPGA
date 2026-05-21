FROM mcr.microsoft.com/devcontainers/base:ubuntu

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    make \
    cmake \
    gcc \
    g++ \
    python3 \
    python3-pip \
    verilator \
    yosys \
    gtkwave \
    iverilog \
    flex \
    bison \
    clang \
    device-tree-compiler \
    ninja-build \
    pkg-config \
    libftdi-dev \
    libusb-1.0-0-dev \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip

WORKDIR /workspace