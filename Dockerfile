FROM python:3.11.7-alpine3.19 as base

ENV LANG=zh_CN.UTF-8 \
    TZ=Asia/Shanghai \
    BILI_IN_DOCKER=true \
    BILI_SYNC_VERSION="dev" \
    REPO_URL="https://github.com/komaedaXnagito/bili-sync" \
    PYPI_MIRROR="https://pypi.tuna.tsinghua.edu.cn/simple" \
    ALPINE_MIRROR="mirrors.ustc.edu.cn" \
    WORKDIR="/app" \
    CONFIG_PATH="/config/config" \
    DATA_PATH="/config/data" \
    THUMB_PATH="/config/thumb"

WORKDIR ${WORKDIR}

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories \
    && apk add --no-cache ffmpeg tini git bash \
    && apk add --no-cache --virtual .build-deps \
        gcc \
        musl-dev \
        libffi-dev \
        openssl-dev \
    && pip install -i https://pypi.tuna.tsinghua.edu.cn/simple poetry==1.7.1 \
    && git config --global pull.ff only \
    && git clone -b ${BILI_SYNC_VERSION} ${REPO_URL} ${WORKDIR} --depth=1 \
    && git config --global --add safe.directory ${WORKDIR} \
    && poetry config virtualenvs.create false \
    && poetry install --only main --no-root \
    && apk del .build-deps \
    && rm -rf \
        /root/.cache \
        /tmp/*

ENTRYPOINT ["tini", "python", "entry.py" ]

VOLUME [ "/config/config", "/config/data", "/config/thumb", "/Videos/Bilibilis" ]