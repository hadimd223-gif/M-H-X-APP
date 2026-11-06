# MHX Ads - Flutter Mobile Application (com.mhx.ads)

Google AdMob integrated Flutter mobile application with Banner, Interstitial, and Rewarded ads.

## 📱 AdMob Configuration

- **Package Name / Application ID:** `com.mhx.ads`
- **AdMob App ID:** `ca-app-pub-9467019896900554~2608224645`
- **Banner Ad Unit ID:** `ca-app-pub-9467019896900554/3083876525`
- **Interstitial Ad Unit ID:** `ca-app-pub-9467019896900554/6355897969`
- **Rewarded Ad Unit ID:** `ca-app-pub-9467019896900554/3355551299`

---

## 🚀 How to build the APK (এপিকে বানানোর নিয়ম)

### পদ্ধতি ১: ক্লাউডে ১-ক্লিকে ফ্রি APK তৈরি (GitHub Actions - সবচেয়ে সহজ)
কোনো কম্পিউটার বা জটিল সফটওয়্যার ইনস্টল ছাড়াই সরাসরি GitHub দিয়ে APK বানাতে পারবেন:
1. এই প্রোজেক্টের সব ফাইল GitHub রিপোজিটরিতে আপলোড করুন।
2. আপনার রিপোজিটরির **Actions** ট্যাবে যান।
3. **Build Android APK** অ্যাকশন সিলেক্ট করে **Run workflow** বাটনে ক্লিক করুন।
4. ২ মিনিটের মধ্যে APK তৈরি হয়ে যাবে এবং Artifacts থেকে সরাসরি `app-release.apk` ডাউনলোড করে নিন!

### পদ্ধতি ২: লোকাল কম্পিউটারে APK তৈরি (Local Flutter Build)
যদি আপনার পিসিতে Flutter SDK ইনস্টল থাকে:
```bash
# ১. ডিপেনডেন্সি ইনস্টল করুন
flutter pub get

# ২. রিলিজ এপিকে বিল্ড করুন
flutter build apk --release
```
বিল্ড সফল হলে আপনার এপিকে ফাইলটি এখানে পাওয়া যাবে:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## ⚠️ গুরুত্বপূর্ণ সতর্কতা (Important AdMob Policy):
- ডেভেলপমেন্ট এবং টেস্টিং এর সময় কখনই নিজের আসল বিজ্ঞাপন ইউনিটে ক্লিক করবেন না! গুগল অ্যাডমব অ্যাকাউন্ট ব্যান হতে পারে।
- টেস্টিং এর জন্য `lib/ad_helper.dart` ফাইলে `useTestAds = true (ডিবাগ মোডে অটো true)` রেখে পরীক্ষা করুন।
- প্লে-স্টোরে পাবলিশ করার আগে `useTestAds = false` নিশ্চিত করুন।
