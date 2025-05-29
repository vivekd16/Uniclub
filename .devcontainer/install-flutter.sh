#!/bin/bash
# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter

# Add Flutter to PATH
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> $HOME/.bashrc
export PATH="$HOME/flutter/bin:$PATH"

# Enable Flutter web (optional)
flutter config --enable-web

# Run Flutter doctor
flutter doctor
