import 'package:cloud_firestore/cloud_firestore.dart';

class VideoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Check if a video title already exists for a specific user
  Future<bool> checkDuplicateTitle(String userId, String title) async {
    final querySnapshot = await _db
        .collection('videos')
        .where('userId', isEqualTo: userId)
        .where('videoTitle', isEqualTo: title)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  /// Save video creation data to Firestore
  Future<String> saveVideoData({
    required String userId,
    required String videoTitle,
    required String category,
    required String description,
    required String background,
    required String characters,
    required int duration,
    required String aspectRatio,
    required String aiGeneratedPrompt,
    required int seed,
  }) async {
    final docRef = await _db.collection('videos').add({
      'userId': userId,
      'videoTitle': videoTitle,
      'category': category,
      'description': description,
      'background': background,
      'characters': characters,
      'duration': duration,
      'aspectRatio': aspectRatio,
      'aiGeneratedPrompt': aiGeneratedPrompt,
      'seed': seed,
      'runwayTaskId': null,
      'videoUrl': null,
      'status': 'generating',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Update video status and details after generation
  Future<void> updateVideoStatus({
    required String videoId,
    required String status,
    String? runwayTaskId,
    String? videoUrl,
  }) async {
    final updateData = {
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (runwayTaskId != null) {
      updateData['runwayTaskId'] = runwayTaskId;
    }

    if (videoUrl != null) {
      updateData['videoUrl'] = videoUrl;
    }

    await _db.collection('videos').doc(videoId).update(updateData);
  }

  /// Get all videos for a specific user
  Stream<QuerySnapshot> getUserVideos(String userId) {
    return _db
        .collection('videos')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get a specific video by ID
  Future<DocumentSnapshot> getVideo(String videoId) async {
    return await _db.collection('videos').doc(videoId).get();
  }
}
