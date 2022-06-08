import 'dart:io';

import 'package:encrypted_cloud/utilities/GoogleDrive.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

class Fullscreen extends StatefulWidget {
  const Fullscreen({Key? key, required this.tappedFile}) : super(key: key);
  final File tappedFile;

  @override
  State<Fullscreen> createState() => _FullscreenState();
}

class _FullscreenState extends State<Fullscreen> {
  final List<String> validExtensions = const [".png", ".jpg"];

  @override
  Widget build(BuildContext context) {
    List<File> files = Provider.of<GoogleDrive>(context, listen: false).files;
    files = files.where((file) => validExtensions.any(file.path.endsWith)).toList();
    PageController controller = PageController(initialPage: files.indexOf(widget.tappedFile));

    return PhotoViewGallery.builder(
      enableRotation: false,
      scrollPhysics: const BouncingScrollPhysics(),
      itemCount: files.length,
      pageController: controller,
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(files[index]),
            minScale: PhotoViewComputedScale.contained,
        );
      },
    );
  }
}