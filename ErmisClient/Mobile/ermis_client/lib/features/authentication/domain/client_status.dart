import 'package:ermis_client/core/exceptions/EnumNotFoundException.dart';

enum ClientStatus {
  online(0),
  offline(1),
  doNotDisturb(2),
  invisible(3);

  final int id;
  const ClientStatus(this.id);

  static final Map<int, ClientStatus> _values = {
    for (final status in ClientStatus.values) status.id: status,
  };

  static ClientStatus fromId(int id) {
    return _values[id] ?? (throw EnumNotFoundException("Client status with given id not found: $id"));
  }
}
