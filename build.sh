echo "============Cleaning project============"
fvm flutter clean

echo "============Fetching dependencies============"
fvm flutter pub get
fvm flutter analyze

echo "============Generating icon============"
fvm dart run flutter_launcher_icons

echo "============Building project============"
fvm flutter build web --release

open -R build/