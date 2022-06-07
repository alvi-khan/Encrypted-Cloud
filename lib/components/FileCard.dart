import 'dart:io';

import 'package:encrypted_cloud/components/FileCardFooter.dart';
import 'package:encrypted_cloud/views/Fullscreen.dart';
import 'package:flutter/material.dart';

class FileCard extends StatelessWidget {
  const FileCard(this.file, {Key? key}) : super(key: key);
  final File file;
  final List<String> validExtensions = const [".png", ".jpg"];

  @override
  Widget build(BuildContext context) {
    String filename = file.path.split(Platform.pathSeparator).last;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: FileCardFooter(text: filename),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(10)
          ),
          child: !validExtensions.any(file.path.endsWith) ? null :
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Fullscreen(tappedFile: file)),
                );
              },
              child: Image.file(file, fit: BoxFit.cover)
          ),
        ),
      ),
    );
  }
}