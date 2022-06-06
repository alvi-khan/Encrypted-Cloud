import 'dart:io';
import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';

class EncryptionHandler {
  String password = "Hello World!";
  var crypt = AesCrypt();

  EncryptionHandler() {
    crypt.setPassword(password);
    crypt.setOverwriteMode(AesCryptOwMode.rename);
  }

  File encryptFile(String directory, File file) {
    String filename = file.path.split(Platform.pathSeparator).last;
    File encryptedFile = File("$directory${Platform.pathSeparator}$filename.aes");
    crypt.encryptDataToFileSync(file.readAsBytesSync(), encryptedFile.path);
    return encryptedFile;
  }

  File decryptFile(String directory, File file) {
    String filename = file.path.split(Platform.pathSeparator).last;
    filename = filename.substring(0, filename.length - 4);
    File decryptedFile = File("$directory${Platform.pathSeparator}$filename");
    crypt.decryptFileSync(file.path, decryptedFile.path);
    return decryptedFile;
  }
}