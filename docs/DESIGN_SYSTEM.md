# Design System — QO-100 TR

## Visual direction

The app should feel modern, technical, trustworthy, and clearly related to satellite/radio communication without becoming visually noisy.

Primary references from the project concept/mockups use:

- deep navy backgrounds;
- cyan/teal highlights;
- white/soft-gray typography;
- rounded cards;
- subtle glow/technical illustration accents;
- satellite, antenna, signal, location, and radio iconography.

## Theme

MVP default theme: dark.

Suggested token direction (final values should be tuned in implementation):

```text
background            deep navy
surface               slightly lighter navy
surfaceElevated       blue-navy
primary               teal/cyan
primaryStrong         brighter cyan
textPrimary           near-white
textSecondary         cool gray
success               teal-green
warning               amber
error                 warm red
outline               low-contrast blue-gray
```

Do not scatter literal colors throughout widgets. Define semantic theme tokens centrally.

## Spacing

Use a small consistent spacing scale, e.g.:

```text
4, 8, 12, 16, 20, 24, 32
```

Screens should generally use 16 logical pixels horizontal padding on standard phones unless a component has a strong reason to differ.

## Radius

Recommended direction:

```text
small controls: 10–12
cards: 16–20
pills/buttons: fully rounded or 14–18 depending on role
```

## Typography

Use the platform-appropriate Flutter typography foundation and centralize app-specific styles.

Suggested hierarchy:

- screen title;
- section title;
- card title;
- body;
- secondary/meta;
- statistic value;
- frequency/technical emphasis.

Frequency values such as `10489.777 MHz` may use a stronger technical display style but should remain readable.

## Core reusable components

Plan reusable widgets for:

- app shell/navigation;
- section headers;
- hero session card;
- primary and secondary action buttons;
- statistic tiles;
- status badges;
- user/station rows;
- article cards;
- empty-state card;
- error/retry card;
- loading skeleton/progress;
- profile information rows;
- achievement badges (Phase 2).

## Bottom navigation

The five main destinations remain visible for authenticated users:

```text
Ana Sayfa
Canlı
Katılım
Haberler
Profil
```

Active state uses the primary teal/cyan accent. Inactive items should remain readable but visually secondary.

## Ana Sayfa pattern

The home screen should prioritize:

1. current/next session;
2. live listening;
3. check-in;
4. participation status;
5. announcements/news.

Avoid putting every metric above the fold.

## Live screen pattern

Keep listening controls/status visually dominant. Do not present decorative player controls that cannot actually control the embedded source.

If MVP WebView integration restricts native control, the UI must clearly reflect the capabilities available.

## Participation screen pattern

The primary action should be unmistakable:

`Katılımımı Kaydet`

Direct/SWL selection must be obvious before submission. After successful submission, transform the state rather than encouraging repeated taps.

## News pattern

Cards should show enough metadata to build trust:

- source;
- publication time;
- headline;
- brief summary;
- image only when available and appropriate.

## Profile pattern

Callsign is the strongest identity element. Equipment and participation history support it rather than overpowering it.

## Motion

Keep motion restrained:

- short tab/page transitions;
- subtle check-in success feedback;
- lightweight loading indicators;
- no continuous decorative animation that drains battery or distracts.

Respect reduced-motion preferences where practical.

## Accessibility

- maintain adequate text/background contrast;
- do not communicate state with color alone;
- provide semantic labels for icon-only controls;
- support text scaling;
- target at least ~44 logical pixel interactive areas where practical;
- avoid extremely small metadata text.

## Presentation mockups vs production UI

The generated concept screens are visual targets, not pixel-perfect specifications. Production implementation should preserve hierarchy, branding, and feature intent while adapting to Flutter layout constraints, accessibility, real data states, Android/iOS differences, and loading/error conditions.
