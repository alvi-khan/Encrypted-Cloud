import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';

class AccountManager extends ChangeNotifier {
  GoogleSignInAccount? account;

  Future<void> signIn() async {
    if (account != null)  return;
    await GoogleSignIn.standard().signOut();
    account = await GoogleSignIn.standard(scopes: [DriveApi.driveScope]).signIn();
    notifyListeners();
  }

  Future<void> signOut() async {
    if (account == null)  return;
    GoogleSignIn.standard().signOut();
    account = null;
    notifyListeners();
  }
}