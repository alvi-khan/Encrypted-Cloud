import 'dart:io';

import 'package:encrypted_cloud/enums/FileState.dart';
import 'package:permission_handler/permission_handler.dart';

class DecryptedFile {
  String id;
  File? data;
  FileState state;
  bool selected;

  DecryptedFile({required this.data, this.id = "", this.state = FileState.loading, this.selected = false});

  String? getFileName() {
    if (data == null)  return null;
    return data!.path.split(Platform.pathSeparator).last;
  }

  void saveLocally() async {
    if (data == null) return;
    PermissionStatus status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await (Permission.storage.request());
      if (!status.isGranted) return;
      // TODO show error message;
    }
    Directory downloadsDir = Directory('/storage/emulated/0/Download');
    String filepath = "${downloadsDir.path}/${getFileName()!}";
    File savedFile = File(filepath);
    savedFile.writeAsBytesSync(data!.readAsBytesSync());
    // TODO show progress
  }
}