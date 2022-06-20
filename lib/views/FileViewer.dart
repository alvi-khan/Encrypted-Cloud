import 'package:encrypted_cloud/components/NoOverscrollGlow.dart';
import 'package:encrypted_cloud/components/appbar/BasicAppBar.dart';
import 'package:encrypted_cloud/views/NoResultsPage.dart';
import 'package:encrypted_cloud/components/Refresh.dart';
import 'package:encrypted_cloud/utils/GoogleAccount.dart';
import 'package:encrypted_cloud/utils/FileHandler.dart';
import 'package:encrypted_cloud/components/filecard/FileCard.dart';
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
    FileHandler fileHandler = Provider.of<FileHandler>(context, listen: false);
    await fileHandler.init(context, account.user!);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Colors.blueGrey.shade800,
        body: const LoadingIndicator(size: 200, strokeWidth: 10, color: Colors.blueGrey),
      );
    }

    return Consumer<FileHandler>(
      builder: (context, fileHandler, child) {
        if (fileHandler.files.isEmpty) {
          return const NoResultsPage();
        }

        return  WillPopScope(
          onWillPop: () async {
            if (fileHandler.selections == 0) {
              return true;
            }
            else {
              fileHandler.clearSelections();
              return false;
            }
          },
          child: Scaffold(
            appBar: const BasicAppBar(),
            backgroundColor: Colors.blueGrey.shade800,
            body: Stack(
                children: [
                  SafeArea(
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: Refresh(
                        onRefresh: () => loadFiles(),
                        child: NoOverscrollGlow(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                            ),
                            itemCount: fileHandler.files.length,
                            itemBuilder: (context, index) {
                              return FileCard(fileHandler.files[index]);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const UploadButton(),
                ]
              ),
            ),
        );
      },
    );
  }
}