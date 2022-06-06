import 'dart:async';
import 'dart:io';
import 'package:encrypted_cloud/EncryptionHandler.dart';
import 'package:file_picker/file_picker.dart';
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
  List<File> files = [];
  bool newUploads = false;
  var tempDir = Directory.systemTemp.createTempSync();
  EncryptionHandler encryptionHandler = EncryptionHandler();

  /// Create new root folder or retrieve existing one.
  Future<String?> getRoot(GoogleSignInAccount account) async {
    final client = Client();
    var header = await account.authHeaders;
    var authClient = AuthClient(client, header);
    var api = drive.DriveApi(authClient);
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

  void uploadFiles(GoogleSignInAccount user) async {
    String? root = await getRoot(user);
    if (root == null) return; // TODO show error

    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;

    final client = Client();
    var header = await user.authHeaders;
    var authClient = AuthClient(client, header);
    var api = drive.DriveApi(authClient);

    List<String?> names = result.names;
    List<File> files = result.paths.map((path) => File(path!)).toList();

    for (var i = 0; i < files.length; i++) {
      String filename = names[i] ?? DateTime.now().toString();
      var driveFile = drive.File(name: "$filename.aes", parents: [root]);
      File encryptedFile = encryptionHandler.encryptFile(tempDir.path, files[i]);
      final result = await api.files.create(
          driveFile,
          uploadMedia: drive.Media(encryptedFile.openRead(), encryptedFile.lengthSync())
      );
      // TODO show error
    }

    newUploads = true;
    notifyListeners();
  }

  Future<File?> downloadFile(drive.DriveApi api, drive.File driveFile) async {
    String filename = driveFile.name ?? DateTime.now().toString();
    File file = File("${tempDir.path}${Platform.pathSeparator}$filename");

    drive.Media media = await api.files.get(driveFile.id!, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    List<int> dataStore = [];

    await for (final data in media.stream) {
      dataStore.addAll(data);
    }
    file.writeAsBytesSync(dataStore);
    if (filename.endsWith(".aes")) {
      file = encryptionHandler.decryptFile(tempDir.path, file);
    }
    return file;
  }

  Future<void> getFiles(GoogleSignInAccount account) async {
    String? root = await getRoot(account);
    if (root == null) return; // TODO display error

    final client = Client();
    var header = await account.authHeaders;
    var authClient = AuthClient(client, header);
    var api = drive.DriveApi(authClient);

    String? pageToken;
    List<File> newFiles = [];
    do {
      var fileList = await api.files.list(
          q: "'$root' in parents",
          pageSize: 20,
          pageToken: pageToken,
          supportsAllDrives: false,
          spaces: "drive",
          $fields: "nextPageToken, files(id, name, mimeType, hasThumbnail, thumbnailLink)"
      );
      pageToken = fileList.nextPageToken;
      if (fileList.files != null) {
        for (var driveFile in fileList.files!) {
          if (driveFile.name == null || !driveFile.name!.endsWith(".aes"))  continue;
          File? file = await downloadFile(api, driveFile);
          if (file != null) newFiles.add(file);
        }}
    } while (pageToken != null);

    files = newFiles;
    newUploads = false;
    notifyListeners();
  }
}