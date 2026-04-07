# Decisions

## 2026-04-07: Riverpod only

- **Decision**: Use Riverpod (no BLoC, no Provider, no GetX).
- **Why**: Enforces consistency across two apps and `shared/` package.

## 2026-04-07: Local-first with Hive + in-memory streams

- **Decision**: Hive is the persistence layer; app state is driven by an in-memory stream layer that mirrors Hive writes.
- **Why**: Keeps UX responsive ("live") while remaining offline-friendly.

## 2026-04-07: Strict RBAC

- **Decision**: RBAC checks happen both at navigation and at service boundaries.
- **Why**: Prevents accidental cross-role features and protects future endpoints.

## 2026-04-07: 100ms token via local server

- **Decision**: Use a minimal `token_server/` to mint 100ms tokens.
- **Why**: Keeps secrets out of the app and matches production patterns.

