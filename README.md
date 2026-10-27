# UX Terms

A mobile learning app for college freshmen meeting design thinking, UX, AI tools and immersive tech for the first time. Built with Flutter, so one codebase runs on **Android** and **iOS**.

## What's in the app

| Tab | What students can do |
| --- | --- |
| **Home** | Pick up their next lesson, swipe the Design Thinking cards (01–05), read the term of the day, jump to other tracks. |
| **Learn** | Browse 5 tracks and 28 short lessons: Design Thinking, Gestalt Principles, Laws of UX, AI for Designers, Immersive & Emerging Tech. |
| **Lessons** | Swipe through cards: intro photo, the idea, deep-dive explainers (e.g. Crazy 8s, SCAMPER, VR/AR/MR), an example, a "Try it" exercise and the key takeaway. 16 animated explainers play inside the cards. |
| **Glossary** | Search 44 terms, filter by category, open a term to see an example and its related lesson, save terms. |
| **Resources** | 32 videos, articles, courses, guides, tools and books, filtered by format and topic. Links open in the browser or YouTube app. |
| **Progress** | Completion ring, daily streak, progress per track, 8 badges, saved terms and resources, credits, reset. |

Progress is saved on the device. On first launch the app shows **sample progress** (3 lessons done, 3-day streak) so reviewers can see a mid-course state; **Progress → Reset progress** clears it.

## Project layout

```
assets/
  content.json        All lessons, glossary terms, resources and animation captions
  images/             16 lesson photos (AI-generated with Figma AI)
  fonts/              Archivo Expanded (titles) and Figtree (body)
lib/
  main.dart           App entry, splash screen, bottom tab bar
  theme.dart          Brand colours (light + dark mode) and type styles
  data/content.dart   Loads and models the course content
  state/progress.dart Saved progress, streaks, bookmarks
  screens/            Home, Learn, Track, Lesson, Glossary, Resources, Progress, Credits
  widgets/common.dart Cards, chips, progress bars, resource cards, term sheet
  widgets/media.dart  Photos, diagrams and the 16 animated explainers
test/app_test.dart    Content, progress and screen tests
```

To edit lesson text, glossary terms or resources, change `assets/content.json`. No code changes needed.

## Run it on your computer

1. Install Flutter 3.47 or newer: https://docs.flutter.dev/get-started/install
2. For Android: install Android Studio (includes the Android SDK and an emulator).
3. For iOS: you need a Mac with Xcode.
4. In this folder:

```bash
flutter pub get
flutter run            # runs on a connected phone or open emulator/simulator
flutter test           # runs the test suite
```

## Build installable apps

**Android**

```bash
flutter build apk --release        # app-release.apk: install directly on a phone
flutter build appbundle --release  # app-release.aab: upload to Google Play
```

Before publishing to Google Play, create your own signing key and add it to `android/app/build.gradle.kts` (see https://docs.flutter.dev/deployment/android). Until then, release builds are signed with a debug key, which is fine for testing on your own devices.

**iOS** (on a Mac)

```bash
open ios/Runner.xcworkspace
```

In Xcode, choose your Apple Developer team under *Signing & Capabilities*, then *Product → Archive* to upload to TestFlight or the App Store (see https://docs.flutter.dev/deployment/ios).

## Automatic builds with GitHub

If you push this folder to a GitHub repository, `.github/workflows/build.yml` builds both apps on every push:

- **ux-terms-android**: `app-release.apk` (install on Android phones) and `app-release.aab` (for Google Play)
- **ux-terms-ios-unsigned**: an unsigned iOS build. Installing on an iPhone still needs signing in Xcode with an Apple Developer account.

Find them under the repository's **Actions** tab → latest run → **Artifacts**.

## App identity

- App name: **UX Terms**
- Android package: `edu.uxterms.ux_terms`; iOS bundle ID: `edu.uxterms.uxTerms` (change both before publishing if you have your own domain)
- Icon: the blue "UX" mark from the case study
