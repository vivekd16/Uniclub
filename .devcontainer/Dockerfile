FROM debian:bullseye

# Basic dependencies
RUN apt-get update && apt-get install -y \
    bash curl git unzip xz-utils zip libglu1-mesa wget gnupg \
    && apt-get clean

# Install Google Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /usr/share/keyrings/google-linux-signing-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-signing-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update && apt-get install -y google-chrome-stable

# Install Flutter
ENV FLUTTER_VERSION=3.22.1
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter \
    && /usr/local/flutter/bin/flutter doctor

ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Set Flutter web target
ENV CHROME_EXECUTABLE=/usr/bin/google-chrome

# Enable web and precache
RUN flutter config --enable-web && flutter precache
