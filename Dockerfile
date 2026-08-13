FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# uv paket yöneticisini yükle
RUN pip install --no-cache-dir uv

COPY . /app

# Bağımlılıkları uv ile sistem seviyesinde kur
RUN uv pip install --system .

ENTRYPOINT ["python", "-m", "virustotal_mcp"]
