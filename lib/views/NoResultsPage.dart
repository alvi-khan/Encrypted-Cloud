import 'package:encrypted_cloud/components/UploadButton.dart';
import 'package:encrypted_cloud/components/appbar/ProfileMenuButton.dart';
import 'package:flutter/material.dart';

class NoResultsPage extends StatelessWidget {
  const NoResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade800,
        actions: const [ProfileMenuButton()],
      ),
      backgroundColor: Colors.blueGrey.shade800,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
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
          ),
          const UploadButton(),
        ],
      ),
    );
  }
}