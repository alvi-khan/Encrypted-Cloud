import 'dart:io';

import 'package:encrypted_cloud/components/FileCardFooter.dart';
import 'package:encrypted_cloud/components/LoadingIndicator.dart';
import 'package:encrypted_cloud/enums/FileState.dart';
import 'package:encrypted_cloud/views/Fullscreen.dart';
import 'package:flutter/material.dart';

class FileCard extends StatelessWidget {
  const FileCard({
    Key? key,
    required this.file,
    required this.fileState,
    required this.selecting,
    required this.selected,
    required this.toggleSelect
  }) : super(key: key);

  final File? file;
  final FileState fileState;
  final bool selecting;
  final bool selected;
  final Function toggleSelect;
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
      } else if (!selecting) {
        child = GestureDetector(
            onLongPress: () => toggleSelect(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Fullscreen(tappedFile: file!)),
              );
            },
            child: Image.file(file!, fit: BoxFit.cover)
        );
      } else {
        child = GestureDetector(
          onTap: () => toggleSelect(),
          child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(file!, fit: BoxFit.cover),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5.0),
                  alignment: Alignment.topLeft,
                  child: Icon(
                    selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                    color: Colors.blueGrey.shade100,
                  ),
                ),
              ]
          ),
        );
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: filename == "" || selecting ? null : FileCardFooter(text: filename),
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