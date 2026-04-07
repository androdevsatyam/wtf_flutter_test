import 'package:hive/hive.dart';
import 'package:shared/src/storage/box_names.dart';

class SharedHive {
  SharedHive(this._hive);

  final HiveInterface _hive;

  Future<Box<String>> openUsersBox() => _hive.openBox<String>(BoxNames.users);
  Future<Box<String>> openMessagesBox() =>
      _hive.openBox<String>(BoxNames.messages);
  Future<Box<String>> openCallRequestsBox() =>
      _hive.openBox<String>(BoxNames.callRequests);
  Future<Box<String>> openRoomMetaBox() =>
      _hive.openBox<String>(BoxNames.roomMeta);
  Future<Box<String>> openSessionLogsBox() =>
      _hive.openBox<String>(BoxNames.sessionLogs);

  Future<Box<String>> openAppStateBox() =>
      _hive.openBox<String>(BoxNames.appState);
}

