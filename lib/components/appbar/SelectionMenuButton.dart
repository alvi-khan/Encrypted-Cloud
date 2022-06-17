import 'package:encrypted_cloud/components/dialog/DeleteFileConfirmationDialog.dart';
import 'package:encrypted_cloud/utils/GoogleDrive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectionMenuButton extends StatelessWidget {
  const SelectionMenuButton({Key? key}) : super(key: key);

  void deleteFiles(BuildContext context, GoogleDrive drive) async {
    await Future.delayed(Duration.zero, () => {});
    bool? confirmed = await showDialog(
      context: context,
      builder: (context) => DeleteFileConfirmationDialog(fileCount: drive.selections),
    );

    if (confirmed != null && confirmed) drive.deleteSelections();
    drive.clearSelections();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoogleDrive>(
      builder: (context, drive, child) {
        int selections = drive.files.where((file) => file.selected).length;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: PopupMenuButton(
            icon: Icon(Icons.more_vert_rounded, size: 30, color: Colors.blueGrey.shade100),
            color: Colors.blueGrey.shade500,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            splashRadius: null,
            itemBuilder: (context) {
              PopupMenuItem saveButton = PopupMenuItem(
                  onTap: () {
                    drive.saveLocally();
                    drive.clearSelections();
                  },
                  enabled: selections != 0,
                  textStyle: const TextStyle(color: Colors.white),
                  child: Row(
                    children: const [
                      Icon(Icons.save_alt_rounded),
                      SizedBox(width: 10),
                      Text("Download"),
                    ],
                  )
              );
              PopupMenuItem selectAllButton = PopupMenuItem(
                  onTap: () => drive.selectAll(),
                  enabled: selections != drive.files.length,
                  textStyle: const TextStyle(color: Colors.white),
                  child: Row(
                    children: const [
                      Icon(Icons.check_rounded),
                      SizedBox(width: 10),
                      Text("Select All"),
                    ],
                  )
              );
              PopupMenuItem deleteButton = PopupMenuItem(
                  onTap: () => deleteFiles(context, drive),
                  enabled: selections != 0,
                  textStyle: const TextStyle(color: Colors.white),
                  child: Row(
                    children: const [
                      Icon(Icons.delete_rounded),
                      SizedBox(width: 10),
                      Text("Delete"),
                    ],
                  )
              );
              return List.from([saveButton, selectAllButton, deleteButton]);
            },
          ),
        );
      },
    );
  }
}