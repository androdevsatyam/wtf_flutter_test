import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared/shared.dart';

final bootstrapProvider = FutureProvider<void>((ref) async {
  await Hive.initFlutter();

  final sharedHive = SharedHive(Hive);
  final usersBox = await sharedHive.openUsersBox();
  final messagesBox = await sharedHive.openMessagesBox();
  final callRequestsBox = await sharedHive.openCallRequestsBox();
  final roomMetaBox = await sharedHive.openRoomMetaBox();
  final sessionLogsBox = await sharedHive.openSessionLogsBox();
  final appStateBox = await sharedHive.openAppStateBox();

  final userRepo = UserRepo(usersBox);
  final messageRepo = MessageRepo(messagesBox);
  final callRequestRepo = CallRequestRepo(callRequestsBox);
  final roomMetaRepo = RoomMetaRepo(roomMetaBox);
  final sessionLogRepo = SessionLogRepo(sessionLogsBox);

  await userRepo.loadFromHive();
  await messageRepo.loadFromHive();
  await callRequestRepo.loadFromHive();
  await roomMetaRepo.loadFromHive();
  await sessionLogRepo.loadFromHive();

  ref
    ..read(userRepoProvider.notifier).state = userRepo
    ..read(messageRepoProvider.notifier).state = messageRepo
    ..read(callRequestRepoProvider.notifier).state = callRequestRepo
    ..read(roomMetaRepoProvider.notifier).state = roomMetaRepo
    ..read(sessionLogRepoProvider.notifier).state = sessionLogRepo;

  final auth = MockAuthService(appStateBox: appStateBox, userRepo: userRepo);
  await auth.ensureSeeded();

  ref.read(authServiceProvider.notifier).state = auth;
  ref.read(chatServiceProvider.notifier).state = MockChatService(messageRepo: messageRepo);
  ref.read(callServiceProvider.notifier).state = MockCallService(
    callRequestRepo: callRequestRepo,
    roomMetaRepo: roomMetaRepo,
    roomProvisioner: TokenServerRoomProvisioner(
      baseUrl: const String.fromEnvironment(
        'TOKEN_SERVER',
        defaultValue: 'http://localhost:8787',
      ),
      templateId: (() {
        const v = String.fromEnvironment('HMS_TEMPLATE_ID', defaultValue: '');
        return v.isEmpty ? null : v;
      })(),
    ),
  );
  ref.read(sessionLogServiceProvider.notifier).state =
      MockSessionLogService(sessionLogRepo: sessionLogRepo);
});

final userRepoProvider = StateProvider<UserRepo?>((ref) => null);
final messageRepoProvider = StateProvider<MessageRepo?>((ref) => null);
final callRequestRepoProvider = StateProvider<CallRequestRepo?>((ref) => null);
final roomMetaRepoProvider = StateProvider<RoomMetaRepo?>((ref) => null);
final sessionLogRepoProvider = StateProvider<SessionLogRepo?>((ref) => null);

final authServiceProvider = StateProvider<AuthService?>((ref) => null);
final chatServiceProvider = StateProvider<ChatService?>((ref) => null);
final callServiceProvider = StateProvider<CallService?>((ref) => null);
final sessionLogServiceProvider = StateProvider<SessionLogService?>((ref) => null);

final currentUserStreamProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(authServiceProvider)!;
  return auth.watchCurrentUser();
});

