# Product Definition — QO-100 TR

## Vision

QO-100 TR is a Turkish mobile community application for amateur radio operators who follow or participate in QO-100 activity, with TA-NET 777 as the initial community anchor.

The app should unify the fragmented current workflow—live listening, weekly attendance, community news, notifications, and operator identity—inside one mobile experience.

## Primary problem

Today the community workflow is split across different places. The existing website already contains valuable participation and live-listening functionality, but the mobile product should make that workflow easier to use, easier to remember, and useful outside the weekly session.

A mobile app that is opened only once per week will quickly lose engagement. Therefore the product must combine the weekly TA-NET 777 ritual with recurring content and notifications.

## Target users

### 1. Active QO-100 operator

An amateur radio operator who actively transmits through QO-100 and wants to:

- listen to the weekly activity;
- record participation;
- see other participants;
- track personal history;
- follow announcements and news.

### 2. SWL / listener

A user who listens but does not transmit and wants to:

- access the live stream;
- register SWL participation;
- follow activity and community news.

### 3. Community administrator

A trusted operator who can later manage:

- weekly sessions;
- exercise/scenario notes;
- news or announcement sources;
- community moderation functions.

## MVP navigation

The primary mobile navigation has five persistent tabs:

1. **Ana Sayfa**
2. **Canlı**
3. **Katılım**
4. **Haberler**
5. **Profil**

## MVP scope

### Authentication and onboarding

- account creation/login;
- operator profile creation;
- callsign;
- name;
- city/QTH;
- Maidenhead locator;
- participation identity stored for future check-ins.

### Ana Sayfa

- next/current weekly session summary;
- frequency/time display;
- live-listening shortcut;
- weekly participation summary;
- check-in shortcut;
- recent announcements;
- news preview.

### Canlı

Initial version:

- embedded WebView or approved compatible live-listening integration;
- session/frequency context;
- fast access from the home screen.

Later version may use a native audio player if a stable stream endpoint is available.

### Katılım

- current weekly session;
- direct/SWL participation selection;
- one-tap check-in using saved profile information;
- live participant list;
- direct/SWL totals;
- weekly detail/history access.

### Haberler

- community news feed;
- RSS-backed sources where legally/technically suitable;
- TA-NET announcements;
- article/source links;
- categories such as QO-100, satellite, and community.

### Profil

- callsign identity;
- user information;
- station information;
- participation history summary;
- notification preferences.

## Phase 2

- province/city participation map;
- callsign search;
- historical weeks;
- top participation statistics;
- antenna/device profile;
- streaks;
- achievements/badges;
- richer personal statistics.

## Phase 3

- short community posts/forum;
- comments;
- moderation;
- reporting;
- moderator role;
- deeper administrator tooling.

## Non-goals for MVP

The first release will not attempt to become:

- a general-purpose amateur radio social network;
- a full QSO logging application;
- an SDR control application;
- a satellite tracking suite;
- a real-time voice/chat platform;
- a replacement for existing emergency communication infrastructure.

## Existing web capability to preserve

During project discovery the existing TA-NET 777 website was observed to provide:

- `777 Canlı Dinleme`;
- selectable historic week detail;
- Turkey-wide participation map;
- direct and SWL participant distinction;
- province detail;
- callsign participation search;
- top-10 direct participation;
- top-10 SWL participation;
- station history;
- Google/email authentication;
- weekly participation submission with callsign, name, Maidenhead locator, QTH, and SWL flag.

The mobile product should preserve the useful domain behavior even if the UI and backend integration change.

## Product principles

1. **Weekly ritual, daily usefulness.** The weekly session is the anchor; news and notifications keep the app relevant during the week.
2. **Fast participation.** Once a profile exists, weekly check-in should take only a few seconds.
3. **Community identity over social noise.** Callsign, activity, station, and participation history matter more than generic social features.
4. **Privacy by default.** Public location should be coarse-grained unless the user explicitly chooses otherwise.
5. **One source of truth.** Website and mobile app should eventually consume the same backend data rather than diverging databases.

## Success criteria for first public release

A release is successful when a user can:

1. install the app on Android or iOS;
2. create/login to an account;
3. create a callsign profile;
4. see the current/next TA-NET 777 session;
5. open live listening;
6. register direct or SWL participation;
7. see participation update;
8. read community news/announcements;
9. receive useful session notifications;
10. see their profile and basic participation summary.

## Open product decisions

The following must be confirmed before hard-coding production behavior:

- authoritative weekly frequency;
- authoritative weekly local/UTC start time;
- existing website backend/database technology;
- whether a stable public/private API already exists;
- exact live-stream integration method;
- official name/logo/brand ownership and store listing name;
- public visibility rules for participant location and station information.
