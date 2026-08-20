# QO-100 TR

QO-100 TR is a Flutter mobile community application for Turkey's QO-100 amateur radio community and the TA-NET 777 weekly activity.

The project brings live listening, weekly check-in, participation history, community news, notifications, and operator profiles into a single Android/iOS application.

## Main navigation

1. Ana Sayfa
2. Canlı
3. Katılım
4. Haberler
5. Profil

## Initial technical direction

- Flutter / Dart
- Riverpod
- GoRouter
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging
- Feature-first architecture

## Documentation

- [`AGENTS.md`](AGENTS.md) — repository-wide Codex/development instructions
- [`docs/PRODUCT.md`](docs/PRODUCT.md) — product definition and MVP scope
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — technical architecture
- [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md) — proposed logical data model
- [`docs/SCREEN_FLOW.md`](docs/SCREEN_FLOW.md) — mobile navigation and screen behavior
- [`docs/DESIGN_SYSTEM.md`](docs/DESIGN_SYSTEM.md) — visual/UI direction
- [`docs/ROADMAP.md`](docs/ROADMAP.md) — phased implementation roadmap

## Current status

Project foundation and product/architecture planning are in progress. The next implementation step is to initialize the Flutter application and create the five-tab shell.

## Important integration note

The existing TA-NET 777 website already contains valuable live-listening, attendance, history, map, callsign search, and authentication behavior. The mobile application should ultimately share or deliberately integrate with the authoritative backend rather than scrape the website or create a disconnected production data source.

## Backend configuration

The application defaults to fixture repositories and does not require a Firebase project:

```sh
flutter run --dart-define=QO100_BACKEND=fixture
```

Backend selection is centralized in `AppConfig`. Presentation, routing, onboarding, and profile editing continue to depend only on `AuthRepository` and `UserProfileRepository`.

### Firebase project-owner setup

No Firebase project configuration is currently committed, so Firebase mode has not been tested against a real project. The project owner must complete these steps before using it:

1. Create or select the authoritative Firebase project.
2. Enable Email/Password under Firebase Authentication providers.
3. Create the Cloud Firestore database in the intended region.
4. Confirm the final Android application ID, then register the Android app.
5. Confirm the final iOS bundle ID, then register the iOS app.
6. Install and authenticate the FlutterFire CLI, then run `flutterfire configure` from the repository root for Android and iOS.
7. Either update `bootstrap.dart` to pass the generated `DefaultFirebaseOptions.currentPlatform` to `Firebase.initializeApp`, or install the supported native configuration files and retain the current default initialization path.
8. Run configured Firebase mode with:

   ```sh
   flutter run --dart-define=QO100_BACKEND=firebase
   ```

The expected client configuration artifacts are `lib/firebase_options.dart`, `android/app/google-services.json`, and `ios/Runner/GoogleService-Info.plist`, depending on the selected FlutterFire setup. Firebase client configuration identifies the app but is not an Admin SDK credential. Never commit service-account JSON, Admin SDK private keys, signing keys, certificates, auth tokens, or `.env` files containing secrets.

iOS plugin integration currently uses CocoaPods; Swift Package Manager is disabled in `pubspec.yaml` so generated third-party package sources do not enter repository-wide format/analyzer checks.

Firestore profile documents use `users/{uid}`. Production rules are intentionally not added in this issue. Their required direction is that an authenticated user may read and write only their own profile; any public community-profile visibility must be decided separately. Do not deploy permissive `allow read, write: if true` rules.
