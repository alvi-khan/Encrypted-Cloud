import 'dart:io';

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
        footer: FileFooter(text: filename),
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

class DownloadButton extends StatelessWidget {
  const DownloadButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueGrey.shade100, width: 2),
          shape: BoxShape.circle
        ),
        child: CircleAvatar(
          backgroundColor: Colors.blueGrey.shade400,
          radius: 20,
          child: const Icon(
            Icons.download_rounded,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class FileFooter extends StatelessWidget {
  const FileFooter({Key? key, required this.text}) : super(key: key);
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black38,
      padding: const EdgeInsets.all(10),
      child: Text(
        text ?? "File not found.",
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class UploadButton extends StatelessWidget {
  const UploadButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GoogleAccount account = Provider.of<GoogleAccount>(context);
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