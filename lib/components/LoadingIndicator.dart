import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, required this.size, required this.strokeWidth, required this.color, this.progress});
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