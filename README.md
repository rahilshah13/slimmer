# Slim Python Dockerizer

1. **Build unslim image and run a trace**:
   `docker build --target unslim -t slim-python:unslim . && docker run --rm -v alpine-vol:/mnt/data slim-python:unslim`

2. **Build slimmer image**:
   `docker build --target slim -t slim-python:slim .`

3. **Compare the image sizes**:
   `docker system df -v | grep -E "REPOSITORY|slim-python"`

## Pipeline

```bash
docker volume rm alpine-vol 2>/dev/null || true && docker build --target unslim -t slim-python:unslim . && docker run --rm -v alpine-vol:/mnt/data slim-python:unslim && docker run --rm -v alpine-vol:/mnt/data alpine cat /mnt/data/used_files.txt > used_files.txt && docker build --target slim -t slim-python:slim . && docker system df -v | grep -E "REPOSITORY|slim-python"
```