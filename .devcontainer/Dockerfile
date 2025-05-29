FROM debian:bullseye

# Basic dependencies
RUN apt-get update && apt-get install -y \
    bash curl git unzip xz-utils zip libglu1-mesa \
    && apt-get clean

# Install Flutter
ENV FLUTTER_VERSION=3.22.1
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter \
    && /usr/local/flutter/bin/flutter doctor

ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Pre-warm Flutter
RUN flutter config --enable-web && flutter precache
