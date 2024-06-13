FROM docker.io/python:3.11-alpine as base
ENV PYTHONUNBUFFERED 1

RUN apk add --no-cache --upgrade \
        ca-certificates \
        tzdata

FROM base as builder

RUN apk add --no-cache --upgrade \
        build-base \
        libffi-dev \
        rust \
        cargo

COPY pendulum-3.0.0-py3-none-any.whl .

ADD https://raw.githubusercontent.com/Flexget/Flexget/master/requirements.txt .

RUN pip install -U pip && \
    pip install --no-cache-dir --find-links=./ --user -r requirements.txt

ADD https://raw.githubusercontent.com/Flexget/Flexget/master/flexget/_version.py .

RUN pip install --no-cache-dir --user FlexGet

FROM base

COPY --from=builder /root/.local /usr/local

VOLUME /config
WORKDIR /config

COPY start.sh /
RUN chmod +x /start.sh
CMD ["/start.sh"]
