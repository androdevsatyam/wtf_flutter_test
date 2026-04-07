# Architecture

## Goals

- **Two localized Flutter apps** in one repository:
  - **Guru App** (Member role)
  - **Trainer App** (Trainer role)
- **Android + iOS only**
- **Riverpod only** for state management
- **Local-first** storage with Hive, plus an **in-memory stream layer** to make UX feel live
- **Strict RBAC** across the entire codebase (Member vs Trainer)
- **RTC via 100ms** plus a minimal token server

## Repository layout

- `guru_app/`: Flutter app (Member UX, primary color `#1769E0`)
- `trainer_app/`: Flutter app (Trainer UX, primary color `#E50914`)
- `shared/`: Dart package
  - models (User/Message/CallRequest/SessionLog/RoomMeta)
  - RBAC and guards
  - services abstractions (AuthService/ChatService/CallService/SessionLogService)
  - Hive repositories + in-memory stream layer
  - shared UI + utils
- `token_server/`: minimal HTTP server that returns a 100ms token (dev/local)

## High-level flow

1. **Mock auth** selects/loads a local `User` from Hive (seeded on first run).
2. **RBAC guard** is evaluated at:
   - navigation (route gating)
   - service entry points (defensive checks)
3. **Data writes** go to Hive (source of truth).
4. **Live UX** is achieved by emitting updates immediately through in-memory streams, then reconciling with Hive writes.
5. **Call scheduling** creates a `CallRequest` and applies conflict checks.
6. **Trainer approval** creates `RoomMeta` with 100ms room/roles; both apps show **Join Call** 10 minutes prior.
7. **Session logs** are created automatically at call end; member can rate; trainer can add notes.

## Observability

- A small in-app **Debug Banner** opens a **DevPanel** that shows:
  - last 20 app logs
  - key env/config values (non-secret only)
  - snackbars for surfaced errors

