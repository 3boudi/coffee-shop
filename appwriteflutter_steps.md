Appwrite + Flutter (coffee_cart) — Quick Setup Steps

This file lists the exact steps to connect the `coffee_cart` Flutter app to Appwrite Cloud and verify registration/login flows on a physical Android device.

Values pulled from this project

- Appwrite public endpoint: https://fra.cloud.appwrite.io/v1
- Appwrite project ID: 68bf228300007baa47f9
- Android applicationId / package: com.example.coffee_cart
- Debug signing fingerprints (debug keystore)
  - SHA-256: F6:DA:CB:4C:29:9E:01:60:1B:98:12:2F:3F:91:D8:7F:1E:91:B8:0B:7C:3B:23:E7:B5:1B:7D:3D:38:EE:D6:49
  - SHA1: 04:0C:9D:A6:8E:17:09:17:6F:BD:DB:37:49:2E:4C:8E:C3:EC:2E:4C

What to do in the Appwrite Console

1. Open https://appwrite.io/ and sign in to the Appwrite Console.
2. Select the project with ID: 68bf228300007baa47f9 (or create a new project and use that project ID in `lib/main.dart`).
3. Register an Android Platform:
   - Project → Settings → Platforms → Add Platform → Android
   - Package name: com.example.coffee_cart
   - Signature: paste the SHA-256 fingerprint above (preferred); SHA1 also works if requested.
   - Save the platform entry.
4. Enable Email/Password authentication (if not already enabled):
   - Project → Auth → Providers (or Settings) → toggle Email/Password on.
5. (Optional) Configure OAuth providers and callback URIs if you plan to use Google/Facebook login.

Verify your app code (already set in this project)

- `lib/main.dart`:
  - Uses endpoint: https://fra.cloud.appwrite.io/v1
  - Uses project ID: 68bf228300007baa47f9
- `android/app/src/main/AndroidManifest.xml` contains:
  - `<uses-permission android:name="android.permission.INTERNET" />`
  - Appwrite OAuth `CallbackActivity` with scheme `appwrite-callback-68bf228300007baa47f9`
- `android/app/build.gradle.kts` contains:
  - `applicationId = "com.example.coffee_cart"`

Rebuild and test on a physical device

1. Uninstall any previous debug build of the app from the phone (important to avoid cached signature issues).
2. From your project root (PowerShell on Windows):

```powershell
cd 'c:\Users\SURFUCE\Pictures\flutter\coffee_cart'
flutter clean
flutter pub get
flutter run
```

3. On the device, try Register (provide email/password/name) and then Login. On success you'll see the Home page.

Troubleshooting

- 403 Invalid Origin: means Appwrite blocked the app because the Android platform (package + fingerprint) isn't registered or doesn't match. Fix by adding the correct package name and fingerprint in the Appwrite Console.
- 401 missing scope at startup: normal when no session exists — sign in to create a session. The app treats this as unauthenticated rather than an error.
- DNS/Network errors (e.g., "Failed host lookup"):
  - Try switching to mobile data or a different Wi‑Fi.
  - Disable VPN/Private DNS if used.
  - Confirm your device can reach https://fra.cloud.appwrite.io/v1 in a browser on the device.

Advanced notes

- Release builds: register the release keystore's fingerprint in Appwrite (not the debug keystore). The debug fingerprint above is only for local debug builds created with the Android debug keystore.
- If you change `applicationId`, update the Android platform entry in Appwrite to match and re-run the app.

If you want me to walk you through Appwrite Console clicks or validate the platform entries after you add them, tell me and I will guide you step-by-step.
