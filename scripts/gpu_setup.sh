#!/bin/bash

# Setup NVIDIA Container Toolkit for GPU support
# Reference: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html

echo "Installing NVIDIA Container Toolkit..."

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

echo "Configuring Docker runtime..."
sudo nvidia-ctk runtime configure --runtime=docker

echo "Restarting Docker..."
sudo systemctl restart docker

echo "Verifying GPU support..."
sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi

echo "GPU Setup Complete. Remember to label this node in Swarm Manager:"
echo "docker node update --label-add gpu=true <node-id>"
