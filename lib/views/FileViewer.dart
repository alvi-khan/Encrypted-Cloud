import 'package:encrypted_cloud/components/DeleteFileConfirmationDialog.dart';
import 'package:encrypted_cloud/components/PasswordDialog.dart';
import 'package:encrypted_cloud/utils/DecryptedFile.dart';
import 'package:encrypted_cloud/utils/GoogleAccount.dart';
import 'package:encrypted_cloud/utils/GoogleDrive.dart';
import 'package:encrypted_cloud/components/FileCard.dart';
import 'package:encrypted_cloud/components/LoadingIndicator.dart';
import 'package:encrypted_cloud/components/UploadButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class FileViewer extends StatefulWidget {
  const FileViewer({Key? key}) : super(key: key);

  @override
  State<FileViewer> createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  bool loading = true;
  int selections = 0;
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
      String? password = await showDialog(
          context: context,
          builder: (context) => PasswordDialog()
      );
      if (password == null) {
        account.signOut();
        return;
      }
      drive.encryptionHandler.setPassword(password);
    }
    await drive.getFiles();
    setState(() => loading = false);
  }

  void toggleSelect(DecryptedFile file) {
    bool selected = file.selected;
    if (selected) {
      file.selected = false;
      setState(() => selections--);
    } else {
      file.selected = true;
      setState(() => selections++);
    }
  }

  void clearSelections(List<DecryptedFile> files) {
    for (var file in files) {file.selected = false;}
    setState(() => selections = 0);
  }

  void selectAll(List<DecryptedFile> files) {
    for (var file in files) {file.selected = true;}
    setState(() => selections = files.length);
  }

  void saveLocally(List<DecryptedFile> files) {
    files.where((file) => file.selected)
        .forEach((file) => file.saveLocally());
    clearSelections(files);
  }

  void deleteFiles(List<DecryptedFile> files) async {
    List<DecryptedFile> selectedFiles = files.where((file) => file.selected).toList();
    await Future.delayed(Duration.zero, () => {});
    bool? confirmed = await showDialog(
        context: context,
        builder: (context) => DeleteFileConfirmationDialog(fileCount: selectedFiles.length),
    );
    clearSelections(files);
    if (confirmed == null || !confirmed)  return;
    GoogleDrive drive = Provider.of<GoogleDrive>(context, listen: false);
    for (DecryptedFile file in selectedFiles) {
      drive.deleteFile(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: Colors.blueGrey.shade800,
        body: const LoadingIndicator(
          size: 200,
          strokeWidth: 10,
          color: Colors.blueGrey,
        ),
      );
    }

    return Consumer<GoogleDrive>(
      builder: (context, drive, child) {
        if (drive.files.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blueGrey.shade800,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: CircleAvatar(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(account.user!.photoUrl!),
                      // TODO handle no profile image case
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.blueGrey.shade800,
            body: Padding(
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
            ),
          );
        }

        return  Scaffold(
          appBar: AppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
            backgroundColor: Colors.blueGrey.shade800,
            title: selections == 0 ?
            Text("Encrypted Cloud", style: TextStyle(color: Colors.blueGrey.shade100)) :
            Row(
              children: [
                GestureDetector(
                    onTap: () => clearSelections(drive.files),
                    child: Icon(Icons.clear_rounded, size: 30, color: Colors.blueGrey.shade100)
                ),
                const SizedBox(width: 30),
                Text(
                    selections.toString(),
                    style: TextStyle(color: Colors.blueGrey.shade100)
                ),
              ],
            ),
            actions: [
              if (selections == 0)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: PopupMenuButton(
                    icon: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(account.user!.photoUrl!),
                          // TODO handle no profile image case
                        )
                    ),
                    color: Colors.blueGrey.shade500,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    splashRadius: null,
                    itemBuilder: (context) {
                      PopupMenuItem logoutButton = PopupMenuItem(
                          onTap: () => account.signOut(),
                          textStyle: const TextStyle(color: Colors.white),
                          child: Row(
                            children: const [
                              Icon(Icons.logout_rounded),
                              SizedBox(width: 10),
                              Text("Log Out"),
                            ],
                          )
                      );
                      return List.from([logoutButton]);
                    },
                  ),
                ),
              if (selections != 0)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: PopupMenuButton(
                    icon: Icon(Icons.more_vert_rounded, size: 30, color: Colors.blueGrey.shade100),
                    color: Colors.blueGrey.shade500,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    splashRadius: null,
                    itemBuilder: (context) {
                      PopupMenuItem saveButton = PopupMenuItem(
                          onTap: () => saveLocally(drive.files),
                          enabled: selections != 0,
                          textStyle: const TextStyle(color: Colors.white),
                          child: Row(
                            children: const [
                              Icon(Icons.save_alt_rounded),
                              SizedBox(width: 10),
                              Text("Download"),
                            ],
                          )
                      );
                      PopupMenuItem selectAllButton = PopupMenuItem(
                          onTap: () => selectAll(drive.files),
                          enabled: selections != drive.files.length,
                          textStyle: const TextStyle(color: Colors.white),
                          child: Row(
                            children: const [
                              Icon(Icons.check_rounded),
                              SizedBox(width: 10),
                              Text("Select All"),
                            ],
                          )
                      );
                      PopupMenuItem deleteButton = PopupMenuItem(
                          onTap: () => deleteFiles(drive.files),
                          enabled: selections != 0,
                          textStyle: const TextStyle(color: Colors.white),
                          child: Row(
                            children: const [
                              Icon(Icons.delete_rounded),
                              SizedBox(width: 10),
                              Text("Delete"),
                            ],
                          )
                      );
                      return List.from([saveButton, selectAllButton, deleteButton]);
                    },
                  ),
                ),
            ],
          ),
          backgroundColor: Colors.blueGrey.shade800,
          body: Stack(
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
                        return FileCard(
                          file: drive.files[index],
                          selecting: selections != 0,
                          toggleSelect: () => toggleSelect(drive.files[index]),
                        );
                      },
                    ),
                  ),
                ),
                const UploadButton(),
              ]
            ),
          );
      },
    );
  }
}