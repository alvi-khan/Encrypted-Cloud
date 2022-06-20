import 'dart:io';
import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:encrypted_cloud/components/dialog/PasswordDialog.dart';
import 'package:flutter/material.dart';

class EncryptionHandler {
  String? password;
  var crypt = AesCrypt();

  EncryptionHandler() {
    if (password != null) crypt.setPassword(password!);
    crypt.setOverwriteMode(AesCryptOwMode.rename);
  }

  Future<bool> setPassword(BuildContext context) async {
    if (password == null) {
      String? password = await showDialog(
          context: context,
          builder: (context) => const PasswordDialog()
      );
      if (password == null) {
        return false;
      }
      crypt.setPassword(password);
    }
    return true;
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