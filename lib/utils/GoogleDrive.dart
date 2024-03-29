import 'dart:io';

import "package:http/http.dart";
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

class GoogleDrive {
  late drive.DriveApi api;
  String? root;
  String? thumbnailsFolder;

  void setAuthHeaders(Map<String, String> authHeaders) {
    AuthClient authClient = AuthClient(Client(), authHeaders);
    api = drive.DriveApi(authClient);
  }

  Future<void> getThumbnailFolder() async {
    if (root == null) return;

    var response = await api.files.list(
        q: "name='.thumbnails' and "
            "mimeType='application/vnd.google-apps.folder' and "
            "'$root' in parents",
        $fields: "files(id, trashed)",
    );
    if (response.files == null) return;

    if (response.files!.isNotEmpty) {
      for (drive.File file in response.files!) {
        if (!file.trashed!) {
          thumbnailsFolder = file.id;
          return;
        }
      }
    }

    drive.File file = await api.files.create(
        drive.File(
            name: '.thumbnails',
            mimeType: "application/vnd.google-apps.folder",
          parents: [root!],
        )
    );
    thumbnailsFolder = file.id;
  }

  /// Create new root folder or retrieve existing one.
  Future<void> getRoot() async {
    var response = await api.files.list(
        q: "name='Encrypted Cloud' and mimeType='application/vnd.google-apps.folder'",
        $fields: "files(id, trashed)"
    );
    if (response.files == null) return;

    // retrieve first non-trashed root
    if (response.files!.isNotEmpty) {
      for (drive.File file in response.files!) {
        if (!file.trashed!) {
          root = file.id;
          return;
        }
      }
    }

    // if no root found or existing ones trashed
    drive.File file = await api.files.create(
        drive.File(
            name: 'Encrypted Cloud',
            mimeType: "application/vnd.google-apps.folder"
        )
    );
    root = file.id;
  }

  Future<List<drive.File>> getThumbnailList() async {
    return await getFileList(parent: thumbnailsFolder);
  }

  Future<List<drive.File>> getFileList({String? parent}) async {
    String? pageToken;
    List<drive.File> newFiles = [];

    parent ??= root;
    if (parent == null) return newFiles;

    do {
      var fileList = await api.files.list(
          q: "'$parent' in parents",
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
    return newFiles;
  }

  Future<File> downloadFile(drive.File driveFile, String location) async {
    String filename = driveFile.name ?? DateTime.now().toString();
    File? file = await File("$location${Platform.pathSeparator}$filename").create(recursive: true);

    drive.Media media = await api.files.get(
        driveFile.id!,
        downloadOptions: drive.DownloadOptions.fullMedia
    ) as drive.Media;

    List<int> dataStore = [];
    await for (final data in media.stream) {
      dataStore.addAll(data);
    }
    file.writeAsBytesSync(dataStore);
    return file;
  }

  Future<drive.File> uploadFile(File file, String filename, String location) async {
    var driveFile = drive.File(name: filename, parents: [location]);
    drive.File result = await api.files.create(
        driveFile,
        uploadMedia: drive.Media(file.openRead(), file.lengthSync())
    );
    return result;
  }

  void deleteFile(String fileID) async {
    api.files.delete(fileID);
  }
}