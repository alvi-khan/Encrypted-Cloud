import 'dart:io';

import 'package:encrypted_cloud/components/FullscreenOptions.dart';
import 'package:encrypted_cloud/enums/FileState.dart';
import 'package:encrypted_cloud/utils/DecryptedFile.dart';
import 'package:encrypted_cloud/utils/FileHandler.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

class Fullscreen extends StatefulWidget {
  const Fullscreen({Key? key, required this.tappedFile}) : super(key: key);
  final DecryptedFile tappedFile;

  @override
  State<Fullscreen> createState() => _FullscreenState();
}

class _FullscreenState extends State<Fullscreen> {
  final List<String> validExtensions = const [".png", ".jpg"];
  bool optionsVisible = true;
  late DecryptedFile currentFile;
  late File file;

  @override
  void initState() {
    currentFile = widget.tappedFile;
    file = currentFile.thumbnail!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FileHandler fileHandler = Provider.of<FileHandler>(context);
    List<DecryptedFile> validFiles = fileHandler.files.where((file) {
      return file.thumbnail != null && validExtensions.any(file.thumbnail!.path.endsWith);
    }).toList();
    PageController controller = PageController(initialPage: validFiles.indexOf(currentFile));
    fileHandler.downloadFullFile(currentFile);

    // TODO hide status bar once flutter/flutter#95403 is resolved

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              setState(() => optionsVisible = !optionsVisible);
            },
            child: Container(
              color: Colors.black,
              child: PhotoViewGallery.builder(
                onPageChanged: (index) {
                  fileHandler.downloadFullFile(validFiles[index]);
                  setState(() => currentFile = validFiles[index]);
                },
                enableRotation: false,
                scrollPhysics: const BouncingScrollPhysics(),
                itemCount: validFiles.length,
                pageController: controller,
                builder: (BuildContext context, int index) {
                  DecryptedFile file = validFiles[index];
                  return PhotoViewGalleryPageOptions(
                    imageProvider: FileImage(file.state == FileState.available ? file.data! : file.thumbnail!),
                    initialScale: PhotoViewComputedScale.contained * 0.999,
                    minScale: PhotoViewComputedScale.contained * 0.999,
                    // TODO remove * 0.999 once bluefireteam/photo_view#383 is resolved
                  );
                },
              ),
            ),
          ),
          FullscreenOptions(
            optionsVisible: optionsVisible,
            onSave: () => fileHandler.saveFile(currentFile),
            onDelete: () {
              DecryptedFile oldFile = currentFile;
              int index = validFiles.indexOf(currentFile);
              index = index + 1 == validFiles.length ? index - 1 : index + 1;
              fileHandler.deleteFile(oldFile);
              if (validFiles.length != 1) {
                setState(() => currentFile = validFiles[index]);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}