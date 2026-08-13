# GoTrek — Tourism Services Mobile App

Final-year group project (Licence, Systèmes Informatiques) — Université Ferhat Abbas Sétif 1, 2025.

GoTrek centralizes tourism services in one app: discovering destinations, booking flights and stays, and joining guided experiences. Full specifications are in [`docs/cahier_des_charges.pdf`](docs/cahier_des_charges.pdf).

## My Role

**UI/UX Design (Figma) & Frontend Development (Flutter)** — Kannoufi Chiraz Lina

I designed the app's screens in Figma and implemented the Flutter frontend: onboarding, authentication, destination browsing, flight and hotel booking, checkout, favourites and profile.

This was a 4-person team project. I contributed to the requirements analysis and UML modelling as a team; backend architecture and the original database schema were led by other team members.

## Tech Stack

| Layer | Technology |
|---|---|
| Design | Figma |
| Frontend | Flutter 3.29 / Dart 3.7 |
| State management | Riverpod (`flutter_riverpod`) |
| Local persistence | `shared_preferences` |
| Formatting | `intl` |
| Database *(schema only, no server yet)* | PostgreSQL |
| Backend *(specified, not implemented)* | Node.js |

## Architecture

The app is organised in three layers. Screens never touch data sources directly — they read from providers, which read from repositories.

```
lib/
├── main.dart                  # runApp(ProviderScope(GoTrekApp()))
├── app/
│   ├── gotrek_app.dart        # MaterialApp, light + dark themes
│   ├── app_routes.dart        # named routes + typed navigation helpers
│   └── app_shell.dart         # bottom-nav shell (IndexedStack)
├── core/
│   ├── theme/                 # colour tokens, 4pt spacing scale, ThemeData
│   ├── utils/                 # formatters, form validators
│   └── widgets/               # shared UI: cards, states, search, rating, …
├── data/
│   ├── models/                # Destination, Hotel, Experience, Booking, …
│   ├── seed/                  # the in-app catalogue, in one place
│   └── repositories/          # catalog, auth, favourites, bookings
├── state/                     # Riverpod providers and controllers
└── features/                  # one folder per screen area
    ├── onboarding/  auth/  home/  explore/  destination/
    └── stays/  experiences/  attractions/  checkout/  favorites/  profile/
```

**Data flow:** `SeedCatalog` → `CatalogRepository` → `FutureProvider` → screen. Replacing the seed data with an HTTP client is a change to the repositories only; nothing in `features/` knows where the data came from.

## Features

Everything listed here works in the app as shipped.

- **Onboarding** — swipe-to-start welcome screen over a softened backdrop.
- **Guest access** — the whole app is browsable without an account. Signing in is only asked for when an action belongs to an account (saving a place, booking, viewing your bookings), and the action resumes automatically once you are in.
- **Authentication** — login and sign-up with full form validation, password visibility toggle, and a four-digit confirmation step. The session persists across restarts.
- **Home = your city** — stays, landmarks and activities in the city you are in, with a search box that filters within that city. The location control opens a picker; the Flights shortcut opens the departures board.
- **Explore = trips elsewhere** — the world's most-visited destinations, searchable and filterable by category, each with a return trip you can book. Your current city is deliberately excluded.
- **Flights** — today's departures from your city with times, durations, fares and seats left.
- **Trip details** — the real outbound and return legs with times, airport codes and durations, a traveller stepper, and the stays available in that city.
- **Stays** — search and a working sort (price ascending/descending, top rated); detail screens with facilities, an expandable description, a date-range picker and a room stepper.
- **Experiences** — guided tours with duration, next date and a guest stepper.
- **Checkout** — itemised price breakdown with a service fee, payment-method selection, and a booking that is actually stored.
- **Bookings** — every confirmed booking with its reference and status, and the ability to cancel one.
- **Favourites** — save destinations, stays, experiences and attractions; persisted on the device and reflected in a badge on the nav bar.
- **Throughout** — loading, empty and error states; a light default theme (a dark theme is built but not wired to the device setting); layouts that adapt from phone to desktop widths.

## Current State & Known Limitations

This repository is the **frontend implementation**. To be precise about what is and is not real:

- **No backend server.** `database/schema.sql` defines the intended data model, but nothing serves it.
- **Only one city has local content.** New York is populated; the location picker lists other cities but marks them as unavailable rather than pretending otherwise.
- **Some destinations have no photography.** The cities added to Explore have no licensed images in `assets/`, so their cards draw a generated gradient cover keyed off the city name instead of a stock photo.
- **Data is seeded locally.** `lib/data/seed/seed_catalog.dart` holds the catalogue. The repositories return it behind a small artificial delay so the loading states are genuinely exercised. Trip dates are generated relative to today, so nothing shows as already departed.
- **Authentication is local.** Any well-formed email and password opens a session; there is no credential store and no OAuth2/JWT yet. The sign-up confirmation code is generated on the device and displayed on screen, because there is no SMS gateway — the check itself is real, and a wrong code is rejected.
- **Payment is not processed.** Choosing a card and confirming stores a booking locally; no payment provider is contacted. No card numbers are captured or stored anywhere.
- **Some controls are deliberately inert.** Social sign-in, notifications, support and a few profile entries are part of the design but have nothing behind them; they say so when tapped rather than doing nothing.

Favourites, bookings and the session are persisted with `shared_preferences`, so they survive a restart on the device.

## What's Needed to Make It Fully Functional

1. **Backend API** (Node.js, as specified) over the entities in `database/schema.sql`.
2. **PostgreSQL instance** created from that schema and connected to the API.
3. **HTTP client** (`http` or `dio`) behind the existing repository interfaces — the screens do not change.
4. **Real authentication** (JWT) replacing `AuthRepository`, and an SMS provider for the confirmation step.
5. **A payment provider** for checkout.
6. **Server-side favourites and bookings**, so they follow the account rather than the device.

## Database

[`database/schema.sql`](database/schema.sql) — PostgreSQL.

The original model was designed by a teammate from the class diagram in the cahier des charges. I revised it so it covers what the app actually handles: destinations, categories, attractions, flights and trip offers, hotel amenities, favourites, payment methods, payments and reviews. Along the way the three identical service-provider tables were merged into one, `circuit.destinations TEXT[]` became a join table, statuses became `ENUM` types, and ratings are derived from reviews through a view rather than stored on the row. Header comments in the file record each change.

The schema has not been executed against a live PostgreSQL instance.

## Running the App

```bash
flutter pub get
```

```bash
flutter run
```

Quality gates — both are clean:

```bash
flutter analyze
```

```bash
flutter test
```

`analysis_options.yaml` promotes unused imports, dead code and deprecated API use to **errors**, so `flutter analyze` failing means the build is broken, not merely untidy.

## Tests

61 tests covering:

- **Unit** — validators, display formatters, model arithmetic and JSON round-trips.
- **Controllers** — favourites and bookings including their persistence, and the catalogue search/filter/sort logic.
- **Widget** — the explore, stays and favourites screens.
- **End to end** — `test/widget/app_flow_test.dart` boots the real app at a phone viewport and covers guest browsing, the sign-in gate on saving and booking, the location picker, home search, the flights board, and welcome → explore → trip detail → checkout → confirmation.

## Documentation

- [Cahier des charges (full spec)](docs/cahier_des_charges.pdf)
- [Use case diagram](docs/diagrams/use_case_diagram.png)
- [Class diagram](docs/diagrams/class_diagram.png)
- [Sequence diagram — Tourist flow](docs/diagrams/sequence_diagram_tourist.png)
- [Sequence diagram — Service providers flow](docs/diagrams/sequence_diagram_providers.png)
