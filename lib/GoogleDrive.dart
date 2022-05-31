import 'dart:io';
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
  List<drive.File> files = [];
  bool newUploads = false;

  Future<String?> createRoot(GoogleSignInAccount account) async {
    final client = Client();
    var header = await account.authHeaders;
    var authClient = AuthClient(client, header);
    var api = drive.DriveApi(authClient);
    var response = await api.files.list(
        q: "name='Encrypted Cloud' and mimeType='application/vnd.google-apps.folder'"
    );
    if (response.files == null) return null;
    if (response.files!.isNotEmpty)  return response.files![0].id;
    drive.File file = await api.files.create(
      drive.File(name: 'Encrypted Cloud', mimeType: "application/vnd.google-apps.folder")
    );
    return file.id;
  }

  void uploadFiles(GoogleSignInAccount user) async {
    String? root = await createRoot(user);
    if (root == null) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null) return;

    final client = Client();
    var header = await user.authHeaders;
    var authClient = AuthClient(client, header);
    var api = drive.DriveApi(authClient);

    List<String?> names = result.names;
    List<File> files = result.paths.map((path) => File(path!)).toList();

    for (var i = 0; i < files.length; i++) {
      var driveFile = drive.File(name: names[i] ?? DateTime.now().toString(), parents: [root]);
      final result = await api.files.create(
          driveFile,
          uploadMedia: drive.Media(files[i].openRead(), files[i].lengthSync())
      );
    }

    newUploads = true;
    notifyListeners();
  }

  Future<void> getFiles(GoogleSignInAccount account) async {
    final client = Client();
    var header = await account.authHeaders;
    var authClient = AuthClient(client, header);
    var api = drive.DriveApi(authClient);

    var response = await api.files.list(
        q: "name='Encrypted Cloud' and mimeType='application/vnd.google-apps.folder'"
    );
    String? root = response.files?[0].id;
    if (root == null) return;

    String? pageToken;
    List<drive.File> newFiles = [];
    do {
      var fileList = await api.files.list(
          q: "'$root' in parents",
          pageSize: 20,
          pageToken: pageToken,
          supportsAllDrives: false,
          spaces: "drive",
          $fields: "nextPageToken, files(id, name, mimeType, thumbnailLink)"
      );
      pageToken = fileList.nextPageToken;
      newFiles.addAll(fileList.files!.toList());
    } while (pageToken != null);

    files = newFiles;
    newUploads = false;
    notifyListeners();
  }
}