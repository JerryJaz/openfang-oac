FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

ARG OPENFANG_VERSION=0.5.6
RUN curl -fsSL https://github.com/RightNow-AI/openfang/releases/download/v${OPENFANG_VERSION}/openfang-x86_64-unknown-linux-gnu.tar.gz \
    | tar -xz -C /usr/local/bin/ \
    && chmod +x /usr/local/bin/openfang

VOLUME ["/data"]
EXPOSE 4200
ENV OPENFANG_DATA_DIR=/data
RUN ln -s /data /root/.openfang

ENTRYPOINT ["openfang"]
CMD ["start"]
