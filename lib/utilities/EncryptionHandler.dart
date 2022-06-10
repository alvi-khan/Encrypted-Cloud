import 'dart:io';
import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';

class EncryptionHandler {
  String? password;
  var crypt = AesCrypt();

  EncryptionHandler() {
    if (password != null) crypt.setPassword(password!);
    crypt.setOverwriteMode(AesCryptOwMode.rename);
  }

  void setPassword(String password) {
    crypt.setPassword(password);
  }

  Future<File> encryptFile(MapEntry<String, File> args) async {
    String directory = args.key;
    File file = args.value;
    String filename = file.path.split(Platform.pathSeparator).last;
    File encryptedFile = File("$directory${Platform.pathSeparator}$filename.aes");
    await crypt.encryptDataToFile(file.readAsBytesSync(), encryptedFile.path);
    return encryptedFile;
  }

  Future<File> decryptFile(MapEntry<String, File> args) async {
    String directory = args.key;
    File file = args.value;
    String filename = file.path.split(Platform.pathSeparator).last;
    filename = filename.substring(0, filename.length - 4);
    File decryptedFile = File("$directory${Platform.pathSeparator}$filename");
    await crypt.decryptFile(file.path, decryptedFile.path);
    return decryptedFile;
  }
}