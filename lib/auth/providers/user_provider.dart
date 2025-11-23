import 'dart:io';

import 'package:animal_kart_demo2/utils/app_constants.dart';
import 'package:animal_kart_demo2/widgets/floating_toast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

final userProfileProvider = ChangeNotifierProvider<UserProfileNotifier>(
  (ref) => UserProfileNotifier(),
);

// In user_profile_notifier.dart or your provider file
class UserProfileNotifier extends ChangeNotifier {
  double? _frontUploadProgress;
  double? _backUploadProgress;
  bool _isFrontUploading = false;
  bool _isBackUploading = false;

  double? get frontUploadProgress => _frontUploadProgress;
  double? get backUploadProgress => _backUploadProgress;
  bool get isFrontUploading => _isFrontUploading;
  bool get isBackUploading => _isBackUploading;
  bool get isUploading => _isFrontUploading || _isBackUploading;

  // Upload individual Aadhaar front image
  Future<String?> uploadAadhaarFront({
    required File file,
    required String userId,
  }) async {
    try {
      _isFrontUploading = true;
      _frontUploadProgress = 0.0;
      notifyListeners();

      final now = DateTime.now();
      final dateFolder =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

      final storage = FirebaseStorage.instanceFor(
        bucket: AppConstants.storageBucketName,
      );

      final url = await _uploadFile(
        storage,
        file,
        "userpics/$dateFolder/${userId}_aadhaar_front.jpg",
        isfront: true,
      );

      return url;
    } catch (e) {
      debugPrint('Error uploading Aadhaar front: $e');
      rethrow;
    } finally {
      _isFrontUploading = false;
      _frontUploadProgress = null;
      notifyListeners();
    }
  }

  // Upload individual Aadhaar back image
  Future<String?> uploadAadhaarBack({
    required File file,
    required String userId,
  }) async {
    try {
      _isBackUploading = true;
      _backUploadProgress = 0.0;
      notifyListeners();

      final now = DateTime.now();
      final dateFolder =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

      final storage = FirebaseStorage.instanceFor(
        bucket: AppConstants.storageBucketName,
      );

      final url = await _uploadFile(
        storage,
        file,
        "userpics/$dateFolder/${userId}_aadhaar_back.jpg",
        isfront: false,
      );

      return url;
    } catch (e) {
      debugPrint('Error uploading Aadhaar back: $e');
      rethrow;
    } finally {
      _isBackUploading = false;
      _backUploadProgress = null;
      notifyListeners();
    }
  }

  Future<Map<String, String>> saveAadhaarDetailsToDb({
    required File aadhaarFront,
    File? aadhaarBack,
    required String userId,
  }) async {
    final urls = <String, String>{};

    try {
      // Upload front image
      if (aadhaarFront != null) {
        final frontUrl = await uploadAadhaarFront(
          file: aadhaarFront,
          userId: userId,
        );
        if (frontUrl != null) {
          urls["aadhaar_front_url"] = frontUrl;
        }
      }

      // Upload back image if exists
      if (aadhaarBack != null) {
        final backUrl = await uploadAadhaarBack(
          file: aadhaarBack,
          userId: userId,
        );
        if (backUrl != null) {
          urls["aadhaar_back_url"] = backUrl;
        }
      }

      return urls;
    } catch (e) {
      debugPrint('Error uploading Aadhaar: $e');
      rethrow;
    }
  }

  // Delete Aadhaar front image from Firebase
  Future<bool> deleteAadhaarFront({required String userId}) async {
    try {
      final now = DateTime.now();
      final dateFolder =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

      final storage = FirebaseStorage.instanceFor(
        bucket: AppConstants.storageBucketName,
      );

      final ref = storage.ref().child("userpics/$dateFolder/${userId}_aadhaar_front.jpg");
      await ref.delete();
      
      FloatingToast.showSimpleToast('Front image deleted successfully');
      return true;
    } catch (e) {
      debugPrint('Error deleting front image: $e');
      FloatingToast.showSimpleToast('Failed to delete front image');
      return false;
    }
  }

  // Delete Aadhaar back image from Firebase
  Future<bool> deleteAadhaarBack({required String userId}) async {
    try {
      final now = DateTime.now();
      final dateFolder =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

      final storage = FirebaseStorage.instanceFor(
        bucket: AppConstants.storageBucketName,
      );

      final ref = storage.ref().child("userpics/$dateFolder/${userId}_aadhaar_back.jpg");
      await ref.delete();
      
      FloatingToast.showSimpleToast('Back image deleted successfully');
      return true;
    } catch (e) {
      debugPrint('Error deleting back image: $e');
      FloatingToast.showSimpleToast('Failed to delete back image');
      return false;
    }
  }

  Future<String> _uploadFile(
    FirebaseStorage storage,
    File file,
    String path, {
    required bool isfront,
  }) async {
    try {
      final ref = storage.ref().child(path);
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: "image/jpeg"),
      );

      //Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        
        if (isfront) {
          _frontUploadProgress = progress;
        } else {
          _backUploadProgress = progress;
        }
        
        notifyListeners();
        
        if (snapshot.state == TaskState.success) {
          FloatingToast.showSimpleToast(
            isfront ? 'Front image uploaded successfully' : 'Back image uploaded successfully'
          );
        }
      });

      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      rethrow;
    }
  }
}
