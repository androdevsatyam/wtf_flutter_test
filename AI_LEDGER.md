# AI Ledger (copy/paste log)

This file records **every AI prompt**, **intent**, **tools used**, and **code snippets** added by the assistant.

## Entry Template

```md
### [YYYY-MM-DD] <component/area>

- **Intent**: <what this change is meant to achieve>
- **Prompt**: <the user prompt / system prompt excerpt that triggered it>
- **Tools used**:
  - <tool>: <what it did>
- **Files changed/added**:
  - `<path>`
- **Key code snippets**:

```<lang>
<snippet>
```

- **Notes / follow-ups**:
  - <todo / risk / assumption>
```

## Entries

### [2026-04-07] Repo scaffold

- **Intent**: Create the monorepo skeleton with two Flutter apps, a shared Dart package, and a token server.
- **Prompt**: "Create at D:\\WorkSpace\\TestAssignment\\wtf_flutter_test ... Guru ↔ Trainer Chat + Video Call System ... Riverpod ... Hive ... 100ms ... token_server ... docs"
- **Tools used**:
  - **Shell**: `flutter create` for `guru_app` and `trainer_app`
  - **Shell**: `dart create -t package` for `shared`
  - **Shell**: `npm init` + `npm install express cors dotenv` for `token_server`
- **Files changed/added**:
  - `guru_app/` (generated)
  - `trainer_app/` (generated)
  - `shared/` (generated)
  - `token_server/` (initialized)
- **Notes / follow-ups**:
  - Next: add RBAC, models, Hive repositories, and "live" stream layer in `shared`, then wire both apps.

### [2026-04-07] `shared/` domain + RBAC + local-first stores

- **Intent**: Centralize RBAC, data models, and local-first storage primitives shared by both apps.
- **Prompt**: "Implement strict RBAC ... Storage: Local-first using Hive, paired with an in-memory stream layer ... Data Models (Must Include) ..."
- **Tools used**:
  - **Edit**: Added models, RBAC, repos, and mock services
  - **Shell**: `dart pub get`, `dart analyze`
- **Files changed/added**:
  - `shared/lib/src/rbac/*`
  - `shared/lib/src/models/*`
  - `shared/lib/src/live/live_store.dart`
  - `shared/lib/src/storage/*`
  - `shared/lib/src/repositories/*`
  - `shared/lib/src/services/mock/*`
- **Key code snippets**:

```dart
// RBAC guard (shared/lib/src/rbac/rbac.dart)
void requireRole({required Role actual, required Set<Role> allowed, String? context}) {
  if (!allowed.contains(actual)) throw RbacException('Role ${actual.toWire()} not allowed');
}
```

```dart
// Local-first "live UX" store (shared/lib/src/live/live_store.dart)
class LiveStore<T> {
  Stream<List<T>> watch() => Stream.multi((multi) { multi.add(_value); _controller.stream.listen(multi.add); });
  void upsertBy(T item, {required bool Function(T a, T b) equals}) { /* ... */ }
}
```

- **Notes / follow-ups**:
  - Hive storage uses JSON strings (no adapters/codegen) for iteration speed; can be upgraded later.

### [2026-04-07] Guru App bootstrap + Member UX shell

- **Intent**: Guru app runs with Riverpod + Hive, auto-signs in as seeded member "DK", and shows Home tabs (Chat/Schedule/My Sessions).
- **Prompt**: "Guru App: Onboard and auto-assign a pre-seeded member profile \"DK\" ... Home UI shows Chat, Schedule, and My Sessions"
- **Tools used**:
  - **Edit**: Added Riverpod bootstrap, UI shell, chat/schedule/sessions screens
  - **Shell**: `flutter pub get`, `flutter analyze`, `flutter test`
- **Files changed/added**:
  - `guru_app/lib/src/core/providers.dart`
  - `guru_app/lib/src/features/*`
- **Key code snippets**:

```dart
// Auto sign-in on first run (guru_app/lib/src/features/bootstrap/bootstrap_screen.dart)
if (user == null) {
  Future<void>(() async => ref.read(authServiceProvider)!.signInAsUser(SeedData.memberDkId));
  return const Scaffold(body: Center(child: CircularProgressIndicator()));
}
```

### [2026-04-07] Trainer App bootstrap + Trainer UX shell

- **Intent**: Trainer app runs with Riverpod + Hive, login as seeded "Aarav (Lead Trainer)", and shows tabs (Members/Chats/Requests/Sessions).
- **Prompt**: "Trainer App: Login as pre-seeded \"Aarav (Lead Trainer)\" ... Home UI shows Members, Chats, Requests, and Sessions"
- **Tools used**:
  - **Edit**: Added Riverpod bootstrap, login screen, home tabs, approvals/declines
  - **Shell**: `flutter pub get`, `flutter analyze`, `flutter test`
- **Files changed/added**:
  - `trainer_app/lib/src/features/*`

### [2026-04-07] Token server scaffold (100ms placeholder)

- **Intent**: Provide a minimal HTTP endpoint for minting 100ms tokens (dev scaffold; placeholder token for now).
- **Prompt**: "RTC: 100ms SDK is mandatory ... accompanied by a minimal local token server"
- **Tools used**:
  - **Edit**: Added Express server + routes
  - **Shell**: `npm init`, `npm install`, `node index.js`
- **Files changed/added**:
  - `token_server/index.js`
  - `token_server/.env.example`
- **Key code snippets**:

```js
// POST /token (token_server/index.js)
app.post("/token", async (req, res) => {
  const { roomId, userId, role } = req.body || {};
  const token = `dev-token:${roomId}:${userId}:${role}:${Date.now()}`;
  return res.json({ token });
});
```

### [2026-04-07] Observability: Debug banner + DevPanel

- **Intent**: Add an in-app Debug Banner that opens a DevPanel with last 20 logs and env vars.
- **Prompt**: "Observability: Include an in-app Debug Banner opening a DevPanel showing the last 20 logs and env vars"
- **Tools used**:
  - **Edit**: Added `DebugBannerOverlay` + `DevPanel` widgets in both apps
- **Files changed/added**:
  - `guru_app/lib/src/core/devpanel.dart`
  - `trainer_app/lib/src/core/devpanel.dart`

### [2026-04-07] 100ms SDK + permissions + pre-join pipeline

- **Intent**: Integrate real 100ms Flutter SDK joining pipeline with camera/mic permission checks before every call, and a minimal in-call UI with mic/cam toggles and trainer end-room capability.
- **Prompt**: "start the actual 100ms SDK and camera, microphone etc permission pipeline ... check permissions everytime before start the call"
- **Tools used**:
  - **Edit**: Added `hmssdk_flutter`, `permission_handler`, `http` + screens and permission utilities
  - **Shell**: `flutter pub get`, `flutter analyze`, `flutter test`
- **Files changed/added**:
  - `guru_app/android/app/src/main/AndroidManifest.xml`
  - `trainer_app/android/app/src/main/AndroidManifest.xml`
  - `guru_app/ios/Runner/Info.plist`
  - `trainer_app/ios/Runner/Info.plist`
  - `guru_app/lib/src/features/call/*`
  - `trainer_app/lib/src/features/call/*`
- **Key code snippets**:

```dart
// Pre-join permission gate (guru_app/lib/src/features/call/prejoin_screen.dart)
await CallPermissions.ensure(); // requests camera/mic (and BT on Android) every time
final token = await TokenApi(baseUrl).fetchToken(roomId: roomId, userId: userId, role: role);
Navigator.push(context, MaterialPageRoute(builder: (_) => CallScreen(authToken: token, userName: name, isTrainer: isTrainer)));
```

```dart
// In-call mic/cam toggles (*/lib/src/features/call/call_screen.dart)
_hms.toggleMicMuteState();
_hms.toggleCameraMuteState();
```

### [2026-04-07] Real 100ms room creation on trainer approval

- **Intent**: Make Trainer approval create a real 100ms room via REST API and persist `RoomMeta.hmsRoomId` as a real joinable `room_id`.
- **Prompt**: "Implement the real 100ms room id so approve creates a real joinable links"
- **Tools used**:
  - **Edit**: Added `/rooms` endpoint to token server and wired a room provisioner into `MockCallService`
  - **Shell**: `dart analyze`, `flutter analyze`, `flutter test`, `npm install`
- **Files changed/added**:
  - `token_server/index.js` (added `POST /rooms` -> 100ms `/v2/rooms`)
  - `token_server/package.json` (added `axios`)
  - `token_server/.env.example` (added `HMS_TEMPLATE_ID` placeholder)
  - `shared/lib/src/services/room_provisioner.dart`
  - `shared/lib/src/services/token_server_room_provisioner.dart`
  - `shared/lib/src/services/mock/mock_call_service.dart` (uses provisioner on approve)
  - `guru_app/lib/src/core/providers.dart` and `trainer_app/lib/src/core/providers.dart` (inject provisioner)
- **Key code snippets**:

```js
// token_server/index.js
app.post("/rooms", async (req, res) => {
  const mgmt = getManagementToken();
  const response = await api.post("/rooms", { name, template_id: tpl });
  return res.json({ roomId: response.data?.id });
});
```

```dart
// shared MockCallService.approveRequest now provisions real room_id when configured
final roomId = await roomProvisioner!.createRoomId(callRequestId: existing.id, name: 'wtf_call_...');
```

