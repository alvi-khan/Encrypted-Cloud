import 'dart:io';

import 'package:encrypted_cloud/enums/FileState.dart';
import 'package:permission_handler/permission_handler.dart';

class DecryptedFile {
  String id = "";
  File? data;
  String thumbnailId = "";
  File? thumbnail;
  FileState state = FileState.loading;
  FileState thumbnailState = FileState.loading;
  bool selected = false;

  DecryptedFile();

  String? getFileName() {
    if (thumbnail == null)  return null;
    return thumbnail!.path.split(Platform.pathSeparator).last;
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
    File savedFile = await File(filepath).create(recursive: true);
    savedFile.writeAsBytesSync(data!.readAsBytesSync());
    // TODO show progress
  }
}