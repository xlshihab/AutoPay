# AutoPay - ADB Setup for SMS Permissions (Development/Testing)

## Prerequisites

1. **Enable Developer Options on your phone:**
   - Go to Settings → About phone
   - Tap "Build number" 7 times
   - You'll see "You are now a developer!" message

2. **Enable USB Debugging:**
   - Go to Settings → System → Developer options
   - Turn ON "USB debugging"

3. **Connect phone via USB cable**
   - Make sure USB cable is good quality (data cable, not just charging)

## Installation Commands

Open Terminal/Command Prompt on your computer and run these commands:

### Step 1: Verify ADB is working
```bash
adb devices
```
You should see your device listed. If you see "unauthorized", check your phone for USB debugging authorization dialog.

### Step 2: Uninstall old version (if exists)
```bash
adb uninstall com.elbito.autopay
```

### Step 3: Install debug APK
```bash
adb install -r /Users/mahbubshihab/Development/Project/autopay/build/app/outputs/flutter-apk/app-debug.apk
```

### Step 4: Grant SMS permissions
```bash
adb shell pm grant com.elbito.autopay android.permission.READ_SMS
adb shell pm grant com.elbito.autopay android.permission.RECEIVE_SMS
adb shell pm grant com.elbito.autopay android.permission.READ_PHONE_STATE
adb shell pm grant com.elbito.autopay android.permission.POST_NOTIFICATIONS
```

### Step 5: Verify permissions
```bash
adb shell dumpsys package com.elbito.autopay | grep permission
```

### Step 6: Launch the app
Open AutoPay on your phone. The app should now be able to read SMS without any permission dialogs.

## Troubleshooting

### If `pm grant` fails with "operation not allowed"
- Make sure you installed the **debug** APK (not release)
- Some OEM devices (Samsung, Xiaomi, Oppo) have extra restrictions
- Try: `adb shell appops set com.elbito.autopay READ_SMS allow`

### If device is not showing in `adb devices`
- Try different USB cable
- Try different USB port on computer
- Check USB debugging is enabled
- On phone, tap "Always allow from this computer" in USB debugging dialog

### If permissions are revoked after reboot
- You need to grant them again via ADB
- This is normal behavior for debug builds

## Testing SMS Reading

After granting permissions:
1. Open AutoPay app
2. You should see a SnackBar showing number of SMS read
3. Go to tabs to see parsed bKash/Nagad transactions
4. Send a test bKash/Nagad SMS to verify real-time detection

## Release Build Warning

⚠️ **Important:** ADB permission granting only works for development/testing. 

For production release on Google Play Store:
- Users cannot use ADB
- You must follow Google Play SMS permission policies
- Alternative approaches needed (notification listener, user forwarding, etc.)

## Quick Copy-Paste Commands

```bash
# Full setup in one go
adb devices
adb uninstall com.elbito.autopay
adb install -r /Users/mahbubshihab/Development/Project/autopay/build/app/outputs/flutter-apk/app-debug.apk
adb shell pm grant com.elbito.autopay android.permission.READ_SMS
adb shell pm grant com.elbito.autopay android.permission.RECEIVE_SMS
adb shell pm grant com.elbito.autopay android.permission.READ_PHONE_STATE
adb shell pm grant com.elbito.autopay android.permission.POST_NOTIFICATIONS
adb shell dumpsys package com.elbito.autopay | grep permission
```

## Logs for Debugging

View app logs:
```bash
adb logcat | grep autopay
```

Or more verbose:
```bash
adb logcat | grep com.elbito.autopay
```
