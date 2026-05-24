import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class VisionService {
  // Stability filter: a label must appear in at least [_stabilityThreshold]
  // of the last [_stabilityWindow] frames before it's surfaced. Kills flicker.
  static const int _stabilityWindow = 5;
  static const int _stabilityThreshold = 3;

  CameraController? _cameraController;
  ObjectDetector? _objectDetector;
  ImageLabeler? _imageLabeler;
  bool _isProcessing = false;
  Timer? _processTimer;
  final List<Set<String>> _recentFrameLabels = [];
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
      // Object detector with bounding boxes (5 broad categories)
      final objOptions = ObjectDetectorOptions(
        mode: DetectionMode.stream,
        classifyObjects: true,
        multipleObjects: true,
      );
      _objectDetector = ObjectDetector(options: objOptions);

      // Image labeler with default 447-class model — this is what actually
      // gives us specific labels like "Cat", "Coffee", "Mobile phone", etc.
      final labelerOptions = ImageLabelerOptions(confidenceThreshold: 0.5);
      _imageLabeler = ImageLabeler(options: labelerOptions);
    } catch (e) {
      _errorController.add('Vision ML unavailable');
      debugPrint('VisionService ML Kit init error: $e');
      _objectDetector = null;
      _imageLabeler = null;
      return false;
    }

    return true;
  }

  void startDetection() {
    if (_cameraController == null) return;
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
    String? imagePath;
    try {
      final image = await _cameraController!.takePicture();
      imagePath = image.path;
      final inputImage = InputImage.fromFilePath(imagePath);

      final labels = <String>{};

      // Image labeling — 447-class general scene/object labels
      if (_imageLabeler != null) {
        final imageLabels = await _imageLabeler!.processImage(inputImage);
        for (final label in imageLabels) {
          labels.add(label.label.toLowerCase());
        }
      }

      // Object detection — adds bounding-box backed broad categories
      if (_objectDetector != null) {
        final objects = await _objectDetector!.processImage(inputImage);
        for (final obj in objects) {
          for (final label in obj.labels) {
            if (label.confidence > 0.6) {
              labels.add(label.text.toLowerCase());
            }
          }
        }
      }

      // Stability filter: track last N frames, only emit labels seen in K+ of them.
      _recentFrameLabels.add(labels);
      if (_recentFrameLabels.length > _stabilityWindow) {
        _recentFrameLabels.removeAt(0);
      }
      final counts = <String, int>{};
      for (final frame in _recentFrameLabels) {
        for (final label in frame) {
          counts[label] = (counts[label] ?? 0) + 1;
        }
      }
      final stable = counts.entries
          .where((e) => e.value >= _stabilityThreshold)
          .map((e) => e.key)
          .toList();
      if (stable.isNotEmpty) {
        debugPrint('VisionService stable labels: $stable');
        _detectedObjectsController.add(stable);
      }
    } on CameraException catch (e) {
      debugPrint('VisionService frame capture error: ${e.description}');
    } catch (e) {
      debugPrint('VisionService frame processing error: $e');
    } finally {
      if (imagePath != null) {
        try {
          await File(imagePath).delete();
        } catch (_) {}
      }
      _isProcessing = false;
    }
  }

  void dispose() {
    stopDetection();
    _cameraController?.dispose();
    _objectDetector?.close();
    _imageLabeler?.close();
    _detectedObjectsController.close();
    _errorController.close();
  }
}
