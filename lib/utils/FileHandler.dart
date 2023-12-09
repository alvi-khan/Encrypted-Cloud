import 'dart:async';
import 'dart:io';
import 'package:encrypted_cloud/enums/FileState.dart';
import 'package:encrypted_cloud/utils/GoogleDrive.dart';
import 'package:encrypted_cloud/utils/EncryptionHandler.dart';
import 'package:encrypted_cloud/utils/DecryptedFile.dart';
import 'package:encrypted_cloud/utils/ThumbnailGenerator.dart';
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
  ThumbnailGenerator thumbnailGenerator = ThumbnailGenerator();


  Future<bool> init(BuildContext context, GoogleSignInAccount user) async {
    Map<String, String> authHeaders = await user.authHeaders;
    cloudHandler.setAuthHeaders(authHeaders);
    bool havePassword = await encryptionHandler.setPassword(context);
    if (!havePassword)  return false;
    await getFiles();
    return true;
  }

  Future<void> getFiles() async {
    await cloudHandler.getRoot();
    await cloudHandler.getThumbnailFolder();
    if (cloudHandler.root == null || cloudHandler.thumbnailsFolder == null) return; // TODO show error

    // TODO handle cases where files and thumbnails don't match
    List<drive.File> newFiles = await cloudHandler.getFileList();
    List<drive.File> newFileThumbnails = await cloudHandler.getThumbnailList();
    files = List.generate(newFiles.length, (index) => DecryptedFile());
    notifyListeners();

    tempDir.delete(recursive: true);
    tempDir = Directory.systemTemp.createTempSync();
    downloadFiles(newFiles, newFileThumbnails);
    return;
  }

  void downloadFiles(List<drive.File> newFiles, List<drive.File> newFileThumbnails) async{
    for (drive.File file in newFiles) {
      int index = newFiles.indexOf(file);
      drive.File thumbnail = newFileThumbnails[index];
      File? data = await downloadFile(thumbnail, subfolder: "${Platform.pathSeparator}.thumbnails");
      files[index].id = file.id!;
      files[index].thumbnailId = thumbnail.id!;
      files[index].thumbnail = data;
      files[index].thumbnailState = data == null ? FileState.error : FileState.available;
      notifyListeners();
    }
  }

  Future<File?> downloadFile(drive.File driveFile, {String subfolder = ""}) async {
    File? file = await cloudHandler.downloadFile(driveFile, tempDir.path + subfolder);
    if (file.path.endsWith(".aes")) {
      try {
        file = await compute(encryptionHandler.decryptFile, file);
      } catch(exception) {
        file = null;  // TODO display error
      }
    }
    return file;
  }

  Future<void> downloadFullFile(DecryptedFile file) async {
    if (file.data == null && file.thumbnail == null)  return;
    if (file.data == null) {
      drive.File driveFile = drive.File();
      driveFile.id = file.id;
      driveFile.name = "${file.getFileName()}.aes";
      file.data = await downloadFile(driveFile);
      file.state = file.data == null ? FileState.error : FileState.available;
      notifyListeners();
    }
  }

  void uploadFiles() async {
    await cloudHandler.getRoot();
    await cloudHandler.getThumbnailFolder();
    if (cloudHandler.root == null || cloudHandler.thumbnailsFolder == null) return; // TODO show error

    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;

    uploading = true;
    notifyListeners();

    List<String?> names = result.names;
    List<File> files = result.paths.map((path) => File(path!)).toList();

    for (var i = 0; i < files.length; i++) {
      String filename = names[i] ?? DateTime.now().toString();
      File encryptedFile = await compute(encryptionHandler.encryptFile, files[i]);
      drive.File result = await cloudHandler.uploadFile(encryptedFile, "$filename.aes", cloudHandler.root!);
      File thumbnail = await thumbnailGenerator.getThumbnail("${tempDir.path}${Platform.pathSeparator}.thumbnails", files[i]);
      File encryptedThumbnail = await compute(encryptionHandler.encryptFile, thumbnail);
      drive.File resultThumbnail = await cloudHandler.uploadFile(encryptedThumbnail, "$filename.aes", cloudHandler.thumbnailsFolder!);
      addFile(result, resultThumbnail);
      // TODO show error
    }

    uploading = false;
    notifyListeners();
  }

  void addFile(drive.File driveFile, drive.File driveFileThumbnail) async {
    DecryptedFile file = DecryptedFile();
    file.id = driveFile.id!;
    file.thumbnailId = driveFileThumbnail.id!;
    files.insert(0, file);
    notifyListeners();

    File? data = await downloadFile(driveFileThumbnail, subfolder: "${Platform.pathSeparator}.thumbnails");
    file.thumbnail = data;
    file.thumbnailState = data == null ? FileState.error : FileState.available;
    notifyListeners();
  }

  void deleteFile(DecryptedFile file) {
    cloudHandler.deleteFile(file.id);
    cloudHandler.deleteFile(file.thumbnailId);
    files.remove(file);
    if (file.data != null)  file.data!.deleteSync();
    if (file.thumbnail != null) file.thumbnail!.deleteSync();
    notifyListeners();
  }

  void deleteSelections() async {
    List<DecryptedFile> selections = files.where((file) => file.selected).toList();
    for (DecryptedFile file in selections) {
      cloudHandler.deleteFile(file.id);
      cloudHandler.deleteFile(file.thumbnailId);
      files.remove(file);
      if (file.data != null)  file.data!.deleteSync();
      if (file.thumbnail != null) file.thumbnail!.deleteSync();
    }
  }

  void setSelected(int index, bool selected) {
    files[index].selected = selected;
    selections = selected ? selections + 1 : selections - 1;
    notifyListeners();
  }

  void clearSelections() {
    for (var file in files) {
      file.selected = false;
    }
    selections = 0;
    notifyListeners();
  }

  void selectAll() {
    for (var file in files) {
      file.selected = true;
    }
    selections = files.length;
    notifyListeners();
  }

  void saveLocally() {
    files.where((file) => file.selected).forEach((file) => saveFile(file));
  }

  void saveFile(DecryptedFile file) async {
    if (file.data == null && file.thumbnail == null)  return;
    if (file.data == null) {
      drive.File driveFile = drive.File();
      driveFile.id = file.id;
      driveFile.name = "${file.getFileName()}.aes";
      file.data = await downloadFile(driveFile);
      file.state = file.data == null ? FileState.error : FileState.available;
      notifyListeners();
    }
    if (file.data == null) return;
    file.saveLocally();
  }
}