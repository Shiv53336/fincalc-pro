## Splash Screen Setup Instructions

### Step 1: Add dependency to pubspec.yaml
```yaml
dev_dependencies:
  flutter_native_splash: ^2.4.3
```

### Step 2: Add this config at the bottom of pubspec.yaml
```yaml
flutter_native_splash:
  color: "#1A365D"
  image: assets/splash_logo.png
  android_12:
    color: "#1A365D"
    image: assets/splash_logo.png
  android: true
  ios: true
```

### Step 3: Create splash logo
- Use the app_icon.svg provided
- Export as PNG at 400x400px (no rounded corners for splash)
- Save as `assets/splash_logo.png`

### Step 4: Create assets directory
```
mkdir -p assets
```
Add to pubspec.yaml:
```yaml
flutter:
  assets:
    - assets/
```

### Step 5: Generate splash screens
```bash
flutter pub get
dart run flutter_native_splash:create
```

This will automatically generate all required splash screen assets
for both Android and iOS at all required resolutions.
