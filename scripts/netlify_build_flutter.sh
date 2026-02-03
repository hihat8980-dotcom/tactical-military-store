#!/bin/bash

set -e

echo "✅ Installing Flutter..."

# تحميل Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# إضافة Flutter إلى PATH
export PATH="$PWD/flutter/bin:$PATH"

# تأكيد نسخة Flutter
flutter --version

echo "✅ Running Flutter build..."

flutter clean
flutter pub get
flutter build web --release

echo "✅ Flutter Web Build Finished Successfully"
