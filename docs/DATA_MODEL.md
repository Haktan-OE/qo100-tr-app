# Data Model — QO-100 TR

This is a proposed logical model for the mobile app. It is not yet a declaration that Firestore will become the authoritative backend for existing TA-NET 777 production data.

## Core entities

### UserProfile

```text
uid
callsign
name
city
locator
antenna
device
role
createdAt
updatedAt
```

Notes:

- `uid` is the internal account identifier.
- `callsign` is the primary community identity.
- Public location should be coarse-grained by default.
- `role` initially supports values such as `member`, `moderator`, `admin`.

### CommunitySession

```text
id
title
frequencyMHz
startAt
scenarioNote
isActive
createdBy
createdAt
updatedAt
```

A session represents one weekly TA-NET 777 activity or another explicitly managed community session.

### CheckIn

```text
id
sessionId
userId
callsign
participationType
city
locator
timestamp
```

`participationType`:

```text
direct
swl
```

The backend should prevent accidental duplicate check-ins for the same user/session unless product rules later explicitly allow corrections or multiple participation records.

### NewsItem

```text
id
source
title
summary
url
imageUrl
category
publishedAt
createdAt
```

Potential categories:

```text
qo100
satellite
community
announcement
```

### UserStats

Derived or materialized summary:

```text
userId
totalCheckIns
directCheckIns
swlCheckIns
currentStreak
longestStreak
lastCheckInAt
```

Stats can initially be computed on demand for a small dataset, then materialized when scale/performance justifies it.

### Achievement

Catalog entry:

```text
id
name
description
iconKey
ruleType
ruleValue
```

### UserAchievement

```text
userId
achievementId
unlockedAt
```

Achievements are Phase 2 and should not complicate MVP check-in writes.

### DeviceRegistration

For notifications:

```text
id
userId
fcmToken
platform
lastSeenAt
createdAt
```

Tokens should be refreshed/removed when invalid.

## Proposed Firestore collections

If Firestore is used as the first implementation:

```text
users/{uid}
sessions/{sessionId}
sessions/{sessionId}/checkins/{uid}
news/{newsId}
userStats/{uid}
achievements/{achievementId}
users/{uid}/achievements/{achievementId}
users/{uid}/devices/{deviceId}
```

Using the user's `uid` as the check-in document id under a session naturally supports one check-in per user per session.

## Example documents

### users/{uid}

```json
{
  "callsign": "TA2HAA",
  "name": "Haktan",
  "city": "Ankara",
  "locator": "KM69",
  "antenna": "80 cm offset",
  "device": "PlutoSDR",
  "role": "member"
}
```

### sessions/{sessionId}

```json
{
  "title": "TA-NET 777 Haftalık Buluşma",
  "frequencyMHz": 10489.777,
  "startAt": "server timestamp/date",
  "scenarioNote": null,
  "isActive": true
}
```

The frequency above is an example fixture based on the currently observed website, not a final canonical product constant.

### sessions/{sessionId}/checkins/{uid}

```json
{
  "userId": "firebase-uid",
  "callsign": "TA2HAA",
  "participationType": "direct",
  "city": "Ankara",
  "locator": "KM69",
  "timestamp": "server timestamp"
}
```

## Data ownership

### User-editable

- name;
- city;
- locator;
- antenna/device information;
- notification preferences.

Callsign changes may require stronger rules later because history and identity are associated with it.

### Admin-managed

- session creation/schedule;
- scenario notes;
- manually curated announcements;
- moderation roles.

### System-derived

- check-in timestamps;
- participation totals;
- streaks;
- achievement unlocks;
- notification token metadata.

## Security principles

The exact Firestore rules will be implemented with the backend setup, but the intended constraints are:

- users may edit only their own profile unless admin;
- normal users cannot assign themselves elevated roles;
- check-ins require authentication;
- check-in `userId` must equal the authenticated `uid`;
- check-in server-authoritative fields should not be freely forgeable;
- admin writes are protected by trusted role claims/rules;
- news/session read visibility may remain public if the product owner chooses;
- private contact/auth information must never be exposed in public participant documents.

## Existing website migration/integration

Before production data is created in a new datastore, inspect the current website backend and answer:

1. Where are existing users stored?
2. Where are historical attendance records stored?
3. Is Firebase already in use?
4. Can mobile authenticate against the same identity source?
5. Is there an API?
6. Can the web application be changed to consume the same new backend if migration is chosen?

Do not create a parallel production attendance database until this decision is made.
