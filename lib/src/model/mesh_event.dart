import 'package:collection/collection.dart';

enum MeshEvent {
  showClose;

  static MeshEvent? fromString(String? value) {
    if (value == null) {
      return null;
    }

    return MeshEvent.values.firstWhereOrNull((e) => e.name == value);
  }
}
