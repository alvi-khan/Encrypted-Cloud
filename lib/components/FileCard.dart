import 'dart:io';

import 'package:encrypted_cloud/components/FileCardFooter.dart';
import 'package:encrypted_cloud/components/LoadingIndicator.dart';
import 'package:encrypted_cloud/enums/FileState.dart';
import 'package:encrypted_cloud/views/Fullscreen.dart';
import 'package:flutter/material.dart';

class FileCard extends StatelessWidget {
  const FileCard(this.file, this.fileState, {Key? key}) : super(key: key);
  final File? file;
  final FileState fileState;
  final List<String> validExtensions = const [".png", ".jpg"];

  @override
  Widget build(BuildContext context) {
    String filename = "";
    Widget? child;

    if (fileState == FileState.loading) {
      child = LoadingIndicator(
        size: 100,
        strokeWidth: 7,
        color: Colors.blueGrey.shade200,
      );
    }

    if (fileState == FileState.error) {
      child = Icon(
          Icons.error_outline_rounded,
          size: 100,
          color: Colors.blueGrey.shade200
      );
    }

    if (fileState == FileState.available) {
      filename = file!.path.split(Platform.pathSeparator).last;
      if (!validExtensions.any(filename.endsWith)) {
        child = null;
      } else {
        child = GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Fullscreen(tappedFile: file!)),
              );
            },
            child: Image.file(file!, fit: BoxFit.cover)
        );
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: filename == "" ? null : FileCardFooter(text: filename),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.blueGrey,
              borderRadius: BorderRadius.circular(10)
          ),
          child: child,
        ),
      ),
    );
  }
}