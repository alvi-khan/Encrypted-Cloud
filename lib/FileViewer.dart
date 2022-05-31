import 'package:encrypted_cloud/GoogleAccount.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'GoogleDrive.dart';

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
    if (loading) {
      return const Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              color: Colors.blueGrey,
              strokeWidth: 10,
            ),
          )
      );
    }
    return Consumer<GoogleDrive>(
      builder: (context, drive, child) {

        if (drive.newUploads && account.user != null) {
          drive.getFiles(account.user!);
        }

        return Stack(
          children: [
            SafeArea(
              child: ListView.builder(
                  itemCount: drive.files.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        drive.files[index].name ?? "File not found.",
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
              ),
            ),
            Align(
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
            ),
          ]
        );
      },
    );
  }
}