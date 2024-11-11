FROM python:3.9-slim

# Set environment variables
ENV VLLM_TARGET_DEVICE=cpu

# Install dependencies
RUN apt-get update -y && \
    apt-get install -y gcc-12 g++-12 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 10 --slave /usr/bin/g++ g++ /usr/bin/g++-12

# Upgrade pip and install required Python packages
RUN pip install --upgrade pip && \
    pip install wheel packaging ninja "setuptools>=49.4.0" numpy

# Copy the vLLM repository into the container
COPY ./vllm ./vllm

WORKDIR ./vllm

# Install Python dependencies and build vLLM
RUN pip install -v -r requirements-cpu.txt --extra-index-url https://download.pytorch.org/whl/cpu
RUN python setup.py install

# Expose the web server on port 8432
EXPOSE 8432

# Run the OpenAI-compatible web server
CMD ["python", "vllm/entrypoints/openai/api_server.py"]