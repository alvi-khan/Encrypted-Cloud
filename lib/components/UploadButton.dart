import 'package:encrypted_cloud/components/LoadingIndicator.dart';
import 'package:encrypted_cloud/utils/FileHandler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UploadButton extends StatelessWidget {
  const UploadButton({super.key});

  @override
  Widget build(BuildContext context) {
    FileHandler fileHandler = Provider.of<FileHandler>(context);

    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        margin: const EdgeInsets.all(30),
        height: 75,
        width: 75,
        child: FloatingActionButton(
          onPressed: fileHandler.uploading ? () {} : () => fileHandler.uploadFiles(),
          backgroundColor: Colors.blueGrey.shade400,
          child: fileHandler.uploading ? LoadingIndicator(
              size: 30,
              strokeWidth: 5,
              color: Colors.blueGrey.shade200
          ) : const Icon(Icons.upload_rounded, size: 50),
        ),
      ),
    );
  }
}