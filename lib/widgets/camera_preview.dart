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
        final isLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;
        return Positioned(
          right: 12,
          bottom: 12,
          child: Semantics(
            label: 'Camera preview, detecting objects for suggestions',
            image: true,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                // Slightly smaller PiP in landscape to save vertical space
                width: isLandscape ? 100 : 120,
                height: isLandscape ? 130 : 160,
                child: CameraPreview(state.vision.cameraController!),
              ),
            ),
          ),
        );
      },
    );
  }
}
