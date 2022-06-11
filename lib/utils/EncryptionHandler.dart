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

  Future<File> encryptFile(File file) async {
    String filepath = await crypt.encryptFile(file.path);
    return File(filepath);
  }

  Future<File> decryptFile(File file) async {
    String filepath = await crypt.decryptFile(file.path);
    return File(filepath);
  }
}