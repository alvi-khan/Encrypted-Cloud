import 'package:encrypted_cloud/components/appbar/ProfileMenuButton.dart';
import 'package:encrypted_cloud/components/appbar/SelectionMenuButton.dart';
import 'package:encrypted_cloud/utils/GoogleDrive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class BasicAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BasicAppBar({Key? key}) : super(key: key);

  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer<GoogleDrive>(
      builder: (context, drive, child) {
        return AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
          backgroundColor: Colors.blueGrey.shade800,
          title: drive.selections == 0 ?
          Text("Encrypted Cloud", style: TextStyle(color: Colors.blueGrey.shade100)) :
          Row(
            children: [
              GestureDetector(
                  onTap: () => drive.clearSelections(),
                  child: Icon(Icons.clear_rounded, size: 30, color: Colors.blueGrey.shade100)
              ),
              const SizedBox(width: 30),
              Text(
                  drive.selections.toString(),
                  style: TextStyle(color: Colors.blueGrey.shade100)
              ),
            ],
          ),
          actions: [drive.selections == 0 ?  const ProfileMenuButton() : const SelectionMenuButton()],
        );
      },
    );
  }
}