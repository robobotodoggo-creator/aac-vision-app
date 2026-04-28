import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class VisionService {
  CameraController? _cameraController;
  ObjectDetector? _objectDetector;
  bool _isProcessing = false;
  Timer? _processTimer;
  final _detectedObjectsController =
      StreamController<List<String>>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  Stream<List<String>> get detectedObjects => _detectedObjectsController.stream;
  Stream<String> get errors => _errorController.stream;
  CameraController? get cameraController => _cameraController;
  bool get isInitialized => _cameraController?.value.isInitialized ?? false;

  Future<bool> init() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _errorController.add('No cameras found on this device');
        return false;
      }

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
    } on CameraException catch (e) {
      _errorController.add('Camera error: ${e.description ?? e.code}');
      _cameraController = null;
      return false;
    } catch (e) {
      _errorController.add('Camera unavailable');
      debugPrint('VisionService camera init error: $e');
      _cameraController = null;
      return false;
    }

    try {
      final options = ObjectDetectorOptions(
        mode: DetectionMode.stream,
        classifyObjects: true,
        multipleObjects: true,
      );
      _objectDetector = ObjectDetector(options: options);
    } catch (e) {
      _errorController.add('Object detection unavailable');
      debugPrint('VisionService ML Kit init error: $e');
      _objectDetector = null;
      return false;
    }

    return true;
  }

  void startDetection() {
    if (_cameraController == null || _objectDetector == null) return;
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
        !_cameraController!.value.isInitialized ||
        _objectDetector == null) {
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
    } on CameraException catch (e) {
      debugPrint('VisionService frame capture error: ${e.description}');
    } catch (e) {
      debugPrint('VisionService frame processing error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  void dispose() {
    stopDetection();
    _cameraController?.dispose();
    _objectDetector?.close();
    _detectedObjectsController.close();
    _errorController.close();
  }
}
