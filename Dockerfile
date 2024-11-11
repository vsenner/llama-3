# Use a slim Python image as the base
FROM python:3.9-slim

# Set environment variables
ENV VLLM_TARGET_DEVICE=cpu

# Install system dependencies, including the latest CMake from Kitware
RUN apt-get update -y && \
    apt-get install -y gcc-12 g++-12 git wget && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 10 --slave /usr/bin/g++ g++ /usr/bin/g++-12 && \
    # Add Kitware APT repository for the latest CMake
    wget -qO - https://apt.kitware.com/keys/kitware-archive-latest.asc | gpg --dearmor -o /usr/share/keyrings/kitware-archive-keyring.gpg && \
    echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main' | tee /etc/apt/sources.list.d/kitware.list > /dev/null && \
    apt-get update && \
    apt-get install -y cmake && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip and install additional required Python packages
RUN pip install --upgrade pip && \
    pip install wheel packaging ninja "setuptools>=61.0.0" numpy setuptools_scm

# Copy the vLLM repository into the container
COPY ./vllm /vllm

# Set the working directory to /vllm
WORKDIR /vllm

# Install Python dependencies for the project from requirements file
RUN pip install -v -r requirements-cpu.txt --extra-index-url https://download.pytorch.org/whl/cpu

# Create a dummy version file to avoid relying on .git metadata (if the repo lacks a .git directory)
RUN echo "0.1.0" > version.txt

# Build and install the vLLM package
RUN python setup.py install

# Expose the web server on port 8432
EXPOSE 8432

# Run the OpenAI-compatible web server
CMD ["python", "vllm/entrypoints/openai/api_server.py"]
