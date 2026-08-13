FROM python:3.11-slim

WORKDIR /app

# Git ve SSL sertifikalarını yükle
RUN apt-get update && apt-get install -y git ca-certificates && update-ca-certificates && rm -rf /var/lib/apt/lists/*

# Orijinal VirusTotal MCP paketini doğrudan GitHub'dan yükle
RUN pip install --no-cache-dir git+https://github.com/barvhaim/virustotal-mcp-server.git

ENV MCP_TRANSPORT=stdio

ENTRYPOINT ["python", "-m", "virustotal_mcp"]
