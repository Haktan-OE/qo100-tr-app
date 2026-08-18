# Architecture — QO-100 TR

## Goals

The architecture should support a small MVP without becoming disposable when the app grows. It must also isolate unknowns around the existing TA-NET 777 backend.

## Client stack

- Flutter / Dart
- Riverpod for state management and dependency injection
- GoRouter for navigation
- Material 3 with a custom dark design system
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging

Additional packages should be added only when a concrete feature requires them.

## High-level architecture

```text
Flutter App
  |
  +-- Presentation
  |     screens, widgets, providers/controllers
  |
  +-- Domain
  |     entities, value objects, use-case rules where justified
  |
  +-- Data
        repositories, DTOs/mappers, remote/local data sources
             |
             +-- Firebase
             +-- Existing TA-NET backend adapter (when known)
             +-- RSS/news sources
             +-- Live listening integration
```

The app should not assume that Firebase must replace the existing website backend. Firebase is the initial mobile platform direction, but existing production data should be integrated through a deliberate adapter/shared-backend decision once the web system is inspected.

## Feature-first folder structure

```text
lib/
  main.dart
  app/
    app.dart
    router/
    theme/
    bootstrap/
  core/
    constants/
    errors/
    extensions/
    services/
    widgets/
  features/
    auth/
      data/
      domain/
      presentation/
    home/
    live/
    participation/
    news/
    profile/
```

Do not create domain/data subfolders when a feature is still trivial. Introduce layers when they reduce coupling or improve testability.

## Navigation

The authenticated application shell contains five persistent branches:

```text
/app/home
/app/live
/app/participation
/app/news
/app/profile
```

Authentication/onboarding routes live outside the shell.

Suggested route groups:

```text
/splash
/auth/login
/auth/register
/onboarding/profile
/app/...
```

GoRouter should own route transitions and deep-link routing. Avoid ad-hoc `Navigator` usage unless a local modal/detail flow clearly benefits from it.

## State management

Riverpod responsibilities:

- expose repositories/services;
- manage authenticated-user state;
- manage current session state;
- expose check-in streams;
- expose news/profile state;
- isolate asynchronous loading/error/data states from widgets.

Widgets should remain declarative. Business rules such as "can this user check in twice?" must not live only inside button callbacks.

## Backend abstraction

The key architectural constraint is that the existing production backend is not yet known.

Define interfaces around domain capabilities rather than Firestore collections. Example:

```dart
abstract interface class SessionRepository {
  Stream<CommunitySession?> watchCurrentSession();
  Future<List<CommunitySession>> getRecentSessions();
}

abstract interface class CheckInRepository {
  Stream<List<CheckIn>> watchCheckIns(String sessionId);
  Future<void> checkIn(CheckInRequest request);
}
```

A Firestore implementation can satisfy these interfaces initially. If the existing website exposes an API or common datastore, another implementation can be introduced without rewriting screens.

## Authentication

Initial target:

- Firebase Authentication;
- email/password;
- Google sign-in;
- Sign in with Apple for iOS if social login is part of the public iOS release.

Account identity is Firebase `uid`; community identity is callsign/profile data.

## Firestore direction

See `DATA_MODEL.md` for the proposed collections.

Rules:

- UI never consumes raw Firestore snapshots directly;
- map timestamps and nullable fields at the data layer;
- use server timestamps for authoritative write times;
- enforce unique/current-session participation through backend/security rules or a transactional write strategy, not only client UI state;
- security rules are part of the product, not an afterthought.

## Live listening

### MVP

Use a WebView or similarly contained integration with the existing approved live-listening page/system.

This reduces initial risk and preserves the current service.

### Later

If a stable audio stream endpoint and permission to consume it directly are available, introduce a native audio abstraction supporting:

- background playback;
- lock-screen controls;
- Bluetooth controls;
- Android foreground-service requirements;
- iOS audio-session configuration.

The rest of the app should not depend on which live-listening implementation is active.

## News

News should enter the app through a repository that can combine:

- curated TA-NET announcements;
- approved RSS feeds;
- manually managed content.

Do not make screen code parse RSS.

## Notifications

Firebase Cloud Messaging is the initial delivery mechanism.

Use cases include:

- session reminder;
- session start;
- important TA-NET announcement;
- emergency-exercise notice;
- later: targeted moderation/community notifications.

Notification payloads should route to a semantic destination such as a session or article, not hard-coded UI indices.

## Configuration

Frequency and schedule values must be configurable because discovery sources currently disagree.

Suggested future configuration sources, in priority order:

1. authoritative backend session document;
2. remote configuration/admin-managed settings;
3. local fallback defaults used only when no remote value exists.

Avoid duplicating production frequency/time constants across widgets.

## Offline behavior

MVP should degrade gracefully:

- cached Firestore reads may display previously fetched data;
- check-in requires confirmed network write and should not falsely claim success offline;
- news may show cached content;
- live listening clearly communicates network failure.

## Error handling

Map infrastructure errors to app-level failures/messages. Avoid exposing raw Firebase exceptions to users.

Expected UI states for asynchronous sections:

- loading;
- data;
- empty;
- recoverable error with retry;
- permission/authentication-required state where relevant.

## Observability

For public beta/release, add crash/error telemetry through an approved service, likely Firebase Crashlytics, after privacy and project setup decisions are made.

Do not log passwords, auth tokens, exact private coordinates, or unnecessary personal data.

## CI target

A later GitHub Actions workflow should run at minimum:

```text
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Platform builds can be added when signing/configuration strategy is ready.

## Architecture decision process

Meaningful deviations from the documented stack should be recorded in this file or a small ADR under `docs/adr/` before they spread through the codebase.
