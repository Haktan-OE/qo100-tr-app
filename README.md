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
