import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key, required this.size, required this.strokeWidth, required this.color, this.progress}) : super(key: key);
  final double size;
  final double strokeWidth;
  final Color color;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            value: progress,
            color: color,
            strokeWidth: strokeWidth,
          ),
        )
    );
  }
}