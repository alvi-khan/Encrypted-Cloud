import 'package:flutter/material.dart';

class PasswordDialog extends StatefulWidget {
  const PasswordDialog({Key? key}) : super(key: key);

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  final TextEditingController controller = TextEditingController();
  bool hidden = true;

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
        autocorrect: false,
        enableSuggestions: false,
        obscureText: hidden,
        autofocus: true,
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 20),
        cursorColor: Colors.white,
        decoration: InputDecoration(
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            isDense: true,
            suffixIcon: IconButton(
              icon: Icon(
                hidden ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                setState(() => hidden = !hidden);
              },
            ),
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