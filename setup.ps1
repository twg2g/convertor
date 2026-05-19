$ErrorActionPreference = "Stop"
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "Install Flutter and add it to PATH: https://docs.flutter.dev/get-started/install/windows"
}
if (-not (Test-Path "android")) {
    flutter create . --org com.universalconverter --project-name universal_converter
}
flutter pub get
flutter test
Write-Host "Ready. Run: flutter run -d windows"
