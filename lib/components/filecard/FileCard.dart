import 'package:encrypted_cloud/components/filecard/FileCardFooter.dart';
import 'package:encrypted_cloud/components/LoadingIndicator.dart';
import 'package:encrypted_cloud/components/filecard/ImageFIleCard.dart';
import 'package:encrypted_cloud/enums/FileState.dart';
import 'package:encrypted_cloud/utils/DecryptedFile.dart';
import 'package:encrypted_cloud/utils/GoogleDrive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FileCard extends StatelessWidget {
  const FileCard(this.file, {Key? key}) : super(key: key);

  final DecryptedFile file;
  final List<String> validExtensions = const [".png", ".jpg"];

  @override
  Widget build(BuildContext context) {
    String filename = "";
    Widget? child;

    if (file.state == FileState.loading) {
      child = LoadingIndicator(size: 100, strokeWidth: 7, color: Colors.blueGrey.shade200);
    }

    if (file.state == FileState.error) {
      child = Icon(Icons.error_outline_rounded, size: 100, color: Colors.blueGrey.shade200);
    }

    if (file.state == FileState.available) {
      filename = file.getFileName()!;
      child = validExtensions.any(filename.endsWith) ? ImageFileCard(file: file) : null;
    }

    return Consumer<GoogleDrive>(
      builder: (context, drive, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: GridTile(
            footer: (filename == "" || drive.selections != 0) ? null : FileCardFooter(text: filename),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}