# AGENTS.md

## Project

QO-100 TR is a Flutter mobile application for the Turkish QO-100 amateur radio community and the TA-NET 777 weekly activity.

Read the files under `docs/` before making architectural or product-level changes.

## Product priorities

1. Keep the first release focused and reliable.
2. Preserve compatibility with the existing TA-NET 777 web data/workflow where feasible.
3. Prefer a shared backend/data source over scraping the website.
4. Optimize for Android and iOS from the beginning.
5. Keep the five primary tabs stable unless a product decision explicitly changes them:
   - Ana Sayfa
   - Canlı
   - Katılım
   - Haberler
   - Profil

## Technical direction

- Flutter / Dart
- Material 3 with a custom dark QO-100 TR design system
- Riverpod for application state and dependency injection
- GoRouter for navigation
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging
- Feature-first project organization

Do not introduce alternative state-management, routing, backend, or DI frameworks without documenting the reason and receiving an explicit architecture decision.

## Architecture rules

Use a feature-first structure. A feature may contain `data`, `domain`, and `presentation` layers when the complexity justifies them. Do not create empty layers only for ceremony.

Expected direction:

```text
lib/
  app/
  core/
  features/
    auth/
    home/
    live/
    participation/
    news/
    profile/
```

Keep Firebase SDK calls out of widgets. Put remote persistence/access behind repositories or services that can be replaced in tests.

Domain and presentation code should not depend directly on Firestore document snapshots.

## UI rules

- Default app theme is dark navy with teal/cyan accents.
- Prefer reusable widgets for repeated cards, section headers, statistic tiles, badges, and loading/error states.
- All user-facing strings are Turkish in the first release.
- Do not hard-code layout values throughout the app; centralize spacing, radius, typography, and color tokens.
- Support common phone sizes and text scaling.
- Treat the presentation mockups as visual direction, not as permission to hard-code sample data into production paths.
- Accessibility: meaningful semantics, adequate contrast, and touch targets of at least 44 logical pixels where practical.

## Data and privacy

- A callsign is the core community identity, but Firebase `uid` is the internal account key.
- Do not expose exact private location data by default.
- Prefer city and/or Maidenhead locator granularity for public community displays.
- Never commit Firebase service account keys, API secrets, signing keys, certificates, `.env` files containing secrets, or production credentials.
- Firebase configuration files must follow the documented setup process and must not contain server-side secrets.

## Existing website integration

The current TA-NET 777 website already provides live listening, weekly participation, historic week detail, participant maps, callsign search, top participation lists, station history, authentication, and direct/SWL check-in.

Do not scrape HTML for production integration if an API, shared database, or backend adapter can be used instead.

The authoritative backend/API is not yet documented in this repository. Any implementation that assumes a specific backend contract must be isolated behind an interface until that contract is confirmed.

## Open product decisions

There is currently a source discrepancy for session frequency/time:

- Existing website observed during project discovery: `10489.777 MHz`, Sunday `18:00 UTC`.
- Concept document: `10489.500 MHz`, Sunday `20:00`.

Do not silently choose one as canonical in business logic. Keep these values configurable until the project owner confirms the authoritative values. Mock/sample UI may use clearly marked fixture values.

## Quality bar

For each implementation task:

1. Keep the change scoped to the task.
2. Run formatting.
3. Run `flutter analyze`.
4. Run relevant tests.
5. Add or update tests for non-trivial logic.
6. Avoid warnings introduced by the change.
7. Update documentation when behavior or architecture changes.

Prefer `const` widgets where appropriate and avoid unnecessary rebuilds, but do not sacrifice readability for micro-optimizations.

## Testing

Target a practical test pyramid:

- unit tests for parsing, mapping, session/check-in rules, and repositories with fakes;
- widget tests for important screen states and reusable UI components;
- integration tests later for authentication and critical check-in flows.

Do not make tests depend on production Firebase services.

## Git and pull requests

- Use small, focused commits.
- Use conventional commit-style messages where practical, e.g. `feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`.
- A PR description should state what changed, how it was tested, and any remaining product/backend assumptions.
- Do not refactor unrelated code in a feature PR unless required to complete the task safely.

## Definition of done for MVP features

A feature is not done because its happy-path UI renders. It must also include sensible loading, empty, and error states; responsive layout; test coverage for meaningful logic; and no new analyzer errors.
