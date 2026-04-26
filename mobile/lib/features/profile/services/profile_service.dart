// ignore_for_file: avoid_print

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Upload profile picture to Supabase Storage (OPTIMIZED - no extra delays)
  Future<String?> uploadProfilePicture(String imagePath) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final imageFile = File(imagePath);
      final fileSizeInKB = imageFile.lengthSync() ~/ 1024;
      print('📤 Uploading: ${fileSizeInKB}KB');

      final fileName = '$userId/profile_picture.jpg';

      // ⚡ Single operation: upsert (no delete overhead!)
      await _supabase.storage.from('profile_pictures').upload(
        fileName,
        imageFile,
        fileOptions: const FileOptions(upsert: true),
      );

      print('✓ Uploaded');

      // Cache-busting: unique URL each time to force refresh
      final baseUrl = _supabase.storage.from('profile_pictures').getPublicUrl(fileName);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final publicUrl = '$baseUrl?t=$timestamp';

      // Update database with cache-busted URL
      await _supabase.from('profiles').update({'profile_picture_url': publicUrl}).eq('id', userId);

      print('✓ Done! (~1-2 sec)');
      return publicUrl;
    } catch (e) {
      print('✗ Error: $e');
      rethrow;
    }
  }

  /// Update user bio
  Future<void> updateBio(String bio) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('profiles')
          .update({'bio': bio})
          .eq('id', userId);

      print('✓ Bio updated successfully');
    } catch (e) {
      print('✗ Error updating bio: $e');
      rethrow;
    }
  }

  /// Delete profile picture
  Future<void> deleteProfilePicture() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final fileName = '$userId/profile_picture.jpg';

      // Delete from storage
      await _supabase.storage
          .from('profile_pictures')
          .remove([fileName]);

      // Clear URL from database
      await _supabase
          .from('profiles')
          .update({'profile_picture_url': null})
          .eq('id', userId);

      print('✓ Profile picture deleted');
    } catch (e) {
      print('✗ Error deleting profile picture: $e');
      rethrow;
    }
  }
}

// Riverpod Provider
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});
