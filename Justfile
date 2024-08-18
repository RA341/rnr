set shell := ["powershell.exe", "-c"]

iapk:
    flutter build apk --release
    just i
i:
  adb install build\app\outputs\flutter-apk\app-release.apk
