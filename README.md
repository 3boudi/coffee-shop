# ☕️ Coffee Cart - Modern Flutter App with Appwrite

A beautiful, modern Flutter coffee cart application with stunning animations, glassmorphism UI, and Appwrite Cloud authentication.

## ✨ Features

- 🎨 **Modern UI/UX Design** - Glassmorphism effects and smooth animations
- 🔐 **Secure Authentication** - Powered by Appwrite Cloud
- 📱 **Responsive Design** - Works perfectly on all screen sizes
- ⚡ **Smooth Animations** - Enhanced user experience with fluid transitions
- 🌙 **Dark Theme** - Beautiful gradient backgrounds
- 🔄 **Real-time Validation** - Instant form feedback

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.9.2 or higher)
- **Dart SDK** (included with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Git** for version control
- **Appwrite Cloud Account** ([Sign up free](https://cloud.appwrite.io))

## 📦 Required Flutter Packages

This project uses the following packages for enhanced functionality:

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.1.2
  appwrite: ^17.0.0
```

### Animation & UI Packages
```yaml
  flutter_animate: ^4.5.0      # Advanced animations
  animated_text_kit: ^4.2.2    # Animated text effects
  glassmorphism: ^3.0.0        # Glassmorphism UI effects
  lottie: ^3.1.2               # Lottie animations
```

## 🚀 Installation & Setup

### 1️⃣ Clone the Repository
```bash
git clone <your-repository-url>
cd coffee_cart
```

### 2️⃣ Install Flutter Dependencies
```bash
flutter clean
flutter pub get
```

### 3️⃣ Set up Appwrite Cloud

#### Create Appwrite Project
1. Go to [Appwrite Console](https://cloud.appwrite.io)
2. Click ➕ **Create Project**
3. Enter project name: `Coffee Cart`
4. Copy your **Project ID** (you'll need this later)

#### Add Android Platform
1. In your Appwrite project, go to **Settings** → **Platforms**
2. Click **Add Platform** → **Android**
3. **Package Name:** `com.example.coffee_cart`
4. **SHA1/SHA256 Fingerprint:** Run this command in your project root:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Copy the `SHA1` or `SHA256` from the debug keystore and paste it in Appwrite

#### Configure OAuth (Optional)
- **Callback URL:** `appwrite-callback://com.example.coffee_cart`

### 4️⃣ Configure the App

Open `lib/main.dart` and update these constants with your Appwrite project details:

```dart
const kAppwriteEndpoint = 'https://cloud.appwrite.io/v1';
const kAppwriteProjectId = 'YOUR_PROJECT_ID_HERE'; // Replace with your actual Project ID
```

### 5️⃣ Android Permissions

Ensure your `android/app/src/main/AndroidManifest.xml` includes internet permission:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <!-- ... rest of your manifest -->
</manifest>
```

### 6️⃣ Run the Application

```bash
# For Android
flutter run

# For specific device
flutter devices
flutter run -d <device-id>

# For release build
flutter build apk --release
```

## 📱 Package Installation Commands

### Install all packages at once:
```bash
flutter pub add appwrite provider flutter_animate animated_text_kit glassmorphism lottie cupertino_icons
flutter pub get
```

### Or install packages individually:
```bash
# Core authentication
flutter pub add appwrite
flutter pub add provider

# Animation packages
flutter pub add flutter_animate
flutter pub add animated_text_kit
flutter pub add lottie

# UI enhancement
flutter pub add glassmorphism
flutter pub add cupertino_icons

# Get all dependencies
flutter pub get
```

## 🎨 UI/UX Features

### Modern Login Page Includes:
- **Glassmorphism Card Design** - Translucent glass-like effects
- **Animated Background** - Floating gradient circles
- **Typewriter Text Animation** - Dynamic app title
- **Smooth Form Transitions** - Elastic slide animations
- **Interactive Elements** - Hover effects and micro-interactions
- **Form Validation** - Real-time input validation
- **Loading States** - Animated loading indicators
- **Error Handling** - Beautiful error message displays

### Animation Details:
- **Entry Animations** - Staggered form field appearances
- **Button Interactions** - Scale animations on press
- **Mode Switching** - Smooth transitions between login/register
- **Background Motion** - Continuous floating elements
- **Text Effects** - Typewriter and fade animations

## 🛠️ Development Commands

```bash
# Clean build files
flutter clean

# Get dependencies
flutter pub get

# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Build APK
flutter build apk

# Build for iOS (macOS only)
flutter build ios

# Analyze code
flutter analyze

# Run tests
flutter test
```

## 🔧 Troubleshooting

### Common Issues:

#### 1. **Package Version Conflicts**
```bash
flutter pub deps
flutter pub upgrade
```

#### 2. **Appwrite Authentication Errors**
- Verify Project ID and endpoint URL
- Check Android package name matches Appwrite platform settings
- Ensure SHA1/SHA256 fingerprint is correctly added
- Verify internet permissions in AndroidManifest.xml

#### 3. **Animation Performance Issues**
- Test on physical device rather than emulator
- Reduce animation complexity if needed
- Check device performance capabilities

#### 4. **Build Errors**
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

#### 5. **Gradle Issues (Android)**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

## 📚 Package Documentation

- **[Flutter Animate](https://pub.dev/packages/flutter_animate)** - Advanced animation library
- **[Animated Text Kit](https://pub.dev/packages/animated_text_kit)** - Text animation effects
- **[Glassmorphism](https://pub.dev/packages/glassmorphism)** - Glass morphism UI components
- **[Lottie](https://pub.dev/packages/lottie)** - Lottie animation support
- **[Appwrite](https://pub.dev/packages/appwrite)** - Appwrite Flutter SDK
- **[Provider](https://pub.dev/packages/provider)** - State management

## 🌟 App Structure

```
lib/
├── main.dart                 # App entry point
├── pages/
│   ├── login_page.dart      # Modern animated login page
│   └── home_page.dart       # Main app content
└── [other files...]
```

## 🎯 Next Steps

1. **Customize Colors** - Modify gradient colors in login_page.dart
2. **Add More Animations** - Explore flutter_animate features
3. **Implement Features** - Add coffee cart functionality
4. **Test on Devices** - Test animations on various devices
5. **Deploy** - Build and distribute your app

## 📞 Support

- **Flutter Documentation:** [docs.flutter.dev](https://docs.flutter.dev)
- **Appwrite Documentation:** [appwrite.io/docs](https://appwrite.io/docs)
- **Package Issues:** Check individual package documentation on [pub.dev](https://pub.dev)

## 🎉 Enjoy Your Modern Coffee Cart App!

Made with ❤️ using Flutter and enhanced with beautiful animations and modern UI design.

---

<<<<<<< HEAD
## 1️⃣ Prerequisites
- Flutter SDK (3.9+)
- Appwrite Cloud account 
- Android device (real or emulator)

---

[Appwrite Console](https://cloud.appwrite.io)
	 - Click ➕ to create a new project
	 - Copy your **Project ID** (e.g. `project id here`)

2. **Add Android Platform**
	 - In your Appwrite project, go to **Platforms** → **Add Platform** → **Android**
	 - **Package Name:** `com.example.coffee_cart`
	 - **SHA1/SHA256:** Run this in your project folder:
		 ```sh
		 ./gradlew signingReport
		 ```
		 - Copy the `SHA1` or `SHA256` from the output and paste it in Appwrite

3. **Set OAuth Callback**
	 - Callback URL: `appwrite-callback://com.example.coffee_cart`

---

## 3️⃣ Configure the App 🛠️
- Open `lib/main.dart`
- Set these values:
	```dart
	const kAppwriteEndpoint = 'https://fra.cloud.appwrite.io/v1';
	const kAppwriteProjectId = 'project id here';
	```

---

## 4️⃣ Android Permissions ⚙️
- Open `android/app/src/main/AndroidManifest.xml`
- Make sure you have:
	```xml
	<uses-permission android:name="android.permission.INTERNET"/>
	```

---

## 5️⃣ Run the App ▶️
- On your device:
	```sh
	flutter clean
	flutter pub get
	flutter run
	```
- Login or register with your email & password!

---

## 6️⃣ Troubleshooting 🛟
- **403 Invalid Origin?**
	- Double-check package name & SHA1/SHA256 in Appwrite console
	- Uninstall old app from device, then reinstall
- **Appwrite errors?**
	- Make sure endpoint & project ID are correct
	- Check your internet connection

---

## 7️⃣ Useful Links 🔗
- [Appwrite Docs](https://appwrite.io/docs)
- [Flutter Docs](https://docs.flutter.dev)

---

=======
**Note:** Make sure to replace `YOUR_PROJECT_ID_HERE` in `lib/main.dart` with your actual Appwrite Project ID before running the app.
>>>>>>> 80bd537 (fix login page)
