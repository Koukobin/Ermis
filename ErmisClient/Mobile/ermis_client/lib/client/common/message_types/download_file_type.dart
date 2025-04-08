import '../../../core/exceptions/EnumNotFoundException.dart';

enum FileType {
  file(0),
  image(1),
  sound(2);

  final int id;
  const FileType(this.id);

  static final Map<int, FileType> _values = {
    for (final type in FileType.values) type.id: type,
  };

  static FileType fromId(int id) {
    FileType? type = _values[id];

    if (type == null) {
      throw EnumNotFoundException('No DownloadFileType found for id $id');
    }

    return type;
  }
}
