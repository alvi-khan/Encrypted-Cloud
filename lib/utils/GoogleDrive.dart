import 'dart:async';
import 'dart:io';
import 'package:encrypted_cloud/enums/FileState.dart';
import 'package:encrypted_cloud/utils/EncryptionHandler.dart';
import 'package:encrypted_cloud/utils/DecryptedFile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart";
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class AuthClient extends BaseClient {
  final Client _baseClient;
  final Map<String, String> _headers;

  AuthClient(this._baseClient, this._headers);

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request.headers.addAll(_headers);
    return _baseClient.send(request);
  }
}

class GoogleDrive extends ChangeNotifier{
  List<DecryptedFile> files = [];
  bool uploading = false;
  bool newUploads = false;
  var tempDir = Directory.systemTemp.createTempSync();
  EncryptionHandler encryptionHandler = EncryptionHandler();
  late drive.DriveApi api;

  Future<void> setAuthHeaders(GoogleSignInAccount user) async {
    Map<String, String> authHeaders = await user.authHeaders;
    AuthClient authClient = AuthClient(Client(), authHeaders);
    api = drive.DriveApi(authClient);
  }

  /// Create new root folder or retrieve existing one.
  Future<String?> getRoot() async {
    var response = await api.files.list(
        q: "name='Encrypted Cloud' and mimeType='application/vnd.google-apps.folder'",
        $fields: "files(id, trashed)"
    );
    if (response.files == null) return null;

    // retrieve first non-trashed root
    if (response.files!.isNotEmpty) {
      for (drive.File file in response.files!) {
        if (!file.trashed!)  return file.id;
      }
    }

    // if no root found or existing ones trashed
    drive.File file = await api.files.create(
      drive.File(name: 'Encrypted Cloud', mimeType: "application/vnd.google-apps.folder")
    );
    return file.id;
  }

  void uploadFiles() async {
    String? root = await getRoot();
    if (root == null) return; // TODO show error

    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;

    uploading = true;
    notifyListeners();

    List<String?> names = result.names;
    List<File> files = result.paths.map((path) => File(path!)).toList();

    for (var i = 0; i < files.length; i++) {
      String filename = names[i] ?? DateTime.now().toString();
      var driveFile = drive.File(name: "$filename.aes", parents: [root]);
      File encryptedFile = await compute(encryptionHandler.encryptFile, files[i]);
      final result = await api.files.create(
          driveFile,
          uploadMedia: drive.Media(encryptedFile.openRead(), encryptedFile.lengthSync())
      );
      // TODO show error
    }

    newUploads = true;
    uploading = false;
    notifyListeners();
  }

  Future<File?> downloadFile(drive.File driveFile) async {
    String filename = driveFile.name ?? DateTime.now().toString();
    File? file = File("${tempDir.path}${Platform.pathSeparator}$filename");

    drive.Media media = await api.files.get(driveFile.id!, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    List<int> dataStore = [];

    await for (final data in media.stream) {
      dataStore.addAll(data);
    }
    file.writeAsBytesSync(dataStore);
    if (filename.endsWith(".aes")) {
      try {
        file = await compute(encryptionHandler.decryptFile, file);
      } catch(exception) {
        file = null;
        // TODO display error
      }
    }
    return file;
  }

  Future<void> getFiles() async {
    String? root = await getRoot();
    if (root == null) return; // TODO display error

    String? pageToken;
    List<drive.File> newFiles = [];
    do {
      var fileList = await api.files.list(
          q: "'$root' in parents",
          pageSize: 20,
          pageToken: pageToken,
          supportsAllDrives: false,
          spaces: "drive",
          $fields: "nextPageToken, files(id, name, mimeType, trashed)"
      );
      pageToken = fileList.nextPageToken;
      if (fileList.files != null) {
        for (var driveFile in fileList.files!) {
          if (driveFile.name == null) continue;
          if (!driveFile.name!.endsWith(".aes"))  continue;
          if (driveFile.trashed!) continue;
          newFiles.add(driveFile);
        }}
    } while (pageToken != null);

    files = List.generate(newFiles.length, (index) => DecryptedFile(data: null));
    newUploads = false;
    notifyListeners();
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

  void deleteFile(DecryptedFile file) async {
    if (file.id == "")  return;
    api.files.delete(file.id);
    files.remove(file);
    notifyListeners();
  }
}