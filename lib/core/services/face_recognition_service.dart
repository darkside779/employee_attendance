import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:camera/camera.dart';

class FaceRecognitionService {
  static final FaceRecognitionService _instance =
      FaceRecognitionService._internal();
  factory FaceRecognitionService() => _instance;
  FaceRecognitionService._internal();

  late FaceDetector _faceDetector;

  // Initialize the face detector
  void initialize() {
    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        enableContours: true,
        enableTracking: true,
        minFaceSize: 0.1,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
  }

  // Dispose of resources
  void dispose() {
    _faceDetector.close();
  }

  // Detect faces in an image
  Future<List<Face>> detectFaces(InputImage inputImage) async {
    try {
      final faces = await _faceDetector.processImage(inputImage);
      return faces;
    } catch (e) {
      throw Exception('Failed to detect faces: $e');
    }
  }

  // Detect faces from camera image
  Future<List<Face>> detectFacesFromCamera(CameraImage cameraImage) async {
    try {
      final inputImage = _inputImageFromCameraImage(cameraImage);
      return await detectFaces(inputImage);
    } catch (e) {
      throw Exception('Failed to detect faces from camera: $e');
    }
  }

  // Detect faces from file path
  Future<List<Face>> detectFacesFromFile(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      return await detectFaces(inputImage);
    } catch (e) {
      throw Exception('Failed to detect faces from file: $e');
    }
  }

  // Extract face embedding from detected face
  Future<List<double>> extractFaceEmbedding(
    InputImage inputImage,
    Face face,
  ) async {
    try {
      // This is a simplified version. In a real implementation,
      // you would use a face recognition model like FaceNet
      // to generate proper embeddings.

      final boundingBox = face.boundingBox;

      // For now, we'll create a simple feature vector based on
      // face landmarks and measurements
      final landmarks = face.landmarks;
      final headEulerAngleY = face.headEulerAngleY ?? 0;
      final headEulerAngleZ = face.headEulerAngleZ ?? 0;
      final leftEyeOpenProbability = face.leftEyeOpenProbability ?? 0;
      final rightEyeOpenProbability = face.rightEyeOpenProbability ?? 0;

      // Create a feature vector (in reality, this would be much more sophisticated)
      List<double> embedding = [
        boundingBox.width / 1000.0,
        boundingBox.height / 1000.0,
        boundingBox.left / 1000.0,
        boundingBox.top / 1000.0,
        headEulerAngleY / 180.0,
        headEulerAngleZ / 180.0,
        leftEyeOpenProbability,
        rightEyeOpenProbability,
      ];

      // Add landmark-based features
      if (landmarks[FaceLandmarkType.leftEye] != null) {
        final leftEye = landmarks[FaceLandmarkType.leftEye]!.position;
        embedding.addAll([leftEye.x / 1000.0, leftEye.y / 1000.0]);
      } else {
        embedding.addAll([0.0, 0.0]);
      }

      if (landmarks[FaceLandmarkType.rightEye] != null) {
        final rightEye = landmarks[FaceLandmarkType.rightEye]!.position;
        embedding.addAll([rightEye.x / 1000.0, rightEye.y / 1000.0]);
      } else {
        embedding.addAll([0.0, 0.0]);
      }

      if (landmarks[FaceLandmarkType.noseBase] != null) {
        final nose = landmarks[FaceLandmarkType.noseBase]!.position;
        embedding.addAll([nose.x / 1000.0, nose.y / 1000.0]);
      } else {
        embedding.addAll([0.0, 0.0]);
      }

      if (landmarks[FaceLandmarkType.bottomMouth] != null) {
        final mouth = landmarks[FaceLandmarkType.bottomMouth]!.position;
        embedding.addAll([mouth.x / 1000.0, mouth.y / 1000.0]);
      } else {
        embedding.addAll([0.0, 0.0]);
      }

      // Pad to make it 128 dimensions (common for face embeddings)
      while (embedding.length < 128) {
        embedding.add(0.0);
      }

      // Truncate if too long
      if (embedding.length > 128) {
        embedding = embedding.take(128).toList();
      }

      return embedding;
    } catch (e) {
      throw Exception('Failed to extract face embedding: $e');
    }
  }

  // Compare two face embeddings
  double compareFaceEmbeddings(
    List<double> embedding1,
    List<double> embedding2,
  ) {
    if (embedding1.length != embedding2.length) {
      throw Exception('Embeddings must have the same length');
    }

    // Calculate Euclidean distance
    double distance = 0.0;
    for (int i = 0; i < embedding1.length; i++) {
      distance += math.pow(embedding1[i] - embedding2[i], 2);
    }
    distance = math.sqrt(distance);

    // Convert to similarity score (0-1, where 1 is identical)
    return 1.0 / (1.0 + distance);
  }

  // Calculate cosine similarity between embeddings
  double cosineSimilarity(List<double> embedding1, List<double> embedding2) {
    if (embedding1.length != embedding2.length) {
      throw Exception('Embeddings must have the same length');
    }

    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;

    for (int i = 0; i < embedding1.length; i++) {
      dotProduct += embedding1[i] * embedding2[i];
      norm1 += embedding1[i] * embedding1[i];
      norm2 += embedding2[i] * embedding2[i];
    }

    norm1 = math.sqrt(norm1);
    norm2 = math.sqrt(norm2);

    if (norm1 == 0.0 || norm2 == 0.0) {
      return 0.0;
    }

    return dotProduct / (norm1 * norm2);
  }

  // Check if faces match based on threshold
  bool doFacesMatch(
    List<double> embedding1,
    List<double> embedding2, {
    double threshold = 0.7,
  }) {
    final similarity = cosineSimilarity(embedding1, embedding2);
    return similarity >= threshold;
  }

  // Validate face quality
  FaceQuality validateFaceQuality(Face face) {
    final boundingBox = face.boundingBox;
    final headEulerAngleY = face.headEulerAngleY?.abs() ?? 0;
    final headEulerAngleZ = face.headEulerAngleZ?.abs() ?? 0;
    final leftEyeOpenProbability = face.leftEyeOpenProbability ?? 0;
    final rightEyeOpenProbability = face.rightEyeOpenProbability ?? 0;

    // Check face size (more lenient)
    if (boundingBox.width < 50 || boundingBox.height < 50) {
      return FaceQuality.tooSmall;
    }

    // Check head pose (more lenient)
    if (headEulerAngleY > 45 || headEulerAngleZ > 45) {
      return FaceQuality.poorPose;
    }

    // Check eye openness (more lenient)
    if (leftEyeOpenProbability < 0.3 || rightEyeOpenProbability < 0.3) {
      return FaceQuality.eyesClosed;
    }

    return FaceQuality.good;
  }

  // Get face quality message
  String getFaceQualityMessage(FaceQuality quality) {
    switch (quality) {
      case FaceQuality.good:
        return 'Face detected successfully';
      case FaceQuality.tooSmall:
        return 'Move closer to the camera';
      case FaceQuality.poorPose:
        return 'Look straight at the camera';
      case FaceQuality.eyesClosed:
        return 'Keep your eyes open';
      case FaceQuality.blurry:
        return 'Hold the camera steady';
    }
  }

  // Convert CameraImage to InputImage
  InputImage _inputImageFromCameraImage(CameraImage cameraImage) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(
      cameraImage.width.toDouble(),
      cameraImage.height.toDouble(),
    );

    final InputImageRotation imageRotation = InputImageRotation.rotation0deg;

    final InputImageFormat inputImageFormat = InputImageFormat.nv21;

    final planeData = cameraImage.planes.map((Plane plane) {
      return InputImagePlaneMetadata(
        bytesPerRow: plane.bytesPerRow,
        height: plane.height,
        width: plane.width,
      );
    }).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    return InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
  }

  // Process face registration
  Future<FaceRegistrationResult> processFaceRegistration(
    String imagePath,
  ) async {
    try {
      final faces = await detectFacesFromFile(imagePath);

      if (faces.isEmpty) {
        return FaceRegistrationResult(
          success: false,
          message: 'No face detected in the image',
        );
      }

      if (faces.length > 1) {
        return FaceRegistrationResult(
          success: false,
          message:
              'Multiple faces detected. Please ensure only one face is visible',
        );
      }

      final face = faces.first;
      final quality = validateFaceQuality(face);

      if (quality != FaceQuality.good) {
        return FaceRegistrationResult(
          success: false,
          message: getFaceQualityMessage(quality),
        );
      }

      final inputImage = InputImage.fromFilePath(imagePath);
      final embedding = await extractFaceEmbedding(inputImage, face);

      return FaceRegistrationResult(
        success: true,
        message: 'Face registered successfully',
        embedding: embedding,
      );
    } catch (e) {
      return FaceRegistrationResult(
        success: false,
        message: 'Failed to process face registration: $e',
      );
    }
  }
}

// Enums and Data Classes
enum FaceQuality { good, tooSmall, poorPose, eyesClosed, blurry }

class FaceRegistrationResult {
  final bool success;
  final String message;
  final List<double>? embedding;

  FaceRegistrationResult({
    required this.success,
    required this.message,
    this.embedding,
  });
}

class FaceMatchResult {
  final bool isMatch;
  final double confidence;
  final String? employeeId;
  final String? employeeName;

  FaceMatchResult({
    required this.isMatch,
    required this.confidence,
    this.employeeId,
    this.employeeName,
  });
}
