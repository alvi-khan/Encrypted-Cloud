import 'package:flutter/material.dart';

class DeleteFileConfirmationDialog extends StatefulWidget {
  const DeleteFileConfirmationDialog({super.key, required this.fileCount});

  final int fileCount;

  @override
  State<DeleteFileConfirmationDialog> createState() => _DeleteFileConfirmationDialogState();
}

class _DeleteFileConfirmationDialogState extends State<DeleteFileConfirmationDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.blueGrey.shade400, width: 3)
      ),
      backgroundColor: Colors.blueGrey.shade800,
      title: Text(
        "Are you sure you want to delete ${widget.fileCount} file${widget.fileCount > 1 ? "s" : ""}?",
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
      titlePadding: const EdgeInsets.all(30),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context, false),
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontSize: 18),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            backgroundColor: Colors.blueGrey.shade400,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            fixedSize: const Size(100, 50),
          ),
          child: const Text("Cancel"),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontSize: 18),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            backgroundColor: Colors.redAccent.shade200,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            fixedSize: const Size(100, 50),
          ),
          child: const Text("Delete", style: TextStyle(color: Colors.white)),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.only(bottom: 20),
    );
  }
}