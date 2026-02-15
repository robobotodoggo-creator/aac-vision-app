import 'dart:async';
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class VisionService {
  CameraController? _cameraController;
  ObjectDetector? _objectDetector;
  bool _isProcessing = false;
  Timer? _processTimer;
  final _detectedObjectsController =
      StreamController<List<String>>.broadcast();

  Stream<List<String>> get detectedObjects => _detectedObjectsController.stream;
  CameraController? get cameraController => _cameraController;
  bool get isInitialized => _cameraController?.value.isInitialized ?? false;

  Future<void> init() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    // Use back camera
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    final options = ObjectDetectorOptions(
      mode: DetectionMode.stream,
      classifyObjects: true,
      multipleObjects: true,
    );
    _objectDetector = ObjectDetector(options: options);
  }

  void startDetection() {
    // Process frames at ~5fps
    _processTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      _processFrame();
    });
  }

  void stopDetection() {
    _processTimer?.cancel();
    _processTimer = null;
  }

  Future<void> _processFrame() async {
    if (_isProcessing ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return;
    }

    _isProcessing = true;
    try {
      final image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final objects = await _objectDetector!.processImage(inputImage);

      final labels = <String>[];
      for (final obj in objects) {
        for (final label in obj.labels) {
          if (label.confidence > 0.6) {
            labels.add(label.text);
          }
        }
      }

      if (labels.isNotEmpty) {
        _detectedObjectsController.add(labels.toSet().toList());
      }
    } catch (_) {
      // Skip frame on error
    } finally {
      _isProcessing = false;
    }
  }

  void dispose() {
    stopDetection();
    _cameraController?.dispose();
    _objectDetector?.close();
    _detectedObjectsController.close();
  }
}
