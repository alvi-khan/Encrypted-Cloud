import 'package:encrypted_cloud/components/dialog/DeleteFileConfirmationDialog.dart';
import 'package:encrypted_cloud/utils/FileHandler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectionMenuButton extends StatelessWidget {
  const SelectionMenuButton({super.key});

  void deleteFiles(BuildContext context, FileHandler fileHandler) async {
    await Future.delayed(Duration.zero, () => {});
    bool? confirmed = await showDialog(
      context: context,
      builder: (context) => DeleteFileConfirmationDialog(fileCount: fileHandler.selections),
    );

    if (confirmed != null && confirmed) fileHandler.deleteSelections();
    fileHandler.clearSelections();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FileHandler>(
      builder: (context, fileHandler, child) {
        int selections = fileHandler.files.where((file) => file.selected).length;
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
                    fileHandler.saveLocally();
                    fileHandler.clearSelections();
                  },
                  enabled: selections != 0,
                  textStyle: const TextStyle(color: Colors.white),
                  child: const Row(
                    children: [
                      Icon(Icons.save_alt_rounded),
                      SizedBox(width: 10),
                      Text("Download"),
                    ],
                  )
              );
              PopupMenuItem selectAllButton = PopupMenuItem(
                  onTap: () => fileHandler.selectAll(),
                  enabled: selections != fileHandler.files.length,
                  textStyle: const TextStyle(color: Colors.white),
                  child: const Row(
                    children: [
                      Icon(Icons.check_rounded),
                      SizedBox(width: 10),
                      Text("Select All"),
                    ],
                  )
              );
              PopupMenuItem deleteButton = PopupMenuItem(
                  onTap: () => deleteFiles(context, fileHandler),
                  enabled: selections != 0,
                  textStyle: const TextStyle(color: Colors.white),
                  child: const Row(
                    children: [
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