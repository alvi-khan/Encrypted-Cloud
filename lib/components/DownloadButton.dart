import 'package:flutter/material.dart';

class DownloadButton extends StatelessWidget {
  const DownloadButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.blueGrey.shade100, width: 2),
            shape: BoxShape.circle
        ),
        child: CircleAvatar(
          backgroundColor: Colors.blueGrey.shade400,
          radius: 20,
          child: const Icon(
            Icons.download_rounded,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}