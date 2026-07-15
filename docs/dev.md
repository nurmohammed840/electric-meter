# Rename App

`flutter pub run rename setAppName --value "Electric Meter"`
`flutter pub run rename setBundleId --value com.nur.electric_meter`

# Change Icon

Replace 1024×1024 `assets/icon.png`.

Then run: `flutter pub run flutter_launcher_icons`
cd
# Build

Android: `flutter build apk --release --split-per-abi`
Web: `flutter build web --release --wasm --base-href /electric-meter-app/`
Windows: `flutter build windows --release`
Linux:  `flutter build linux --release`