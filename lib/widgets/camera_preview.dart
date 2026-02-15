import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class CameraPreviewWidget extends StatelessWidget {
  const CameraPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (!state.cameraEnabled || !state.vision.isInitialized) {
          return const SizedBox.shrink();
        }
        return Positioned(
          right: 12,
          bottom: 12,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 120,
              height: 160,
              child: CameraPreview(state.vision.cameraController!),
            ),
          ),
        );
      },
    );
  }
}
