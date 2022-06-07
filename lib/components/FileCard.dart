import 'dart:io';

import 'package:encrypted_cloud/components/DownloadButton.dart';
import 'package:encrypted_cloud/components/FileCardFooter.dart';
import 'package:flutter/material.dart';

class FileCard extends StatelessWidget {
  const FileCard(this.file, {Key? key}) : super(key: key);
  final File file;

  @override
  Widget build(BuildContext context) {
    String filename = file.path.split(Platform.pathSeparator).last;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        header: const DownloadButton(),
        footer: FileCardFooter(text: filename),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(10)
          ),
          child: !file.path.endsWith(".jpg") ? null : Image.file(file, fit: BoxFit.cover),
        ),
      ),
    );
  }
}