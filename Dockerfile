FROM python:3.13-alpine3.20
LABEL maintainer="londonappdeveloper.com"

ENV PYTHONUNBUFFERED=1

ARG UID=101
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./scripts /scripts
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
RUN apk add --update --no-cache \
    postgresql-client jpeg-dev zlib-dev libjpeg libjpeg-turbo-dev \
    freetype-dev lcms2-dev openjpeg-dev tiff-dev tk-dev tcl-dev harfbuzz-dev fribidi-dev && \
    python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev zlib zlib-dev linux-headers && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ "$DEV" = "true" ]; then /py/bin/pip install -r /tmp/requirements.dev.txt; fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --uid $UID \
        --disabled-password \
        --no-create-home \
        django-user && \
    mkdir -p /vol/web/media /vol/web/static && \
    chown -R django-user:django-user /vol/web && \
    chmod -R 755 /vol/web && \
    chmod -R +x /scripts

ENV PATH="/scripts:/py/bin:$PATH"

USER django-user

VOLUME /vol/web/media
VOLUME /vol/web/static

CMD ["run.sh"]
