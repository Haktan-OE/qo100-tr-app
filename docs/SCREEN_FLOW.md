# Screen Flow — QO-100 TR

## Primary navigation

After authentication/onboarding, the user enters a persistent five-tab application shell:

```text
Ana Sayfa | Canlı | Katılım | Haberler | Profil
```

## Authentication flow

```text
Splash
  |
  +-- unauthenticated --> Login / Register
  |                         |
  |                         +--> Profile Onboarding
  |                                  |
  |                                  +--> App Shell
  |
  +-- authenticated + profile complete --> App Shell
  |
  +-- authenticated + profile incomplete --> Profile Onboarding
```

## Ana Sayfa

Purpose: answer "what is happening now and what should I do next?"

Recommended sections:

1. app/community header;
2. current or next TA-NET 777 session hero card;
3. frequency and time;
4. `Canlı Dinle` primary action;
5. weekly participation summary: direct / SWL / cities;
6. `Yoklamaya Katıl` action;
7. recent announcements;
8. news preview.

Key transitions:

```text
Canlı Dinle -> Canlı tab
Yoklamaya Katıl -> Katılım tab
News card -> News detail
Announcement -> Announcement/detail where applicable
```

## Canlı

Purpose: make the existing live-listening workflow easy to access on mobile.

MVP sections:

1. live status;
2. frequency/session context;
3. embedded listening experience (initially WebView/approved existing system);
4. listening/loading/error state;
5. optional shortcut to open the source in browser;
6. recent/active station context only if reliable backend data exists.

Important: the mobile app must not pretend audio is live if the embedded source is unavailable.

## Katılım

Purpose: reduce weekly direct/SWL check-in to a few seconds.

Sections:

1. current session card;
2. direct/SWL selector;
3. saved user identity summary;
4. primary `Katılımımı Kaydet` button;
5. live totals;
6. live participant list;
7. link to weekly/historical detail.

States:

```text
No active session
Active session, not checked in
Submitting
Checked in successfully
Already checked in
Submission error
Authentication/profile required
```

A successful check-in should clearly show the participation mode and timestamp.

## Haberler

Purpose: give users a reason to return outside the weekly session.

Sections:

1. featured article/announcement;
2. category filters;
3. chronological news feed;
4. TA-NET announcement card;
5. article detail/external-source transition.

Potential categories:

```text
Tümü
QO-100
Uydu
Topluluk
```

## Profil

Purpose: represent the operator's community identity and participation record.

MVP sections:

1. callsign identity;
2. name and city;
3. Maidenhead locator;
4. station information;
5. basic participation statistics;
6. edit profile;
7. notification settings;
8. sign out.

Phase 2 sections:

- streak;
- achievements/badges;
- equipment details;
- participation history;
- map/privacy controls.

Admin users may later see a `Yönetim Paneli` entry.

## Historical participation flow — Phase 2

```text
Katılım
  -> Haftalık Detaylar
      -> Week selector
      -> Direct participants
      -> SWL participants
      -> City/map view
      -> Callsign profile/history
```

## Callsign history — Phase 2

Accessible through search/profile/participant list:

```text
Callsign
  -> total participation
  -> direct / SWL distribution
  -> recent weeks
  -> streak/achievement summary
```

## Admin flow — later phase

```text
Profil
  -> Yönetim Paneli
      -> Sessions
      -> Scenario/exercise note
      -> Announcements/news sources
      -> Roles/moderation (Phase 3)
```

## Deep-link targets

The routing model should eventually support semantic links to:

- current session;
- specific historical session;
- news item;
- announcement;
- public callsign profile if enabled.

Notifications should use these semantic destinations rather than positional tab assumptions.
