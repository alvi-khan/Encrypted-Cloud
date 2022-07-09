import 'package:encrypted_cloud/utils/DecryptedFile.dart';
import 'package:encrypted_cloud/utils/FileHandler.dart';
import 'package:encrypted_cloud/views/Fullscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImageFileCard extends StatelessWidget {
  const ImageFileCard({Key? key, required this.file}) : super(key: key);
  final DecryptedFile file;

  @override
  Widget build(BuildContext context) {
    return Consumer<FileHandler>(
      builder: (context, fileHandler, child) {
        int index = fileHandler.files.indexOf(file);
        if (fileHandler.selections == 0) {
          return GestureDetector(
              onLongPress: () => fileHandler.setSelected(index, true),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) {
                        return Fullscreen(tappedFile: file);
                      },
                  ),
                );
              },
              child: Image.file(file.thumbnail!, fit: BoxFit.cover)
          );
        }
        return GestureDetector(
          onTap: () => fileHandler.setSelected(index, !file.selected),
          child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  padding: file.selected ? const EdgeInsets.all(10) : EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(file.thumbnail!, fit: BoxFit.cover),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5.0),
                  alignment: Alignment.topLeft,
                  child: Icon(
                    file.selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                    color: Colors.blueGrey.shade100,
                  ),
                ),
              ]
          ),
        );
      },
    );
  }
}