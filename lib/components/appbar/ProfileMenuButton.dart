import 'package:encrypted_cloud/utils/GoogleAccount.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileMenuButton extends StatelessWidget {
  const ProfileMenuButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GoogleAccount account = Provider.of<GoogleAccount>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: PopupMenuButton(
        icon: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(account.user!.photoUrl!),
              // TODO handle no profile image case
            )
        ),
        color: Colors.blueGrey.shade500,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        splashRadius: null,
        itemBuilder: (context) {
          PopupMenuItem logoutButton = PopupMenuItem(
              onTap: () => account.signOut(),
              textStyle: const TextStyle(color: Colors.white),
              child: Row(
                children: const [
                  Icon(Icons.logout_rounded),
                  SizedBox(width: 10),
                  Text("Log Out"),
                ],
              )
          );
          return List.from([logoutButton]);
        },
      ),
    );
  }
}