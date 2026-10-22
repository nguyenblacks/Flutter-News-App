# Swavoti News 📰

A modern, fast, and elegant news application built with **Flutter 3**, **Dart 3 (Sound Null Safety)**, and **Material 3**. Powered by live **Google News RSS feeds** requiring zero API keys.

---

## ✨ Features

- ⚡ **Live Realtime News**: Directly streams up-to-the-minute global headlines via Google News RSS feeds.
- 🗂 **Categorized Feeds**: Instant filtering across **Business**, **Technology**, **Entertainment**, **Health**, **Science**, and **Sports**.
- 🔍 **Realtime Search**: Search across topics and global events instantly.
- 🌓 **Theme Modes**: Seamless Dark & Light theme support with Material 3 styling, persisted locally with **Hive**.
- 📱 **Adaptive UI**: Responsive layouts powered by `flutter_screenutil` tailored for all screen sizes.
- 🚀 **Automated CI/CD**: Pre-configured **GitHub Actions** workflow that builds and archives release-ready Android APKs.

---

## 🏛 Architecture & Tech Stack

This project follows Clean Architecture with separation of concerns:

- **State Management**: [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) (Event-driven state handling)
- **Networking**: [`dio`](https://pub.dev/packages/dio) with custom interceptors and XML parsing
- **Dependency Injection**: [`get_it`](https://pub.dev/packages/get_it) service locator
- **Local Persistence**: [`hive`](https://pub.dev/packages/hive) & [`hive_flutter`](https://pub.dev/packages/hive_flutter)
- **Responsive Layout**: [`flutter_screenutil`](https://pub.dev/packages/flutter_screenutil)
- **Image Caching**: [`cached_network_image`](https://pub.dev/packages/cached_network_image)
- **External Links**: [`url_launcher`](https://pub.dev/packages/url_launcher)
- **Connectivity**: [`internet_connection_checker_plus`](https://pub.dev/packages/internet_connection_checker_plus)

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.47.0` (or latest stable)
- Dart SDK `^3.10.0`
- Android Studio / VS Code

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/nguyenblacks/Flutter-News-App.git
   cd Flutter-News-App
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   - **Production Flavor**:
     ```bash
     flutter run -t lib/main_production.dart --flavor production
     ```
   - **Development Flavor**:
     ```bash
     flutter run -t lib/main_development.dart --flavor development
     ```

---

## 📦 Building Release APK

To build a release APK locally or via CI:

```bash
flutter build apk --release --flavor production -t lib/main_production.dart --android-skip-build-dependency-validation
```

The output APK will be generated at:
`build/app/outputs/flutter-apk/app-production-release.apk`

---

## 🤖 CI / CD Pipeline

The repository includes a GitHub Actions workflow at [`.github/workflows/build_apk.yml`](.github/workflows/build_apk.yml) that automatically:
1. Sets up Java 17 and Flutter.
2. Runs static code analysis (`flutter analyze`).
3. Compiles the release production APK.
4. Uploads the built APK as a downloadable artifact.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
