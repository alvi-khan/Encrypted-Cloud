import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}