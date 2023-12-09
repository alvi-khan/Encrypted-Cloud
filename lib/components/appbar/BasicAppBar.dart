import 'package:encrypted_cloud/components/appbar/ProfileMenuButton.dart';
import 'package:encrypted_cloud/components/appbar/SelectionMenuButton.dart';
import 'package:encrypted_cloud/utils/FileHandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class BasicAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BasicAppBar({super.key});

  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer<FileHandler>(
      builder: (context, fileHandler, child) {
        return AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
          backgroundColor: Colors.blueGrey.shade800,
          title: fileHandler.selections == 0 ?
          Text("Encrypted Cloud", style: TextStyle(color: Colors.blueGrey.shade100)) :
          Row(
            children: [
              GestureDetector(
                  onTap: () => fileHandler.clearSelections(),
                  child: Icon(Icons.clear_rounded, size: 30, color: Colors.blueGrey.shade100)
              ),
              const SizedBox(width: 30),
              Text(
                  fileHandler.selections.toString(),
                  style: TextStyle(color: Colors.blueGrey.shade100)
              ),
            ],
          ),
          actions: [fileHandler.selections == 0 ?  const ProfileMenuButton() : const SelectionMenuButton()],
        );
      },
    );
  }
}