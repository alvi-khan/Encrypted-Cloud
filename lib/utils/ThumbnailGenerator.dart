import 'dart:io';

import 'package:image/image.dart';

class ThumbnailGenerator {
  Future<File> getThumbnail(String directory, File file) async {
    String filename = file.path.split(Platform.pathSeparator).last;
    if (filename.endsWith("jpg") || filename.endsWith("jpeg")) {
      return await getJpgThumbnail(directory, file);
    }
    if (filename.endsWith("png")) return await getPngThumbnail(directory, file);
    return file;
  }

  Future<File> getJpgThumbnail(String directory, File file) async {
    String filename = file.path.split(Platform.pathSeparator).last;
    Image? image = decodeImage(file.readAsBytesSync());
    Image thumbnail = copyResize(image!, width: 600);
    thumbnail = copyRotate(thumbnail, 90);
    File thumbnailFile = await File('$directory${Platform.pathSeparator}$filename').create(recursive: true);
    thumbnailFile.writeAsBytesSync(encodeJpg(thumbnail));
    return thumbnailFile;
  }

  Future<File> getPngThumbnail(String directory, File file) async {
    String filename = file.path.split(Platform.pathSeparator).last;
    Image? image = decodeImage(file.readAsBytesSync());
    Image thumbnail = copyResize(image!, width: 600);
    thumbnail = copyRotate(thumbnail, 90);
    File thumbnailFile = await File('$directory${Platform.pathSeparator}$filename').create(recursive: true);
    thumbnailFile.writeAsBytesSync(encodePng(thumbnail));
    return thumbnailFile;
  }
}