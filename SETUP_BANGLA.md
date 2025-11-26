# AutoPay - স্বয়ংক্রিয় SMS পেমেন্ট ট্র্যাকার

## Firebase সেটআপ নির্দেশনা

### ধাপ ১: Firebase প্রকল্প তৈরি করুন

1. [Firebase Console](https://console.firebase.google.com/) এ যান
2. "Add project" ক্লিক করুন
3. প্রকল্পের নাম দিন (উদাঃ "autopay")
4. Google Analytics সক্রিয় করুন (ঐচ্ছিক)
5. প্রকল্প তৈরি করুন

### ধাপ ২: Android অ্যাপ যোগ করুন

1. Firebase Console এ আপনার প্রকল্পে যান
2. "Add app" বা Android আইকনে ক্লিক করুন
3. Android package name: `com.example.autopay`
4. App nickname: `AutoPay` (ঐচ্ছিক)
5. "Register app" ক্লিক করুন

### ধাপ ৩: google-services.json ডাউনলোড করুন

1. `google-services.json` ফাইল ডাউনলোড করুন
2. ফাইলটি এই লোকেশনে রাখুন:
   ```
   android/app/google-services.json
   ```

### ধাপ ৪: Firestore Database তৈরি করুন

1. Firebase Console এ "Firestore Database" এ যান
2. "Create database" ক্লিক করুন
3. Production mode নির্বাচন করুন
4. Location নির্বাচন করুন (সবচেয়ে কাছের)
5. "Enable" ক্লিক করুন

### ধাপ ৫: Firestore Rules সেটআপ করুন

Firestore Database Rules টি নিম্নলিখিত দিয়ে প্রতিস্থাপন করুন:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /payments/{document=**} {
      allow read, write: if true;  // উন্নয়নের জন্য
      // উৎপাদনে authentication যোগ করুন:
      // allow read, write: if request.auth != null;
    }
  }
}
```

⚠️ **নিরাপত্তা সতর্কতা**: উৎপাদন পরিবেশে অবশ্যই authentication যোগ করুন।

## অ্যাপ চালানোর নির্দেশনা

### পূর্বশর্ত
- Flutter SDK ইনস্টল থাকতে হবে
- Android Studio বা VS Code
- Android device বা emulator

### প্যাকেজ ইনস্টল করুন
```bash
flutter pub get
```

### অ্যাপ চালান
```bash
flutter run
```

### ডিবাগ করুন
```bash
flutter run --debug
```

### বিল্ড করুন (Release)
```bash
flutter build apk --release
```

## পারমিশন সেটআপ

অ্যাপ চালানোর পর:

1. Settings স্ক্রিনে যান
2. "পারমিশন রিকোয়েস্ট করুন" বাটনে ক্লিক করুন
3. সকল পারমিশন অনুমোদন করুন:
   - SMS Read
   - SMS Receive
   - Phone State
   - Notifications

## SMS পার্সার টেস্ট করুন

Settings স্ক্রিনে "SMS পার্সার টেস্ট" সেকশনে:

### বিকাশ টেস্ট:
- **প্রেরক**: `bKash`
- **মেসেজ**: `You have received BDT 1,500.00 from 01712345678. TrxID ABC1234567 at 20/11/2025 10:30 AM`

### নগদ টেস্ট:
- **প্রেরক**: `NAGAD`
- **মেসেজ**: `You have received Tk. 2,000.00 from 01812345678. Transaction ID: XYZ9876543 at 20/11/2025`

## ব্যাকগ্রাউন্ড সার্ভিস

Home Screen থেকে "সার্ভিস চালু করুন" বাটনে ক্লিক করুন। সার্ভিস:
- ব্যাকগ্রাউন্ডে চলবে
- নতুন SMS আসলে স্বয়ংক্রিয়ভাবে পড়বে
- বিকাশ/নগদ পেমেন্ট শনাক্ত করবে
- Firebase এ সংরক্ষণ করবে

## সমস্যা সমাধান

### Firebase সংযোগ ব্যর্থ
- `google-services.json` ফাইল সঠিক জায়গায় আছে কিনা চেক করুন
- Package name মিলছে কিনা নিশ্চিত করুন
- Internet সংযোগ চেক করুন

### SMS পড়া যাচ্ছে না
- পারমিশন অনুমোদিত কিনা চেক করুন
- Android 13+ এ "Post Notifications" পারমিশন প্রয়োজন
- ব্যাকগ্রাউন্ড সার্ভিস চালু আছে কিনা চেক করুন

### পার্সিং কাজ করছে না
- SMS ফরম্যাট সঠিক কিনা চেক করুন
- Settings এ টেস্ট পার্সার ব্যবহার করুন
- বিকাশ/নগদের sender ID সঠিক কিনা চেক করুন

## প্রজেক্ট স্ট্রাকচার

```
lib/
├── main.dart                       # অ্যাপ এন্ট্রি পয়েন্ট
├── models/
│   └── payment_model.dart         # পেমেন্ট ডেটা মডেল
├── services/
│   ├── sms_service.dart           # এসএমএস পড়া ও শোনা
│   ├── firebase_service.dart      # Firebase অপারেশন
│   ├── parser_service.dart        # এসএমএস পার্স করা
│   └── background_service.dart    # ব্যাকগ্রাউন্ড সার্ভিস
├── utils/
│   ├── constants.dart             # কনস্ট্যান্ট ভ্যালু
│   └── permissions.dart           # পারমিশন হ্যান্ডলার
└── screens/
    ├── home_screen.dart           # হোম স্ক্রিন
    └── settings_screen.dart       # সেটিংস স্ক্রিন
```

## ভবিষ্যৎ উন্নয়ন

- [ ] Authentication যোগ করা
- [ ] অফলাইন সাপোর্ট (Hive/SQLite)
- [ ] রকেট, উপায় সাপোর্ট
- [ ] খরচের SMS ট্র্যাকিং
- [ ] ড্যাশবোর্ড ও রিপোর্ট
- [ ] ওয়েব ড্যাশবোর্ড

## লাইসেন্স

এই প্রজেক্টটি শুধুমাত্র ব্যক্তিগত ব্যবহারের জন্য তৈরি করা হয়েছে।

## সতর্কতা

⚠️ অন্যের SMS পড়া আইনত দণ্ডনীয় অপরাধ। এই অ্যাপটি শুধুমাত্র নিজের ফোনে ব্যবহারের জন্য তৈরি করা হয়েছে।
