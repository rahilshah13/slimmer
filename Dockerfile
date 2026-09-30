# syntax=docker/dockerfile:1

# ==========================================
# Stage 1: Unslim (Tracer & Manifest Generator)
# ==========================================
FROM alpine:latest AS unslim

ARG APP_CMD="python3 -m http.server 8000"
ARG HEALTHCHECK_CMD="wget -qO- http://localhost:8000 > /dev/null 2>&1"

ENV APP_CMD="$APP_CMD"
ENV HEALTHCHECK_CMD="$HEALTHCHECK_CMD"

RUN apk update && apk add --no-cache strace findutils coreutils python3 wget
WORKDIR /app

RUN cat << 'EOF' > /app/entrypoint.sh
#!/bin/sh
MANIFEST="/mnt/data/used_files.txt"
[ $# -eq 0 ] && set -- $APP_CMD

if [ ! -f "$MANIFEST" ]; then
    echo "==> Phase 1: Tracing file accesses..."
    timeout 10s strace -f -e trace=file -o /tmp/strace.log "$@" &
    SERVER_PID=$!
    sleep 2
    eval "$HEALTHCHECK_CMD"
    wait $SERVER_PID 2>/dev/null
    awk -F'"' '{print $2}' /tmp/strace.log | while read -r f; do
        [ -e "$f" ] && realpath "$f"
    done | sort -u > "$MANIFEST"
    echo "==> Trace complete. Manifest saved to volume."
    exit 0
fi

exec "$@"
EOF

RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]


# ==========================================
# Stage 2: Pruner (Performs Dynamic Deletion)
# ==========================================
FROM alpine:latest AS pruner

RUN apk update && apk add --no-cache findutils coreutils python3

COPY used_files.txt /tmp/used_files.txt

RUN python3 -c 'import os; manifest = "/tmp/used_files.txt"; keep = set(l.strip() for l in open(manifest)) if os.path.exists(manifest) else set(); whitelist = {"/bin/sh", "/bin/ash", "/bin/busybox", "/bin/cat", "/bin/echo", "/bin/grep", "/bin/rm", "/bin/sed", "/bin/env", "/bin/ln", "/bin/ls", "/lib/ld-musl-x86_64.so.1", "/lib/ld-musl-aarch64.so.1"}; keep.update(whitelist); [os.remove(fp) for base_dir in ["/bin", "/sbin", "/usr/bin", "/usr/sbin", "/lib", "/usr/lib"] if os.path.exists(base_dir) for root, dirs, files in os.walk(base_dir) for file in files if (fp := os.path.join(root, file)) not in keep and (rp := os.path.realpath(fp)) not in keep and file not in {"sh", "ash", "busybox"}]; os.remove(manifest) if os.path.exists(manifest) else None' && \
    find /bin /sbin /usr/bin /usr/sbin /lib /usr/lib -type d -empty -delete 2>/dev/null || true


# ==========================================
# Stage 3: Slim (Pristine Final Image)
# ==========================================
FROM alpine:latest AS slim

ARG APP_CMD="python3 -m http.server 8000"
ENV APP_CMD="$APP_CMD"

COPY --from=pruner / /

WORKDIR /app
ENTRYPOINT ["sh", "-c", "$APP_CMD"]