import 'dart:io';

import 'package:encrypted_cloud/enums/FileState.dart';

class DecryptedFile {
  File? data;
  FileState state;
  bool selected;

  DecryptedFile({required this.data, this.state = FileState.loading, this.selected = false});
}