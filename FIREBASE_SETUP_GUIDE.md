# Firebase 403 Error - Setup Guide

## Problem
You're getting a **403 Forbidden** error because your Firebase configuration has placeholder values instead of actual credentials.

## Current Issue in `lib/core/config/firebase_config.dart`:
```dart
appId: '1:YOUR_WEB_APP_ID:web:YOUR_WEB_APP_ID',  // ❌ PLACEHOLDER
messagingSenderId: 'YOUR_SENDER_ID',              // ❌ PLACEHOLDER
```

## Solution: Get Real Firebase Configuration

### Step 1: Go to Firebase Console
1. Visit: https://console.firebase.google.com/
2. Select your project: **mad-project-77dd3**

### Step 2: Get Web App Configuration
1. Click on the **Settings gear icon** (⚙️) → **Project settings**
2. Scroll down to **Your apps** section
3. If you don't have a web app registered:
   - Click **Add app** → Select **Web** (</> icon)
   - Register your app with a nickname (e.g., "COMSATS GPT Web")
   - Check "Also set up Firebase Hosting" if needed
   - Click **Register app**
4. You'll see the Firebase configuration object like this:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyAc_QUqGd27kRgLP9BoQwoD7jDjmT8LONs",
  authDomain: "mad-project-77dd3.firebaseapp.com",
  projectId: "mad-project-77dd3",
  storageBucket: "mad-project-77dd3.appspot.com",
  messagingSenderId: "123456789012",           // ← Real value
  appId: "1:123456789012:web:abcdef123456",    // ← Real value
  measurementId: "G-XXXXXXXXXX"                 // ← Optional
};
```

### Step 3: Get Android App Configuration (if needed)
1. In Project settings → Your apps
2. Click **Add app** → Select **Android**
3. Register with package name: `com.example.comsats_gpt`
4. Download `google-services.json` and place it in `android/app/`
5. Note the configuration values

### Step 4: Get iOS App Configuration (if needed)
1. In Project settings → Your apps
2. Click **Add app** → Select **iOS**
3. Register with bundle ID: `com.example.comsatsGpt`
4. Download `GoogleService-Info.plist` and add to Xcode project
5. Note the configuration values

### Step 5: Update Your Code

Replace the placeholder values in `lib/core/config/firebase_config.dart`:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyAc_QUqGd27kRgLP9BoQwoD7jDjmT8LONs',
  appId: '1:YOUR_ACTUAL_APP_ID:web:YOUR_ACTUAL_WEB_ID',  // ← Update this
  messagingSenderId: 'YOUR_ACTUAL_SENDER_ID',             // ← Update this
  projectId: 'mad-project-77dd3',
  authDomain: 'mad-project-77dd3.firebaseapp.com',
  storageBucket: 'mad-project-77dd3.appspot.com',
);
```

### Step 6: Enable Authentication Methods
1. In Firebase Console → **Authentication** → **Sign-in method**
2. Enable **Email/Password** authentication
3. Add authorized domains:
   - `localhost` (for local development)
   - Your production domain (if any)

### Step 7: Configure API Key Restrictions (Optional but Recommended)
1. Go to Google Cloud Console: https://console.cloud.google.com/
2. Select your project: **mad-project-77dd3**
3. Navigate to **APIs & Services** → **Credentials**
4. Find your API key: `AIzaSyAc_QUqGd27kRgLP9BoQwoD7jDjmT8LONs`
5. Click **Edit**
6. Under **Application restrictions**:
   - For development: Select "None" or add HTTP referrers (localhost)
   - For production: Add your domain
7. Under **API restrictions**:
   - Select "Restrict key"
   - Enable: Identity Toolkit API, Firebase Authentication API

## Quick Fix Using FlutterFire CLI (Recommended)

The easiest way to configure Firebase is using the FlutterFire CLI:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login

# Configure Firebase for your Flutter project
flutterfire configure --project=mad-project-77dd3
```

This will automatically:
- Register your apps on all platforms
- Generate the correct configuration
- Create/update `lib/firebase_options.dart` with real values

Then update your `firebase_config.dart` to use the generated values.

## Testing the Fix

After updating the configuration:

1. **Clear cache and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run -d chrome
   ```

2. **Check browser console** for any remaining errors

3. **Test authentication** by trying to sign up/login

## Common Issues

### Issue: Still getting 403 error
- **Solution**: Make sure you've enabled Email/Password authentication in Firebase Console
- **Solution**: Check that localhost is in authorized domains

### Issue: CORS errors
- **Solution**: Add your domain to authorized domains in Firebase Console

### Issue: API key restrictions blocking requests
- **Solution**: Temporarily set API restrictions to "None" for testing, then configure properly

## Need Help?

If you're still having issues:
1. Check Firebase Console → Authentication → Users (to see if users are being created)
2. Check browser DevTools → Network tab for detailed error messages
3. Verify all Firebase services are enabled in your project
4. Make sure billing is enabled if using Firestore or other paid features

---

**Next Steps:**
1. Get the real Firebase configuration values from Firebase Console
2. Update `lib/core/config/firebase_config.dart` with actual values
3. Rebuild and test your app
