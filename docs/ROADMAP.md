# Roadmap — QO-100 TR

## Milestone 0 — Discovery and foundation

Goal: remove major integration unknowns and establish a maintainable Flutter base.

Tasks:

- inspect existing TA-NET 777 backend/source if available;
- confirm authoritative frequency and weekly schedule;
- initialize Flutter project;
- add Riverpod and GoRouter;
- create app theme/design tokens;
- implement five-tab shell with placeholder pages;
- add CI for format/analyze/test;
- document Firebase project setup strategy.

Exit criteria:

- app builds on Android and iOS simulator/device targets;
- five tabs are navigable;
- analyzer and tests are clean;
- backend integration decision is documented or explicitly isolated behind interfaces.

## Milestone 1 — Core MVP

Goal: produce a usable community app beta.

### Authentication and onboarding

- Firebase Authentication wiring;
- email/password login/register;
- Google sign-in;
- Apple sign-in planning/implementation for iOS public release if required;
- callsign profile onboarding;
- profile persistence.

### Ana Sayfa

- session hero;
- current/next session state;
- live shortcut;
- participation summary;
- check-in shortcut;
- announcements/news preview.

### Canlı

- WebView/approved live integration;
- loading/error states;
- browser fallback where appropriate.

### Katılım

- direct/SWL selector;
- one-tap saved-profile check-in;
- duplicate protection;
- live participant stream;
- direct/SWL totals;
- success/error states.

### Haberler

- repository/service abstraction;
- initial approved RSS/manual source integration;
- feed and article opening;
- announcement support.

### Profil

- display/edit profile;
- station fields;
- basic participation summary;
- notification preferences;
- logout.

### Notifications

- FCM device registration;
- session reminder/start notification path;
- deep-link routing foundation.

Exit criteria:

- a test user can complete the end-to-end success criteria in `PRODUCT.md`;
- critical flows have tests;
- beta builds can be produced.

## Milestone 2 — Community visibility and retention

Goal: bring the strongest existing website history/statistics features into mobile.

- historical week browser;
- callsign search;
- station participation history;
- province/city participation view;
- map view with privacy-aware location granularity;
- top participation lists;
- richer user statistics;
- direct/SWL breakdown;
- streaks;
- achievements/badges;
- expanded antenna/device profile.

Exit criteria:

- mobile reproduces the important historical/statistical value of the current site;
- stats remain performant with realistic production data.

## Milestone 3 — Admin and community layer

Goal: support sustainable community operations.

- admin session management;
- scenario/exercise notes;
- announcement/news source management;
- moderator role;
- community posts;
- comments;
- reports;
- moderation tools;
- anti-spam/abuse controls.

Forum/community posting should not ship until moderation responsibilities and rules are defined.

## Milestone 4 — Enhanced live experience

Only after a stable stream endpoint and usage permission are confirmed:

- native audio player;
- background audio;
- lock-screen media controls;
- Bluetooth/media controls;
- robust reconnection behavior.

This milestone replaces or supplements MVP WebView listening without changing the rest of the app's domain architecture.

## Suggested first implementation sequence for Codex

1. Initialize Flutter project and baseline tooling.
2. Add dependencies and application shell.
3. Implement design tokens/theme.
4. Add five placeholder feature pages.
5. Add router tests/widget smoke test.
6. Set up CI.
7. Introduce domain repository interfaces for session/check-in/profile.
8. Implement fixture-backed Home and Participation screens before backend connection.
9. Connect Firebase only after app boundaries are established.
10. Replace fixtures with real repositories feature by feature.

## Time expectation

This roadmap intentionally separates MVP from later community features. With focused AI-assisted development and timely backend decisions, an MVP can be targeted in weeks rather than months, but store release timing still depends on integration, testing, credentials, signing, and review processes.
