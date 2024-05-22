FROM docker.io/python:alpine as base
ENV PYTHONUNBUFFERED 1

RUN apk add --no-cache --upgrade \
        ca-certificates \
        tzdata && \
    rm -rf /var/cache/apk/*

FROM base as builder

RUN apk add --no-cache --upgrade \
        build-base \
        libffi-dev \
        rust \
        cargo

COPY pendulum-3.0.0-py3-none-any.whl .

ADD https://raw.githubusercontent.com/Flexget/Flexget/develop/requirements.txt .

RUN pip install -U pip && \
    pip install --no-cache-dir --find-links=./ -r requirements.txt

ADD https://api.github.com/repos/Flexget/Flexget/releases/latest .

RUN pip install --no-cache-dir FlexGet

FROM base

COPY --from=builder /usr/local /usr/local

VOLUME /config
WORKDIR /config

COPY start.sh /
RUN chmod +x /start.sh
CMD ["/start.sh"]
