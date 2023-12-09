import 'package:encrypted_cloud/utils/GoogleAccount.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileMenuButton extends StatelessWidget {
  const ProfileMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    GoogleAccount account = Provider.of<GoogleAccount>(context, listen: false);
    String? image = account.user!.photoUrl;
    Widget icon;
    if (image == null) {
      icon = Icon(Icons.more_vert_rounded, size: 30, color: Colors.blueGrey.shade100);
    } else {
      icon = CircleAvatar(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.network(account.user!.photoUrl!)
          ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: PopupMenuButton(
        icon: icon,
        color: Colors.blueGrey.shade500,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        splashRadius: null,
        itemBuilder: (context) {
          PopupMenuItem logoutButton = PopupMenuItem(
              onTap: () => account.signOut(),
              textStyle: const TextStyle(color: Colors.white),
              child: const Row(
                children: [
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