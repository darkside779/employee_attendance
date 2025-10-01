import 'dart:math';
import 'package:google_ml_kit/google_ml_kit.dart';

/// Advanced facial landmark-based similarity calculation service
/// Provides more accurate face verification using facial geometry and landmarks
class LandmarkSimilarityService {
  
  /// Extract facial landmarks and geometry from a detected face
  static Map<String, dynamic> extractFacialFeatures(Face face) {
    final landmarks = <String, List<double>>{};
    final geometry = <String, double>{};
    
    // Extract key facial landmarks
    final faceLandmarks = face.landmarks;
    for (final landmarkType in faceLandmarks.keys) {
      final landmark = faceLandmarks[landmarkType];
      if (landmark != null) {
        landmarks[landmarkType.toString()] = [
          landmark.position.x.toDouble(),
          landmark.position.y.toDouble(),
        ];
      }
    }
    
    // Calculate facial geometry measurements
    final boundingBox = face.boundingBox;
    geometry['face_width'] = boundingBox.width.toDouble();
    geometry['face_height'] = boundingBox.height.toDouble();
    geometry['face_area'] = boundingBox.width * boundingBox.height;
    geometry['aspect_ratio'] = boundingBox.width / boundingBox.height;
    
    // Head pose angles
    geometry['head_euler_y'] = face.headEulerAngleY?.toDouble() ?? 0.0;
    geometry['head_euler_z'] = face.headEulerAngleZ?.toDouble() ?? 0.0;
    geometry['head_euler_x'] = face.headEulerAngleX?.toDouble() ?? 0.0;
    
    // Eye and smile probabilities
    geometry['left_eye_open'] = face.leftEyeOpenProbability?.toDouble() ?? 0.0;
    geometry['right_eye_open'] = face.rightEyeOpenProbability?.toDouble() ?? 0.0;
    geometry['smile_probability'] = face.smilingProbability?.toDouble() ?? 0.0;
    
    // Calculate additional geometric features
    _calculateGeometricFeatures(landmarks, geometry);
    
    return {
      'landmarks': landmarks,
      'geometry': geometry,
    };
  }
  
  /// Calculate advanced geometric features from landmarks
  static void _calculateGeometricFeatures(
    Map<String, List<double>> landmarks, 
    Map<String, double> geometry
  ) {
    // Eye distance calculation
    if (landmarks.containsKey('FaceLandmarkType.leftEye') && 
        landmarks.containsKey('FaceLandmarkType.rightEye')) {
      final leftEye = landmarks['FaceLandmarkType.leftEye']!;
      final rightEye = landmarks['FaceLandmarkType.rightEye']!;
      geometry['eye_distance'] = _calculateDistance(leftEye, rightEye);
    }
    
    // Nose to mouth distance
    if (landmarks.containsKey('FaceLandmarkType.noseBase') && 
        landmarks.containsKey('FaceLandmarkType.bottomMouth')) {
      final nose = landmarks['FaceLandmarkType.noseBase']!;
      final mouth = landmarks['FaceLandmarkType.bottomMouth']!;
      geometry['nose_mouth_distance'] = _calculateDistance(nose, mouth);
    }
    
    // Face symmetry (left vs right eye height)
    if (landmarks.containsKey('FaceLandmarkType.leftEye') && 
        landmarks.containsKey('FaceLandmarkType.rightEye')) {
      final leftEye = landmarks['FaceLandmarkType.leftEye']!;
      final rightEye = landmarks['FaceLandmarkType.rightEye']!;
      geometry['eye_height_difference'] = (leftEye[1] - rightEye[1]).abs();
    }
    
    // Mouth width (left to right mouth corner)
    if (landmarks.containsKey('FaceLandmarkType.leftMouth') && 
        landmarks.containsKey('FaceLandmarkType.rightMouth')) {
      final leftMouth = landmarks['FaceLandmarkType.leftMouth']!;
      final rightMouth = landmarks['FaceLandmarkType.rightMouth']!;
      geometry['mouth_width'] = _calculateDistance(leftMouth, rightMouth);
    }
  }
  
  /// Calculate Euclidean distance between two points
  static double _calculateDistance(List<double> point1, List<double> point2) {
    final dx = point1[0] - point2[0];
    final dy = point1[1] - point2[1];
    return sqrt(dx * dx + dy * dy);
  }
  
  /// Calculate comprehensive similarity between two faces using landmarks and geometry
  static double calculateLandmarkSimilarity(
    Map<String, List<double>> landmarks1,
    Map<String, double> geometry1,
    Map<String, List<double>> landmarks2,
    Map<String, double> geometry2,
  ) {
    if (landmarks1.isEmpty || landmarks2.isEmpty) return 0.0;
    
    // Weights for different similarity components
    const double landmarkWeight = 0.4;
    const double geometryWeight = 0.3;
    const double ratioWeight = 0.3;
    
    // Calculate landmark similarity
    final landmarkSimilarity = _calculateLandmarkPointSimilarity(landmarks1, landmarks2);
    
    // Calculate geometric feature similarity
    final geometrySimilarity = _calculateGeometrySimilarity(geometry1, geometry2);
    
    // Calculate facial ratio similarity
    final ratioSimilarity = _calculateRatioSimilarity(geometry1, geometry2);
    
    // Weighted final similarity
    final finalSimilarity = (landmarkSimilarity * landmarkWeight) +
                           (geometrySimilarity * geometryWeight) +
                           (ratioSimilarity * ratioWeight);
    
    return finalSimilarity.clamp(0.0, 1.0);
  }
  
  /// Calculate similarity between landmark points
  static double _calculateLandmarkPointSimilarity(
    Map<String, List<double>> landmarks1,
    Map<String, List<double>> landmarks2,
  ) {
    double totalSimilarity = 0.0;
    int matchCount = 0;
    
    // Key landmarks with higher importance
    const landmarkWeights = {
      'FaceLandmarkType.leftEye': 1.5,
      'FaceLandmarkType.rightEye': 1.5,
      'FaceLandmarkType.noseBase': 1.2,
      'FaceLandmarkType.bottomMouth': 1.0,
      'FaceLandmarkType.leftMouth': 0.8,
      'FaceLandmarkType.rightMouth': 0.8,
      'FaceLandmarkType.leftCheek': 0.6,
      'FaceLandmarkType.rightCheek': 0.6,
    };
    
    for (final landmarkType in landmarks1.keys) {
      if (landmarks2.containsKey(landmarkType)) {
        final point1 = landmarks1[landmarkType]!;
        final point2 = landmarks2[landmarkType]!;
        
        // Normalize coordinates and calculate similarity
        final normalizedSimilarity = _calculateNormalizedPointSimilarity(point1, point2);
        final weight = landmarkWeights[landmarkType] ?? 0.5;
        
        totalSimilarity += normalizedSimilarity * weight;
        matchCount++;
      }
    }
    
    return matchCount > 0 ? totalSimilarity / matchCount : 0.0;
  }
  
  /// Calculate normalized similarity between two landmark points
  static double _calculateNormalizedPointSimilarity(List<double> point1, List<double> point2) {
    final distance = _calculateDistance(point1, point2);
    // Normalize distance to similarity (closer = more similar)
    // Assuming max face size of ~400 pixels
    final normalizedDistance = distance / 400.0;
    return max(0.0, 1.0 - normalizedDistance);
  }
  
  /// Calculate similarity between geometric features
  static double _calculateGeometrySimilarity(
    Map<String, double> geometry1,
    Map<String, double> geometry2,
  ) {
    double totalSimilarity = 0.0;
    int matchCount = 0;
    
    // Important geometric features with weights
    const geometryWeights = {
      'eye_distance': 1.5,
      'nose_mouth_distance': 1.2,
      'aspect_ratio': 1.0,
      'mouth_width': 0.8,
      'eye_height_difference': 0.6,
    };
    
    for (final feature in geometryWeights.keys) {
      if (geometry1.containsKey(feature) && geometry2.containsKey(feature)) {
        final value1 = geometry1[feature]!;
        final value2 = geometry2[feature]!;
        
        // Calculate relative similarity
        final maxValue = max(value1, value2);
        final minValue = min(value1, value2);
        final similarity = maxValue > 0 ? minValue / maxValue : 1.0;
        
        totalSimilarity += similarity * geometryWeights[feature]!;
        matchCount++;
      }
    }
    
    return matchCount > 0 ? totalSimilarity / matchCount : 0.0;
  }
  
  /// Calculate similarity between facial ratios
  static double _calculateRatioSimilarity(
    Map<String, double> geometry1,
    Map<String, double> geometry2,
  ) {
    double totalSimilarity = 0.0;
    int ratioCount = 0;
    
    // Calculate eye-to-face width ratio
    if (geometry1.containsKey('eye_distance') && geometry1.containsKey('face_width') &&
        geometry2.containsKey('eye_distance') && geometry2.containsKey('face_width')) {
      final ratio1 = geometry1['eye_distance']! / geometry1['face_width']!;
      final ratio2 = geometry2['eye_distance']! / geometry2['face_width']!;
      totalSimilarity += _calculateTwoRatioSimilarity(ratio1, ratio2);
      ratioCount++;
    }
    
    // Calculate mouth-to-face width ratio
    if (geometry1.containsKey('mouth_width') && geometry1.containsKey('face_width') &&
        geometry2.containsKey('mouth_width') && geometry2.containsKey('face_width')) {
      final ratio1 = geometry1['mouth_width']! / geometry1['face_width']!;
      final ratio2 = geometry2['mouth_width']! / geometry2['face_width']!;
      totalSimilarity += _calculateTwoRatioSimilarity(ratio1, ratio2);
      ratioCount++;
    }
    
    return ratioCount > 0 ? totalSimilarity / ratioCount : 0.0;
  }
  
  /// Calculate similarity between two ratio values
  static double _calculateTwoRatioSimilarity(double ratio1, double ratio2) {
    final maxRatio = max(ratio1, ratio2);
    final minRatio = min(ratio1, ratio2);
    return maxRatio > 0 ? minRatio / maxRatio : 1.0;
  }
  
  /// Combine embedding similarity with landmark similarity for final score
  static double calculateCombinedSimilarity(
    List<double> embedding1,
    List<double> embedding2,
    Map<String, List<double>> landmarks1,
    Map<String, double> geometry1,
    Map<String, List<double>> landmarks2,
    Map<String, double> geometry2,
  ) {
    // Calculate embedding similarity (cosine similarity)
    final embeddingSimilarity = _calculateCosineSimilarity(embedding1, embedding2);
    
    // Calculate landmark similarity
    final landmarkSimilarity = calculateLandmarkSimilarity(
      landmarks1, geometry1, landmarks2, geometry2
    );
    
    // Weighted combination (embeddings are still primary)
    const double embeddingWeight = 0.7;
    const double landmarkWeight = 0.3;
    
    final combinedSimilarity = (embeddingSimilarity * embeddingWeight) +
                              (landmarkSimilarity * landmarkWeight);
    
    return combinedSimilarity.clamp(0.0, 1.0);
  }
  
  /// Calculate cosine similarity between two embeddings
  static double _calculateCosineSimilarity(List<double> embedding1, List<double> embedding2) {
    if (embedding1.length != embedding2.length) return 0.0;
    
    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;
    
    for (int i = 0; i < embedding1.length; i++) {
      dotProduct += embedding1[i] * embedding2[i];
      norm1 += embedding1[i] * embedding1[i];
      norm2 += embedding2[i] * embedding2[i];
    }
    
    if (norm1 == 0.0 || norm2 == 0.0) return 0.0;
    
    return dotProduct / (sqrt(norm1) * sqrt(norm2));
  }
}
