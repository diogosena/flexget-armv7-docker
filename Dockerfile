FROM docker.io/python:3.11-alpine as builder
ENV PYTHONUNBUFFERED 1

RUN apk add --no-cache --upgrade \
        ca-certificates \
        build-base \
        libffi-dev \
        rust \
        cargo && \
    rm -rf /var/cache/apk/*

# Copie o arquivo .whl para o diretório de cache do pip
COPY pendulum-3.0.0-py3-none-any.whl .

# Atualize o pip e instale as dependências em uma única instrução RUN
RUN pip install -U pip && \
    pip install --no-cache-dir --find-links=./ -r https://raw.githubusercontent.com/Flexget/Flexget/develop/requirements.txt

# Instale o FlexGet em uma camada separada
RUN pip install --no-cache-dir FlexGet

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
