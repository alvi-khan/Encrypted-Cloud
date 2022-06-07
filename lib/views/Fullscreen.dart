import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:encrypted_cloud/utilities/GoogleDrive.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: CarouselSlider(
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height,
            initialPage: files.indexOf(widget.tappedFile),
            enableInfiniteScroll: false,
            viewportFraction: 1,
          ),
          items: files.map((file) {
            return Image.file(file);
          }).toList(),
        ),
      ),
    );
  }
}