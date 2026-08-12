# GoTrek — Tourism Services Mobile App

Final-year group project (Licence, Systèmes Informatiques) — Université Ferhat Abbas Sétif 1, 2025.

GoTrek is a mobile platform concept that centralizes tourism services: destination discovery, accommodation booking, and interaction with local service providers (hotels, travel agencies, tour guides). Full specifications are in [`docs/cahier_des_charges.pdf`](docs/cahier_des_charges.pdf).

## My Role

**UI/UX Design (Figma) & Frontend Development (Flutter)** — Kannoufi Chiraz Lina

I designed the app's screens in Figma and implemented the Flutter frontend: 14 screens covering onboarding, authentication, destination browsing, hotel booking, payment flow, and user profile/favourites.

This was a 4-person team project. I contributed to the requirements analysis and UML modeling as a team, while backend architecture and database design were led by other team members.

## Tech Stack

| Layer | Technology |
|---|---|
| Design | Figma |
| Frontend | Flutter (Dart) |
| Backend *(specified, not yet implemented)* | Node.js |
| Database | PostgreSQL |
| Hosting *(specified)* | Firebase |
| Planned auth | OAuth 2.0 / JWT |

## Project Structure

```
GoTrek_app/
├── docs/                  # Requirements doc + UML diagrams
│   ├── cahier_des_charges.pdf
│   └── diagrams/
├── database/
│   └── schema.sql         # PostgreSQL schema
├── lib/
│   ├── main.dart
│   └── pages/              # 14 screens
├── assets/images/
├── test/
└── android/ ios/ web/ macos/ linux/ windows/   # Flutter platform targets
```

## Features (Frontend / UI)

- Onboarding & welcome flow
- Login / signup / SMS verification (UI only — see limitations below)
- Home feed & destination explorer with filters
- Hotel listing & hotel detail screens
- Flight detail screen
- Booking / payment method & payment success flow
- Favourites
- User profile

## Current State & Known Limitations

This repository currently contains the **frontend UI implementation only**. To be transparent about what is and isn't functional yet:

- No backend server is implemented — `database/schema.sql` defines the intended data model, but there is no API serving it.
- Screens display **static/mock data** rather than data fetched from a database.
- Login/signup do not perform real authentication (no OAuth2/JWT wired up yet).
- No state management library is used across screens.

## What's Needed to Make It Fully Functional

1. **Backend API** (Node.js, as specified) implementing REST endpoints for the entities in `database/schema.sql`: `Utilisateur`, `Touriste`, `Hotel`, `AgenceVoyage`, `GuideTouristique`, `Circuit`, `OffreGuidage`, `Hebergement`, `Reservation`.
2. **Database connection** — stand up PostgreSQL using `database/schema.sql` and connect it to the API.
3. **HTTP client in Flutter** (`http` or `dio` package) to replace hardcoded lists with real API calls.
4. **Real authentication** (JWT) replacing the current placeholder login check.
5. **State management** (e.g., Provider/Riverpod/Bloc) to pass data between screens instead of hardcoded constructor arguments.
6. **Firebase configuration** for hosting/deployment, as specified in the requirements doc.
7. **Error handling & loading states** for network requests.
8. **Test coverage** beyond the default Flutter widget test template.

## Running the App (current frontend-only state)

```bash
flutter pub get
flutter run
```

## Documentation

- [Cahier des charges (full spec)](docs/cahier_des_charges.pdf)
- [Use case diagram](docs/diagrams/use_case_diagram.png)
- [Class diagram](docs/diagrams/class_diagram.png)
- [Sequence diagram — Tourist flow](docs/diagrams/sequence_diagram_tourist.png)
- [Sequence diagram — Service providers flow](docs/diagrams/sequence_diagram_providers.png)

## Screenshots

*(Add screenshots of key screens here)*
