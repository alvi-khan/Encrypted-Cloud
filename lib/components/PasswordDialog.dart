import 'package:flutter/material.dart';

class PasswordDialog extends StatelessWidget {
  PasswordDialog({Key? key}) : super(key: key);
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.blueGrey.shade400, width: 3)
      ),
      backgroundColor: Colors.blueGrey.shade800,
      title: const Text("Enter Password", style: TextStyle(color: Colors.white)),
      titlePadding: const EdgeInsets.all(30),
      content: TextField(
        autofocus: true,
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 20),
        cursorColor: Colors.white,
        decoration: const InputDecoration(
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            isDense: true,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (controller.text.isEmpty) return;
            Navigator.pop(context, controller.text);
          },
          style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              primary: Colors.blueGrey.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
          ),
          child: const Text("Continue"),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.symmetric(vertical: 30),
    );
  }

}