// ignore_for_file: avoid_print

import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class ImageCaptureService {
  static final ImageCaptureService _instance = ImageCaptureService._internal();
  factory ImageCaptureService() => _instance;
  ImageCaptureService._internal();

  // Capture face from camera image and crop to face bounding box
  Future<File?> captureFaceImage(
    CameraImage cameraImage, 
    Face face, {
    required String employeeId,
    required String type, // 'checkin' or 'checkout'
  }) async {
    try {
      print('🖼️ DEBUG: Capturing face image for $employeeId ($type)');
      
      // Convert CameraImage to Image format
      final image = _convertCameraImage(cameraImage);
      if (image == null) return null;
      
      // Crop to face bounding box with padding
      final croppedFace = _cropFaceFromImage(image, face);
      if (croppedFace == null) return null;
      
      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'face_${employeeId}_${type}_$timestamp.jpg';
      final filePath = '${tempDir.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(img.encodeJpg(croppedFace));
      
      print('✅ DEBUG: Face image captured: $filePath');
      return file;
      
    } catch (e) {
      print('❌ DEBUG: Face image capture failed: $e');
      return null;
    }
  }

  img.Image? _convertCameraImage(CameraImage image) {
    try {
      if (image.format.group == ImageFormatGroup.yuv420) {
        return _convertYUV420ToImage(image);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        return _convertBGRA8888ToImage(image);
      }
      return null;
    } catch (e) {
      print('❌ DEBUG: Image conversion failed: $e');
      return null;
    }
  }

  img.Image _convertYUV420ToImage(CameraImage image) {
    final width = image.width;
    final height = image.height;
    
    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;
    
    final img.Image convertedImage = img.Image(width: width, height: height);
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * width + x;
        final int uvIndex = (y ~/ 2) * (width ~/ 2) + (x ~/ 2);
        
        final yValue = yPlane[yIndex].toInt();
        final uValue = uPlane[uvIndex].toInt() - 128;
        final vValue = vPlane[uvIndex].toInt() - 128;
        
        // Convert YUV to RGB
        final r = (yValue + 1.402 * vValue).clamp(0, 255).toInt();
        final g = (yValue - 0.344 * uValue - 0.714 * vValue).clamp(0, 255).toInt();
        final b = (yValue + 1.772 * uValue).clamp(0, 255).toInt();
        
        convertedImage.setPixelRgba(x, y, r, g, b, 255);
      }
    }
    
    return convertedImage;
  }

  img.Image _convertBGRA8888ToImage(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final bytes = image.planes[0].bytes;
    
    return img.Image.fromBytes(width: width, height: height, bytes: bytes.buffer);
  }

  img.Image? _cropFaceFromImage(img.Image image, Face face) {
    try {
      final boundingBox = face.boundingBox;
      
      // Add padding around face (20% of face size)
      final paddingX = boundingBox.width * 0.2;
      final paddingY = boundingBox.height * 0.2;
      
      // Calculate crop area with bounds checking
      final left = (boundingBox.left - paddingX).clamp(0, image.width - 1).toInt();
      final top = (boundingBox.top - paddingY).clamp(0, image.height - 1).toInt();
      final right = (boundingBox.right + paddingX).clamp(0, image.width).toInt();
      final bottom = (boundingBox.bottom + paddingY).clamp(0, image.height).toInt();
      
      final width = right - left;
      final height = bottom - top;
      
      if (width <= 0 || height <= 0) {
        print('❌ DEBUG: Invalid crop dimensions: ${width}x$height');
        return null;
      }
      
      print('🔍 DEBUG: Cropping face at ($left, $top) ${width}x$height');
      return img.copyCrop(image, x: left, y: top, width: width, height: height);
      
    } catch (e) {
      print('❌ DEBUG: Face cropping failed: $e');
      return null;
    }
  }

  // Upload to Firebase Storage
  Future<String?> uploadFaceImage(File imageFile, String employeeId, String type) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'faces/$employeeId/${type}_$timestamp.jpg';
      
      final ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(imageFile);
      
      final downloadUrl = await ref.getDownloadURL();
      print('✅ DEBUG: Face image uploaded: $downloadUrl');
      
      return downloadUrl;
    } catch (e) {
      print('❌ DEBUG: Image upload failed: $e');
      return null;
    }
  }
}
