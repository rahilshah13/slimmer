#### slimmer
1. **build unslim image and run a trace**:
   `docker build --target unslim -t slim-python:unslim . && docker run --rm -v alpine-vol:/mnt/data slim-python:unslim`

2. **build slimmer image**:
   `docker build --target slim -t slim-python:slim .`

3. **compare image sizes**:
   `docker system df -v | grep -E "REPOSITORY|slim-python"`

#### pipeline

```bash
docker volume rm alpine-vol 2>/dev/null || true && docker build --target unslim -t slim-python:unslim . && docker run --rm -v alpine-vol:/mnt/data slim-python:unslim && docker run --rm -v alpine-vol:/mnt/data alpine cat /mnt/data/used_files.txt > used_files.txt && docker build --target slim -t slim-python:slim . && docker system df -v | grep -E "REPOSITORY|slim-python"
```

---

<img width="1586" height="104" alt="image" src="https://github.com/user-attachments/assets/96b57050-60f0-49df-bc14-cb825cc754dd" />
