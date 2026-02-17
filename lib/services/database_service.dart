import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get User Stream
  Stream<UserModel?> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromFirestore(snapshot);
      } else {
        return null;
      }
    });
  }

  // Get User Future
  Future<UserModel?> getUser(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  // Create Video Record
  Future<void> createVideoRecord({
    required String uid,
    required String title,
    required String category,
    required String description,
    required String characterId,
    required String backgroundId,
    required String videoUrl,
  }) async {
    await _db.collection('videos').add({
      'userId': uid,
      'videoTitle':
          title, // Changed from 'title' to 'videoTitle' to match VideoService
      'category': category,
      'description': description,
      'characterId': characterId,
      'backgroundId': backgroundId,
      'videoUrl': videoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get My Videos
  Stream<QuerySnapshot> getMyVideos(String uid) {
    return _db
        .collection('videos')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Admin: create category
  Future<void> createCategory(String name, String description) async {
    await _db.collection('categories').add({
      'name': name,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Admin: create character
  Future<void> createCharacter(String name, String description) async {
    await _db.collection('characters').add({
      'name': name,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Admin: create background
  Future<void> createBackground(String name, String description) async {
    await _db.collection('backgrounds').add({
      'name': name,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Admin: get dashboard stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Fetch all users and filter in memory to avoid Firestore index issues
      final allUsers = await _db.collection('users').get();
      final usersDocs = allUsers.docs
          .where((doc) => doc.data()['role'] != 'admin')
          .toList();
      final proDocs = usersDocs
          .where((doc) => doc.data()['isPro'] == true)
          .toList();

      final videosCount = await _db.collection('videos').get();
      final categoriesCount = await _db.collection('categories').get();
      final charactersCount = await _db.collection('characters').get();
      final backgroundsCount = await _db.collection('backgrounds').get();

      return {
        'totalUsers': usersDocs.length,
        'proMembers': proDocs.length,
        'videosCreated': videosCount.docs.length,
        'totalCategories': categoriesCount.docs.length,
        'totalCharacters': charactersCount.docs.length,
        'totalBackgrounds': backgroundsCount.docs.length,
      };
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      // Return empty stats or rethrow depending on needs. modified: rethrow to show in UI
      rethrow;
    }
  }

  // Admin: get all users with their subscription status
  Stream<QuerySnapshot> getUsersStream() {
    return _db
        .collection('users')
        .where('role', isNotEqualTo: 'admin')
        .snapshots();
  }

  // Delete Video
  Future<void> deleteVideo(String videoId) async {
    await _db.collection('videos').doc(videoId).delete();
  }

  // Update User Profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }
}
