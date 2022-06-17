import 'package:flutter/material.dart';

class FileCardFooter extends StatelessWidget {
  const FileCardFooter({Key? key, required this.text}) : super(key: key);
  final String? text;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Container(
        color: Colors.black38,
        padding: const EdgeInsets.all(10),
        child: Text(
          text ?? "File not found.",
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}