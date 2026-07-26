#!/bin/sh
MANIFEST="/mnt/data/used_files.txt"

if [ $# -eq 0 ]; then
    set -- $APP_CMD
fi

if [ ! -f "$MANIFEST" ]; then
    echo "==> Phase 1: Tracing file accesses..."
    
    timeout 10s strace -f -e trace=file -o /tmp/strace.log "$@" &
    SERVER_PID=$!
    
    sleep 2
    # Execute the parameterized health check command
    eval "$HEALTHCHECK_CMD"
    
    wait $SERVER_PID 2>/dev/null
    
    awk -F'"' '{print $2}' /tmp/strace.log | while read -r f; do
        [ -e "$f" ] && realpath "$f"
    done | sort -u > "$MANIFEST"
    
    echo "==> Trace complete. Restart container to apply pruning."
    exit 0
fi

echo "==> Phase 2: Purging unused files..."
find /bin /sbin /usr/bin /usr/sbin -type f,l | while read -r file; do
    if ! grep -qxF "$file" "$MANIFEST"; then
        rm -f "$file"
    fi
done

exec "$@"
