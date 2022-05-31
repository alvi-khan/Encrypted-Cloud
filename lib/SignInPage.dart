import 'package:encrypted_cloud/GoogleAccount.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignInPage();
}

class _SignInPage extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GoogleAccount> (
        builder: (context, account, child) {
          return Center(
            child: ElevatedButton(
              onPressed: () => account.signIn(),
              style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  primary: Colors.blueGrey.shade400,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              child: const Text("Sign In"),
            ),
          );
        }
    );
  }
}