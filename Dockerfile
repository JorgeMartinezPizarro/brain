FROM alpine

WORKDIR /root/volumes/

# Build context is DATA_DIR (see make save)
COPY volumes brain
