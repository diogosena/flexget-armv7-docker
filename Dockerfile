# Primeiro est�gio: Construir o Flexget
FROM docker.io/python:3.11-alpine as builder
ENV PYTHONUNBUFFERED 1

RUN apk add --no-cache --upgrade \
        ca-certificates \
        build-base \
        libffi-dev \
        rust \
        cargo && \
    rm -rf /var/cache/apk/*

COPY pendulum-3.0.0-py3-none-any.whl .
RUN pip install pendulum-3.0.0-py3-none-any.whl && \
    pip install -U pip && \
    pip install --no-cache-dir FlexGet

# Segundo est�gio: Copiar o Flexget constru�do para a imagem final
FROM docker.io/python:3.11-alpine
ENV PYTHONUNBUFFERED 1

RUN apk add --no-cache --upgrade \
        ca-certificates \
        tzdata && \
    rm -rf /var/cache/apk/*

COPY --from=builder /usr/local /usr/local

VOLUME /config
WORKDIR /config

CMD rm -f /config/.config-lock && flexget daemon start --autoreload-config
