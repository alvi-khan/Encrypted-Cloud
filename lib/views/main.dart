import 'package:encrypted_cloud/views/FileViewer.dart';
import 'package:encrypted_cloud/utils/GoogleAccount.dart';
import 'package:encrypted_cloud/utils/FileHandler.dart';
import 'package:encrypted_cloud/views/SignInPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GoogleAccount()),
        ChangeNotifierProvider(create: (context) => FileHandler()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Consumer<GoogleAccount>(
      builder: (context, account, child) {
        return account.user == null ? const SignInPage() : const FileViewer();
      }
    );
  }
}
