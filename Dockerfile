FROM python:3.9-bullseye
LABEL maintaner="Florian Purchess <florian@attacke.ventures>"

RUN apt-get update && \
  apt-get install -y poppler-utils qpdf libfile-mimeinfo-perl libimage-exiftool-perl ghostscript libsecret-1-0 zlib1g-dev libjpeg-dev \
  libreoffice inkscape ffmpeg xvfb \
  libnotify4 libappindicator3-1 curl \
  scribus inkscape \
  libcairo2-dev libpango1.0-dev libgdk-pixbuf2.0-dev libffi-dev pkg-config \
  python3-dev build-essential \
  && rm -rf /var/lib/apt/lists/*

ENV DRAWIO_VERSION="12.6.5"
RUN ARCH=$(dpkg --print-architecture) && \
  if [ "$ARCH" = "amd64" ]; then \
    curl -LO https://github.com/jgraph/drawio-desktop/releases/download/v${DRAWIO_VERSION}/draw.io-amd64-${DRAWIO_VERSION}.deb && \
    dpkg -i draw.io-amd64-${DRAWIO_VERSION}.deb && \
    rm draw.io-amd64-${DRAWIO_VERSION}.deb; \
  else \
    echo "Draw.io not available for architecture $ARCH, skipping..."; \
  fi

WORKDIR /app

RUN pip install --upgrade pip
RUN pip install uvicorn starlette "preview-generator[all]" python-multipart aiofiles

COPY docker-entrypoint.sh /app/
COPY app.py /app/

RUN groupadd -r previewservice && useradd -r -s /bin/false -g previewservice previewservice
RUN chown -R previewservice:previewservice /app
USER previewservice

EXPOSE 8000

CMD ["./docker-entrypoint.sh"]
