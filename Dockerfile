FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

ARG OPENFANG_REF=latest
RUN curl -fsSL https://openfang.sh/install | sh

VOLUME ["/data"]
EXPOSE 4200
ENV OPENFANG_DATA_DIR=/data
RUN ln -s /data /root/.openfang

ENTRYPOINT ["openfang"]
CMD ["start"]
