import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:encrypted_cloud/components/LoadingIndicator.dart';
import 'package:flutter/material.dart';

class Refresh extends StatelessWidget {
  const Refresh({super.key, required this.child, required this.onRefresh});

  final Widget child;
  final Function onRefresh;
  final int headerHeight = 150;
  final Duration resetTime = const Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: () => onRefresh(),
      builder: (context, child, controller) {
        return Stack(
          children: [
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return Container(
                  alignment: Alignment.center,
                  height: controller.value * headerHeight,
                  child: LoadingIndicator(
                    color: Colors.blueGrey,
                    size: 50,
                    strokeWidth: 5,
                    progress: controller.isLoading ? null : controller.value.clamp(0, 1),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              builder: (context, _) {
                return Transform.translate(
                  offset: Offset(0.0, controller.value * headerHeight),
                  child: AbsorbPointer(
                      absorbing: controller.isLoading,
                      child: child
                  ),
                );
              },
              animation: controller,
            ),
          ],
        );
      },
      child: child,
    );
  }
}