import 'package:shared/src/rbac/role.dart';

class RbacException implements Exception {
  RbacException(this.message);
  final String message;

  @override
  String toString() => 'RbacException($message)';
}

void requireRole({
  required Role actual,
  required Set<Role> allowed,
  String? context,
}) {
  if (!allowed.contains(actual)) {
    final c = context == null ? '' : ' ($context)';
    throw RbacException('Role ${actual.toWire()} not allowed$c');
  }
}

