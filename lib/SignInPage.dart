import 'package:encrypted_cloud/AccountManager.dart';
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
    return Consumer<AccountManager> (
        builder: (context, manager, child) {
          return Container(
            color: Colors.blueGrey.shade800,
            child: Center(
              child: manager.account == null ?
              SignInButton(onPressed: () => manager.signIn()) :
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AccountDetails(
                      imageUrl: manager.account!.photoUrl,
                      name: manager.account!.displayName ?? ""
                  ),
                  const SizedBox(height: 50),
                  SignOutButton(
                    onPressed: () => manager.signOut(),
                  )
                ],
              ),
            )
          );
        }
    );
  }

}

class AccountDetails extends StatelessWidget {
  const AccountDetails({Key? key, this.imageUrl, required this.name}) : super(key: key);
  final String? imageUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (imageUrl != null)
          CircleAvatar(
            foregroundImage: NetworkImage(imageUrl!),
            radius: 45,
          ),
        if (imageUrl != null) const SizedBox(width: 30),
        Text(name, style: const TextStyle(fontSize: 30, color: Colors.white))
      ],
    );
  }
}

class SignInButton extends StatelessWidget {
  const SignInButton({Key? key, required this.onPressed}) : super(key: key);
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed(),
      style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 20),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          primary: Colors.blueGrey.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
      ),
      child: const Text("Sign In"),
    );
  }
}

class SignOutButton extends StatelessWidget {
  const SignOutButton({Key? key, required this.onPressed}) : super(key: key);
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed(),
      style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 20),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          primary: Colors.blueGrey.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
      ),
      child: const Text("Sign Out"),
    );
  }
}