FROM python:3.12-slim

# docker CLI only; the daemon is the host's, via the mounted socket
COPY --from=docker:cli /usr/local/bin/docker /usr/local/bin/docker
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

# Dependencies first so this layer caches between code changes
COPY pyproject.toml uv.lock agent_install_version.py helpers.py softwares.csv ./

RUN uv sync --frozen --no-install-project

ENTRYPOINT ["uv", "run", "python", "agent_install_version.py"]
CMD ["softwares.csv"]
