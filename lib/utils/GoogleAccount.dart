import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';

class GoogleAccount extends ChangeNotifier {
  GoogleSignInAccount? user;

  Future<void> signIn() async {
    if (user != null)  return;
    await GoogleSignIn.standard().signOut();
    user = await GoogleSignIn.standard(scopes: [DriveApi.driveScope]).signIn();
    notifyListeners();
  }

  Future<void> signOut() async {
    if (user == null)  return;
    GoogleSignIn.standard().signOut();
    user = null;
    notifyListeners();
  }
}