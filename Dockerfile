# VirusTotal MCP — Osiris (Archestra) icin HTTP/SSE remote MCP sunucusu
# Kaynak: barvhaim/virustotal-mcp-server (FastMCP tabanli, 8 tool)
# Commit'e SABITLENDI (tedarik zinciri: main branch'e degil, tek bir SHA'ya)
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates \
 && update-ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Bagimliliklar (upstream pyproject ile ayni, pinli)
RUN pip install --no-cache-dir \
      "fastmcp>=2.11.3,<3" \
      "httpx>=0.28.1,<1" \
      "pydantic>=2.11.7,<3" \
      "python-dotenv>=1.1.1,<2"

# Upstream kaynagi TEK DOSYA (main.py) — kurulabilir modul DEGIL.
# Bu yuzden "pip install git+..." + "python -m virustotal_mcp" CALISMAZ
# (hata: No module named virustotal_mcp).
ARG UPSTREAM_SHA=5f2f527caace5ea7464bb01ec9dbb95766b794b4
RUN git clone --quiet https://github.com/barvhaim/virustotal-mcp-server.git /tmp/src \
 && cd /tmp/src \
 && git checkout --quiet "${UPSTREAM_SHA}" \
 && cp /tmp/src/main.py /app/main.py \
 && rm -rf /tmp/src

# Upstream portu 8000'e sabit bagliyor; Render/PaaS $PORT verir.
# Tek satirlik yama: port artik ortam degiskeninden okunuyor (varsayilan 8000).
RUN sed -i 's/port=8000/port=int(os.getenv("PORT", "8000"))/' /app/main.py \
 && grep -q 'os.getenv("PORT"' /app/main.py

# stdio DEGIL: web servisi olarak HTTP konusmali.
# SSE SECILMEDI: Render proxy'si uzun omurlu SSE akisini tutuyor -> /sse hic yanit
# basligi dondurmuyor (curl 20 sn bosuna bekliyor), Osiris de "fetch failed" diyor.
# streamable-http normal istek/yanit oldugu icin proxy arkasinda calisir; uc: /mcp
ENV MCP_TRANSPORT=streamable-http
ENV PORT=8000
EXPOSE 8000

# VIRUSTOTAL_API_KEY imaja GOMULMEZ — calisma aninda ortam degiskeni olarak verilir
# (Render: Environment > Add Secret). Anahtar yoksa uygulama bilerek hata verip durur.
CMD ["python", "main.py"]
