import 'package:encrypted_cloud/components/LoadingIndicator.dart';
import 'package:encrypted_cloud/utils/GoogleDrive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UploadButton extends StatelessWidget {
  const UploadButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GoogleDrive drive = Provider.of<GoogleDrive>(context);

    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        margin: const EdgeInsets.all(30),
        height: 75,
        width: 75,
        child: FloatingActionButton(
          onPressed: drive.uploading ? () {} : () => drive.uploadFiles(),
          backgroundColor: Colors.blueGrey.shade400,
          child: drive.uploading ? LoadingIndicator(
              size: 30,
              strokeWidth: 5,
              color: Colors.blueGrey.shade200
          ) : const Icon(Icons.upload_rounded, size: 50),
        ),
      ),
    );
  }
}