import 'package:encrypted_cloud/utilities/GoogleAccount.dart';
import 'package:encrypted_cloud/utilities/GoogleDrive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UploadButton extends StatelessWidget {
  const UploadButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GoogleAccount account = Provider.of<GoogleAccount>(context, listen: false);
    GoogleDrive drive = Provider.of<GoogleDrive>(context, listen: false);

    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        margin: const EdgeInsets.all(30),
        height: 75,
        width: 75,
        child: FloatingActionButton(
          onPressed: () => drive.uploadFiles(account.user!),
          backgroundColor: Colors.blueGrey.shade400,
          child: const Icon(Icons.upload_rounded, size: 50),
        ),
      ),
    );
  }
}