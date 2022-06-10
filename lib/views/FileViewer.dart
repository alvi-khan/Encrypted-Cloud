import 'package:encrypted_cloud/components/PasswordDialog.dart';
import 'package:encrypted_cloud/utilities/GoogleAccount.dart';
import 'package:encrypted_cloud/utilities/GoogleDrive.dart';
import 'package:encrypted_cloud/components/FileCard.dart';
import 'package:encrypted_cloud/components/LoadingIndicator.dart';
import 'package:encrypted_cloud/components/UploadButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FileViewer extends StatefulWidget {
  const FileViewer({Key? key}) : super(key: key);

  @override
  State<FileViewer> createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  bool loading = true;
  late GoogleAccount account;

  @override
  void initState() {
    super.initState();
    account = Provider.of<GoogleAccount>(context, listen: false);
    Future.delayed(Duration.zero, () => loadFiles());
  }

  void loadFiles() async {
    GoogleDrive drive = Provider.of<GoogleDrive>(context, listen: false);
    await drive.setAuthHeaders(account.user!);
    if (drive.encryptionHandler.password == null) {
      String password = await showDialog(
          context: context,
          builder: (context) => PasswordDialog()
      );
      drive.encryptionHandler.setPassword(password);
    }
    await drive.getFiles();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const LoadingIndicator(
        size: 200,
        strokeWidth: 10,
        color: Colors.blueGrey,
      );
    }

    return Consumer<GoogleDrive>(
      builder: (context, drive, child) {

        if (drive.newUploads && account.user != null) {
          drive.getFiles();
        }

        if (drive.files.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.image_rounded, size: 150, color: Colors.blueGrey.shade100),
                const SizedBox(height: 20),
                Text(
                  "Images you upload will show up here.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueGrey.shade100, fontSize: 20, height: 1.5),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            SafeArea(
              child: Container(
                margin: const EdgeInsets.all(10),
                child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: drive.files.length,
                    itemBuilder: (context, index) {
                      return FileCard(drive.files[index], drive.fileStates[index]);
                    }
                ),
              ),
            ),
            const UploadButton(),
          ]
        );
      },
    );
  }
}