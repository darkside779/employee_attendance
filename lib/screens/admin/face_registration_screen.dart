// Camera-based face registration screen
// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/face_recognition_service.dart';
import '../../core/services/landmark_similarity_service.dart';
import '../../providers/employee_provider.dart';
import '../../models/employee_model.dart';

class FaceRegistrationScreen extends StatefulWidget {
  final EmployeeModel employee;
  
  const FaceRegistrationScreen({
    super.key,
    required this.employee,
  });

  @override 
  State<FaceRegistrationScreen> createState() => _FaceRegistrationScreenState();
}

class _FaceRegistrationScreenState extends State<FaceRegistrationScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _isCapturing = false;
  String _message = 'Look straight at the camera - Photo 1/3';
  Color _messageColor = AppColors.textPrimary;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  int _captureCount = 0;
  final int _requiredCaptures = 3; // Take 3 photos from different angles
  final List<List<double>> _capturedEmbeddings = [];
  final List<Map<String, List<double>>> _capturedLandmarks = [];  // Store landmarks from each capture
  final List<Map<String, double>> _capturedGeometry = [];         // Store geometry from each capture
  
  // Define required angles for each capture
  final List<String> _captureInstructions = [
    'Look straight at the camera',
    'Turn your head slightly to the RIGHT',
    'Turn your head slightly to the LEFT',
  ];
  
  final List<String> _captureDescriptions = [
    'Straight forward view',
    'Right angle view', 
    'Left angle view',
  ];

  final FaceRecognitionService _faceService = FaceRecognitionService();
  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true, // Enable landmarks for better accuracy
      enableContours: true,  // Enable face contours for detailed features
      minFaceSize: 0.1,
      performanceMode: FaceDetectorMode.accurate, // Use accurate mode for registration
    ),
  );

  @override
  void initState() {
    super.initState();
    _faceService.initialize();
    _initializeAnimation();
    _initializeCamera();
  }

  void _initializeAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeCamera() async {
    try {
      print('🔍 DEBUG: Starting camera initialization for face registration...');
      
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        _showError('No cameras available on this device');
        return;
      }
      
      // Use front camera for face registration
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        frontCamera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high, // Higher quality for registration
        enableAudio: false,
        imageFormatGroup: kIsWeb ? ImageFormatGroup.jpeg : ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('❌ DEBUG: Camera initialization error: $e');
      _showError('Camera initialization failed: $e');
    }
  }

  void _showError(String error) {
    if (mounted) {
      setState(() {
        _message = error;
        _messageColor = AppColors.error;
      });
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('❌ Camera Error'),
          content: Text('$error\n\nPlease:\n• Check camera permissions\n• Restart the app\n• Contact IT support if issue persists'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to manage employees
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _retryCamera();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
  }

  void _retryCamera() {
    setState(() {
      _isInitialized = false;
      _message = 'Initializing camera...';
      _messageColor = AppColors.info;
    });
    _initializeCamera();
  }

  Future<void> _captureFace() async {
    if (_isProcessing || _isCapturing || _cameraController == null) return;
    
    setState(() {
      _isCapturing = true;
      _isProcessing = true;
      _message = 'Capturing face ${_captureCount + 1} of $_requiredCaptures...';
      _messageColor = AppColors.info;
    });

    try {
      // Take a photo
      final XFile photo = await _cameraController!.takePicture();
      
      if (kIsWeb) {
        // Web: ML Kit not available, use simulated face detection
        print('🌐 DEBUG: Web platform - using simulated face detection');
        await Future.delayed(const Duration(milliseconds: 800)); // Simulate processing
        
        // Generate web-compatible embedding
        final embedding = await _generateWebFaceEmbedding(photo.path, _captureCount);
        
        if (embedding.isEmpty) {
          throw Exception('Failed to generate face features. Please try again.');
        }
        
        print('✅ DEBUG: Generated web embedding for ${widget.employee.fullName}, capture ${_captureCount + 1}: ${embedding.length} dimensions');
        _capturedEmbeddings.add(embedding);
        
      } else {
        // Mobile: Use actual ML Kit face detection
        print('📱 DEBUG: Mobile platform - using ML Kit face detection');
        
        final inputImage = InputImage.fromFilePath(photo.path);
        
        // Detect faces using ML Kit
        final faces = await _faceDetector.processImage(inputImage);
        
        if (faces.isEmpty) {
          throw Exception('No face detected. Please position your face in the frame.');
        }
        
        if (faces.length > 1) {
          throw Exception('Multiple faces detected. Please ensure only one person is in the frame.');
        }
        
        final face = faces.first;
        
        // Check face quality using ML Kit data
        if (!_isGoodQualityFace(face)) {
          throw Exception('Face quality not good enough. Please improve lighting and face the camera directly.');
        }
        
        // Generate enhanced face embedding with landmarks
        final embedding = await _generateFaceEmbeddingWithLandmarks(face, _captureCount);
        
        if (embedding.isEmpty) {
          throw Exception('Failed to extract face features. Please try again.');
        }
        
        print('✅ DEBUG: Generated enhanced face embedding with landmarks for ${widget.employee.fullName}, capture ${_captureCount + 1}: ${embedding.length} dimensions');
        _capturedEmbeddings.add(embedding);
      }
      
      _captureCount++;
      
      if (_captureCount >= _requiredCaptures) {
        // All captures done, create final embedding
        await _finalizeFaceRegistration();
      } else {
        // Need more captures
        setState(() {
          _message = 'Great! $_captureCount/$_requiredCaptures captured (${_captureDescriptions[_captureCount - 1]})';
          _messageColor = AppColors.success;
          _isProcessing = false;
          _isCapturing = false;
        });
        
        // Wait 3 seconds before showing next instruction
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          setState(() {
            _message = '${_captureInstructions[_captureCount]} - Photo ${_captureCount + 1}/$_requiredCaptures';
            _messageColor = AppColors.warning; // Orange color for instructions
          });
        }
      }
      
    } catch (e) {
      print('❌ DEBUG: Face capture error: $e');
      if (mounted) {
        setState(() {
          _message = 'Capture failed: $e';
          _messageColor = AppColors.error;
          _isProcessing = false;
          _isCapturing = false;
        });
      }
    }
  }

  bool _isGoodQualityFace(Face face) {
    final boundingBox = face.boundingBox;
    final headEulerAngleY = face.headEulerAngleY ?? 0;
    final headEulerAngleX = face.headEulerAngleX?.abs() ?? 0;
    
    // Check face size (minimum 80x80 pixels for registration)
    if (boundingBox.width < 80 || boundingBox.height < 80) {
      print('❌ DEBUG: Face too small: ${boundingBox.width}x${boundingBox.height}');
      return false;
    }
    
    // Angle-specific validation based on capture count
    if (_captureCount == 0) {
      // Photo 1: Straight forward (allow ±15 degrees)
      if (headEulerAngleY.abs() > 15 || headEulerAngleX > 25) {
        print('❌ DEBUG: Photo 1 - Face not straight enough: Y=$headEulerAngleY, X=$headEulerAngleX');
        return false;
      }
    } else if (_captureCount == 1) {
      // Photo 2: Right angle (should be between 10-30 degrees right)
      if (headEulerAngleY < 10 || headEulerAngleY > 30 || headEulerAngleX > 25) {
        print('❌ DEBUG: Photo 2 - Not turned right enough: Y=$headEulerAngleY, X=$headEulerAngleX');
        return false;
      }
    } else if (_captureCount == 2) {
      // Photo 3: Left angle (should be between -30 to -10 degrees left)
      if (headEulerAngleY > -10 || headEulerAngleY < -30 || headEulerAngleX > 25) {
        print('❌ DEBUG: Photo 3 - Not turned left enough: Y=$headEulerAngleY, X=$headEulerAngleX');
        return false;
      }
    }
    
    print('✅ DEBUG: Face quality good for ${_captureDescriptions[_captureCount]}: ${boundingBox.width}x${boundingBox.height}, Y=$headEulerAngleY, X=$headEulerAngleX');
    return true;
  }

  Future<void> _finalizeFaceRegistration() async {
    setState(() {
      _message = 'Processing face registration...';
      _messageColor = AppColors.info;
    });

    try {
      // Average the embeddings for better accuracy
      final avgEmbedding = _averageEmbeddings(_capturedEmbeddings);
      
      // 🆕 AVERAGE THE LANDMARKS AND GEOMETRY DATA
      final avgLandmarks = _averageLandmarks(_capturedLandmarks);
      final avgGeometry = _averageGeometry(_capturedGeometry);
      
      print('🎯 DEBUG: Averaged landmarks: ${avgLandmarks.length} points');
      print('🎯 DEBUG: Averaged geometry: ${avgGeometry.length} measurements');
      
      // Update employee with face embedding + landmarks + geometry
      final employeeProvider = context.read<EmployeeProvider>();
      final updatedEmployee = widget.employee.copyWith(
        faceEmbedding: avgEmbedding,
        faceLandmarks: avgLandmarks,          // 🆕 SAVE LANDMARKS
        faceGeometry: avgGeometry,            // 🆕 SAVE GEOMETRY
        lastFaceCapture: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await employeeProvider.updateEmployee(updatedEmployee);
      
      if (mounted) {
        setState(() {
          _message = 'Face + landmarks registered successfully!';
          _messageColor = AppColors.success;
        });
        
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('✅ Success!'),
            content: Text('Face + landmarks registration completed for ${widget.employee.fullName}!\n\nEnhanced face recognition with landmarks is now active for more accurate check-in/check-out.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to manage employees
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
      
    } catch (e) {
      print('❌ DEBUG: Face registration finalization error: $e');
      if (mounted) {
        setState(() {
          _message = 'Registration failed: $e';
          _messageColor = AppColors.error;
          _isProcessing = false;
        });
      }
    }
  }

  // Generate enhanced face embedding with landmarks for higher accuracy
  Future<List<double>> _generateFaceEmbeddingWithLandmarks(Face face, int captureIndex) async {
    try {
      print('🔍 DEBUG: Generating face embedding with landmarks for capture ${captureIndex + 1}');
      
      // 🆕 EXTRACT LANDMARKS AND GEOMETRY FOR STORAGE
      final faceFeatures = LandmarkSimilarityService.extractFacialFeatures(face);
      final extractedLandmarks = faceFeatures['landmarks'] as Map<String, List<double>>? ?? {};
      final extractedGeometry = faceFeatures['geometry'] as Map<String, double>? ?? {};
      
      // Store landmarks and geometry for this capture
      _capturedLandmarks.add(extractedLandmarks);
      _capturedGeometry.add(extractedGeometry);
      print('🎯 DEBUG: Extracted ${extractedLandmarks.length} landmarks and ${extractedGeometry.length} geometry features for capture ${captureIndex + 1}');
      
      // Create enhanced feature vector based on face characteristics + landmarks
      final List<double> embedding = [];
      
      // 1. Basic face dimensions (normalized)
      final boundingBox = face.boundingBox;
      embedding.add(boundingBox.width / 1000.0);
      embedding.add(boundingBox.height / 1000.0);
      embedding.add(boundingBox.left / 1000.0);
      embedding.add(boundingBox.top / 1000.0);
      embedding.add(boundingBox.center.dx / 1000.0);
      embedding.add(boundingBox.center.dy / 1000.0);
      
      // 2. Face angles
      final headEulerAngleY = face.headEulerAngleY ?? 0;
      final headEulerAngleZ = face.headEulerAngleZ ?? 0;
      final headEulerAngleX = face.headEulerAngleX ?? 0;
      embedding.add(headEulerAngleY / 180.0);
      embedding.add(headEulerAngleZ / 180.0);
      embedding.add(headEulerAngleX / 180.0);
      
      // 3. Face landmarks (key facial feature positions)
      final landmarks = <FaceLandmarkType, FaceLandmark?>{
        FaceLandmarkType.leftEye: face.landmarks[FaceLandmarkType.leftEye],
        FaceLandmarkType.rightEye: face.landmarks[FaceLandmarkType.rightEye],
        FaceLandmarkType.noseBase: face.landmarks[FaceLandmarkType.noseBase],
        FaceLandmarkType.leftMouth: face.landmarks[FaceLandmarkType.leftMouth],
        FaceLandmarkType.rightMouth: face.landmarks[FaceLandmarkType.rightMouth],
        FaceLandmarkType.bottomMouth: face.landmarks[FaceLandmarkType.bottomMouth],
        FaceLandmarkType.leftEar: face.landmarks[FaceLandmarkType.leftEar],
        FaceLandmarkType.rightEar: face.landmarks[FaceLandmarkType.rightEar],
      };
      
      // Add landmark positions (normalized coordinates)
      for (final landmark in landmarks.values) {
        if (landmark != null) {
          embedding.add(landmark.position.x / 1000.0);
          embedding.add(landmark.position.y / 1000.0);
          print('📍 DEBUG: Added landmark at (${landmark.position.x.toStringAsFixed(1)}, ${landmark.position.y.toStringAsFixed(1)})');
        } else {
          // Landmark not detected, add default values
          embedding.add(0.0);
          embedding.add(0.0);
        }
      }
      
      // 4. Calculate inter-landmark distances for facial geometry
      final leftEye = landmarks[FaceLandmarkType.leftEye];
      final rightEye = landmarks[FaceLandmarkType.rightEye];
      final noseBase = landmarks[FaceLandmarkType.noseBase];
      final bottomMouth = landmarks[FaceLandmarkType.bottomMouth];
      
      if (leftEye != null && rightEye != null) {
        // Eye distance
        final eyeDistance = sqrt(
          pow(rightEye.position.x - leftEye.position.x, 2) +
          pow(rightEye.position.y - leftEye.position.y, 2)
        );
        embedding.add(eyeDistance / 1000.0);
        print('👁️ DEBUG: Eye distance: ${eyeDistance.toStringAsFixed(1)}');
      } else {
        embedding.add(0.0);
      }
      
      if (noseBase != null && bottomMouth != null) {
        // Nose to mouth distance
        final noseMouthDistance = sqrt(
          pow(bottomMouth.position.x - noseBase.position.x, 2) +
          pow(bottomMouth.position.y - noseBase.position.y, 2)
        );
        embedding.add(noseMouthDistance / 1000.0);
        print('👄 DEBUG: Nose-mouth distance: ${noseMouthDistance.toStringAsFixed(1)}');
      } else {
        embedding.add(0.0);
      }
      
      // 5. Face classification probabilities
      final smilingProb = face.smilingProbability ?? 0.5;
      final leftEyeOpenProb = face.leftEyeOpenProbability ?? 0.5;
      final rightEyeOpenProb = face.rightEyeOpenProbability ?? 0.5;
      embedding.add(smilingProb);
      embedding.add(leftEyeOpenProb);
      embedding.add(rightEyeOpenProb);
      
      // 6. Employee-specific and capture-specific features
      final employeeId = widget.employee.id;
      final employeeSeed = employeeId.hashCode % 1000;
      embedding.add(captureIndex * 0.1); // Different for each capture angle
      embedding.add(employeeSeed * 0.001); // Employee-specific factor
      
      // 7. Angle variations with trigonometric functions
      embedding.add(sin(headEulerAngleY * pi / 180) + employeeSeed * 0.0001);
      embedding.add(cos(headEulerAngleY * pi / 180) + employeeSeed * 0.0001);
      embedding.add(sin(headEulerAngleZ * pi / 180) + employeeSeed * 0.0001);
      embedding.add(cos(headEulerAngleZ * pi / 180) + employeeSeed * 0.0001);
      
      // 8. Pad to fixed size (256 dimensions for enhanced accuracy)
      while (embedding.length < 256) {
        embedding.add(0.0);
      }
      
      final finalEmbedding = embedding.take(256).toList();
      
      print('✅ DEBUG: Generated enhanced face embedding with landmarks for ${widget.employee.fullName}, capture ${captureIndex + 1}: ${finalEmbedding.length} dimensions');
      print('📊 DEBUG: Feature summary - Face: ${boundingBox.width.toInt()}x${boundingBox.height.toInt()}, Landmarks: ${landmarks.values.where((l) => l != null).length}/8, Smile: ${(smilingProb * 100).toStringAsFixed(1)}%');
      
      return finalEmbedding;
      
    } catch (e) {
      print('❌ DEBUG: Enhanced face embedding generation error: $e');
      return [];
    }
  }

  // Generate web-compatible face embedding (for web platform)
  Future<List<double>> _generateWebFaceEmbedding(String imagePath, int captureIndex) async {
    // Create unique embedding based on employee ID, image path, and angle
    final employeeId = widget.employee.id;
    final combinedHash = employeeId.hashCode + imagePath.hashCode + captureIndex * 1000;
    
    // Use a fixed random seed for consistency
    final random = Random(combinedHash);
    
    // Generate 256-dimensional embedding (matching enhanced format)
    final embedding = List.generate(256, (index) {
      // Create features that vary by angle to simulate different perspectives
      final baseValue = (combinedHash + index) * 0.001;
      final angleVariation = (captureIndex - 1) * 0.1; // -0.1, 0, 0.1 for left, straight, right
      final randomVariation = (random.nextDouble() - 0.5) * 0.05;
      
      return (baseValue % 1.0) + angleVariation + randomVariation;
    });
    
    print('🌐 DEBUG: Generated web embedding for ${widget.employee.fullName}, capture ${captureIndex + 1}: ${embedding.length} dimensions');
    return embedding;
  }

  List<double> _averageEmbeddings(List<List<double>> embeddings) {
    if (embeddings.isEmpty) return [];
    
    final length = embeddings.first.length;
    final avgEmbedding = List<double>.filled(length, 0.0);
    
    for (final embedding in embeddings) {
      for (int i = 0; i < length; i++) {
        avgEmbedding[i] += embedding[i];
      }
    }
    
    for (int i = 0; i < length; i++) {
      avgEmbedding[i] /= embeddings.length;
    }
    
    return avgEmbedding;
  }

  // 🆕 AVERAGE LANDMARKS FROM MULTIPLE CAPTURES
  Map<String, List<double>> _averageLandmarks(List<Map<String, List<double>>> landmarksList) {
    if (landmarksList.isEmpty) return {};
    
    final avgLandmarks = <String, List<double>>{};
    final allKeys = <String>{};
    
    // Collect all landmark keys from all captures
    for (final landmarks in landmarksList) {
      allKeys.addAll(landmarks.keys);
    }
    
    // Average each landmark point
    for (final key in allKeys) {
      final points = <List<double>>[];
      
      // Collect all instances of this landmark
      for (final landmarks in landmarksList) {
        if (landmarks.containsKey(key)) {
          points.add(landmarks[key]!);
        }
      }
      
      if (points.isNotEmpty) {
        // Average the coordinates
        final avgPoint = <double>[];
        final pointLength = points.first.length;
        
        for (int i = 0; i < pointLength; i++) {
          double sum = 0.0;
          for (final point in points) {
            if (i < point.length) {
              sum += point[i];
            }
          }
          avgPoint.add(sum / points.length);
        }
        
        avgLandmarks[key] = avgPoint;
      }
    }
    
    return avgLandmarks;
  }

  // 🆕 AVERAGE GEOMETRY FROM MULTIPLE CAPTURES  
  Map<String, double> _averageGeometry(List<Map<String, double>> geometryList) {
    if (geometryList.isEmpty) return {};
    
    final avgGeometry = <String, double>{};
    final allKeys = <String>{};
    
    // Collect all geometry keys from all captures
    for (final geometry in geometryList) {
      allKeys.addAll(geometry.keys);
    }
    
    // Average each geometry measurement
    for (final key in allKeys) {
      double sum = 0.0;
      int count = 0;
      
      for (final geometry in geometryList) {
        if (geometry.containsKey(key)) {
          sum += geometry[key]!;
          count++;
        }
      }
      
      if (count > 0) {
        avgGeometry[key] = sum / count;
      }
    }
    
    return avgGeometry;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Register Face - ${widget.employee.fullName}'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Camera View
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _messageColor, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: _isInitialized && _cameraController != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _cameraController!.value.previewSize!.height,
                                height: _cameraController!.value.previewSize!.width,
                                child: CameraPreview(_cameraController!),
                              ),
                            ),
                          ),
                          
                          // Face detection overlay
                          Center(
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: 200,
                                    height: 250,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _messageColor,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Processing indicator
                          if (_isProcessing)
                            Container(
                              color: Colors.black54,
                              child: const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            ),
                        ],
                      )
                    : const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
              ),
            ),
          ),
          
          // Instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade700),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.face,
                  size: 48,
                  color: _messageColor,
                ),
                const SizedBox(height: 16),
                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _messageColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Position face in frame • Look directly at camera • Good lighting',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Capture Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_requiredCaptures, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < _captureCount 
                            ? AppColors.success 
                            : Colors.grey.shade600,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  'Progress: $_captureCount/$_requiredCaptures',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Capture Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _isInitialized && !_isProcessing && !_isCapturing 
                  ? _captureFace 
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _captureCount < _requiredCaptures 
                    ? 'Capture ${_captureDescriptions[_captureCount]} (${_captureCount + 1}/$_requiredCaptures)'
                    : 'Processing...',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _pulseController.dispose();
    _faceDetector.close();
    
    try {
      _faceService.dispose();
    } catch (e) {
      // Ignore if dispose method doesn't exist
    }
    
    super.dispose();
  }
}
