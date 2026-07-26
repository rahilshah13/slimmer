- **Build**: `docker build --build-arg APP_CMD="python3 -m http.server 8000" --build-arg HEALTHCHECK_CMD="wget -qO- http://localhost:8000 > /dev/null 2>&1" -t slim-python:unslim .`
- **Trace**: `docker run --rm -v alpine-vol:/mnt/data slim-python:unslim`
- **Slim**: `docker build --build-arg APP_CMD="python3 -m http.server 8000" --build-arg HEALTHCHECK_CMD="wget -qO- http://localhost:8000 > /dev/null 2>&1" -t slim-python:slim .`
- **Run slimmer image**: `docker run --rm -p 8000:8000 -v alpine-vol:/mnt/data slim-python:slim`

--- 

- `docker images --format "{{.Repository}}:{{.Tag}}\t{{.Size}}" | grep slim-python`
