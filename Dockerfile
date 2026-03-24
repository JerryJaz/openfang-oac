# ─────────────────────────────────────────────────────────────────
# Stage 1: Build OpenFang from source
# ─────────────────────────────────────────────────────────────────
FROM rust:1.75-slim AS builder

# System deps for SQLite (bundled) + Wasmtime + TLS
RUN apt-get update && apt-get install -y \
    git \
    pkg-config \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Clone upstream source — pin to a tag for reproducibility,
# or use main for always-latest. GitHub Actions workflow below
# will rebuild on each new upstream release.
ARG OPENFANG_REF=main
RUN git clone --depth 1 --branch ${OPENFANG_REF} \
    https://github.com/RightNow-AI/openfang.git .

# Use the release-fast profile for faster CI builds.
# Switch to --release for production images.
RUN cargo build --profile release-fast -p openfang-cli \
    && cp target/release-fast/openfang /usr/local/bin/openfang

# ─────────────────────────────────────────────────────────────────
# Stage 2: Minimal runtime image
# ─────────────────────────────────────────────────────────────────
FROM debian:bookworm-slim AS runtime

RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy the single binary
COPY --from=builder /usr/local/bin/openfang /usr/local/bin/openfang

# Runtime data directory — mounted as a PVC in Kubernetes
VOLUME ["/data"]

# OpenFang dashboard + API port
EXPOSE 4200

# Config lives in /data so it survives pod restarts
ENV OPENFANG_DATA_DIR=/data

ENTRYPOINT ["openfang"]
CMD ["start"]

