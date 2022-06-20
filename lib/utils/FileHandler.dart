import 'dart:async';
import 'dart:io';
import 'package:encrypted_cloud/enums/FileState.dart';
import 'package:encrypted_cloud/utils/GoogleDrive.dart';
import 'package:encrypted_cloud/utils/EncryptionHandler.dart';
import 'package:encrypted_cloud/utils/DecryptedFile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class FileHandler extends ChangeNotifier{
  List<DecryptedFile> files = [];
  int selections = 0;
  bool uploading = false;
  var tempDir = Directory.systemTemp.createTempSync();
  EncryptionHandler encryptionHandler = EncryptionHandler();
  GoogleDrive cloudHandler = GoogleDrive();


  Future<bool> init(BuildContext context, GoogleSignInAccount user) async {
    Map<String, String> authHeaders = await user.authHeaders;
    cloudHandler.setAuthHeaders(authHeaders);
    bool havePassword = await encryptionHandler.setPassword(context);
    if (!havePassword)  return false;
    await getFiles();
    return true;
  }

  Future<void> getFiles() async {
    String? root = await cloudHandler.getRoot();
    if (root == null) return; // TODO display error

    List<drive.File> newFiles = await cloudHandler.getFileList(root);
    files = List.generate(newFiles.length, (index) => DecryptedFile(data: null));
    notifyListeners();

    tempDir.delete(recursive: true);
    tempDir = Directory.systemTemp.createTempSync();
    downloadFiles(newFiles);
    return;
  }

  void downloadFiles(List<drive.File> newFiles) async{
    for (drive.File file in newFiles) {
      int index = newFiles.indexOf(file);
      File? data = await downloadFile(file);
      files[index].id = file.id!;
      files[index].data = data;
      files[index].state = data == null ? FileState.error : FileState.available;
      notifyListeners();
    }
  }

  Future<File?> downloadFile(drive.File driveFile) async {
    File? file = await cloudHandler.downloadFile(driveFile, tempDir.path);
    if (file.path.endsWith(".aes")) {
      try {
        file = await compute(encryptionHandler.decryptFile, file);
      } catch(exception) {
        file = null;  // TODO display error
      }
    }
    return file;
  }

  void uploadFiles() async {
    String? root = await cloudHandler.getRoot();
    if (root == null) return; // TODO show error

    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;

    uploading = true;
    notifyListeners();

    List<String?> names = result.names;
    List<File> files = result.paths.map((path) => File(path!)).toList();

    for (var i = 0; i < files.length; i++) {
      String filename = names[i] ?? DateTime.now().toString();
      File encryptedFile = await compute(encryptionHandler.encryptFile, files[i]);
      drive.File result = await cloudHandler.uploadFile(encryptedFile, "$filename.aes", root);
      addFile(result);
      // TODO show error
    }

    uploading = false;
    notifyListeners();
  }

  void addFile(drive.File driveFile) async {
    DecryptedFile file = DecryptedFile(data: null);
    file.id = driveFile.id!;
    files.insert(0, file);
    notifyListeners();

    File? data = await downloadFile(driveFile);
    file.data = data;
    file.state = data == null ? FileState.error : FileState.available;
    notifyListeners();
  }

  void deleteFile(DecryptedFile file) {
    cloudHandler.deleteFile(file.id);
    files.remove(file);
    file.data!.deleteSync();
    notifyListeners();
  }

  void deleteSelections() async {
    List<DecryptedFile> selections = files.where((file) => file.selected).toList();
    for (DecryptedFile file in selections) {
      cloudHandler.deleteFile(file.id);
      files.remove(file);
      file.data!.deleteSync();
    }
  }

  void setSelected(int index, bool selected) {
    files[index].selected = selected;
    selections = selected ? selections + 1 : selections - 1;
    notifyListeners();
  }

  void clearSelections() {
    files.forEach((file) => file.selected = false);
    selections = 0;
    notifyListeners();
  }

  void selectAll() {
    files.forEach((file) => file.selected = true);
    selections = files.length;
    notifyListeners();
  }

  void saveLocally() {
    files.where((file) => file.selected).forEach((file) => file.saveLocally());
  }
}