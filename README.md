# coffee_cart

☕️ Coffee Cart Flutter + Appwrite Cloud 🚀

Welcome! This is a modern Flutter app with Appwrite Cloud authentication. Follow these simple steps to get started! 👇

---

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

## 🎉 Enjoy your Coffee Cart app!

Made with ❤️ by 3boudi & GitHub Copilot
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
