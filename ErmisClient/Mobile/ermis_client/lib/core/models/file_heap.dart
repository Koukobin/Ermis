/* Copyright (C) 2024 Ilias Koukovinis <ilias.koukovinis@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:typed_data';

class LoadedInMemoryFile {
  String fileName;
  Uint8List fileBytes;

  LoadedInMemoryFile(this.fileName, this.fileBytes);

  void setFileName(String fileName) => this.fileName = fileName;
  void setFileBytes(Uint8List fileBytes) => this.fileBytes = fileBytes;

  String get getFileName => fileName;
  Uint8List get getFileBytes => fileBytes;

  @override
  int get hashCode {
    return fileName.hashCode ^ fileBytes.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoadedInMemoryFile) return false;
    return fileName == other.fileName && fileBytes == other.fileBytes;
  }

  @override
  String toString() {
    return 'File {fileName: $fileName, fileBytes: $fileBytes}';
  }
}