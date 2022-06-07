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
    loadFiles();
  }

  void loadFiles() async {
    await Provider.of<GoogleDrive>(context, listen: false).getFiles(account.user!);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading)  return const LoadingIndicator();

    return Consumer<GoogleDrive>(
      builder: (context, drive, child) {

        if (drive.newUploads && account.user != null) {
          drive.getFiles(account.user!);
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
                      return FileCard(drive.files[index]);
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