import 'package:encrypted_cloud/components/dialog/DeleteFileConfirmationDialog.dart';
import 'package:encrypted_cloud/utils/GoogleDrive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FullscreenOptions extends StatelessWidget {
  const FullscreenOptions({Key? key, required this.optionsVisible, required this.onDelete, required this.onSave}) : super(key: key);
  final bool optionsVisible;
  final Function onDelete;
  final Function onSave;

  void delete(BuildContext context) async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (context) => const DeleteFileConfirmationDialog(fileCount: 1),
    );

    if (confirmed != null && confirmed) onDelete();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoogleDrive>(
      builder: (context, drive, child) {
        return AnimatedOpacity(
          opacity: optionsVisible ? 1.0 : 0.0,
          curve: Curves.fastOutSlowIn,
          duration: const Duration(milliseconds: 200),
          child: Stack(
            children: [
              IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xCC000000), Color(0x00000000), Color(0x00000000), Color(0xCC000000)],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_rounded, size: 35, color: Colors.white)
                          ),
                        )
                    ),
                    const Expanded(child: SizedBox()),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                              onPressed: () => onSave(),
                              icon: const Icon(Icons.download_rounded, size: 35, color: Colors.white)
                          ),
                          IconButton(
                              onPressed: () => delete(context),
                              icon: const Icon(Icons.delete_rounded, size: 35, color: Colors.white)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}