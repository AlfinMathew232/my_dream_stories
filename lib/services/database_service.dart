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
      'title': title,
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
    final usersCount = await _db
        .collection('users')
        .where('role', isNotEqualTo: 'admin')
        .get();

    final proCount = await _db
        .collection('users')
        .where('role', isNotEqualTo: 'admin')
        .where('isPro', isEqualTo: true)
        .get();

    final videosCount = await _db.collection('videos').get();

    return {
      'totalUsers': usersCount.docs.length,
      'proMembers': proCount.docs.length,
      'videosCreated': videosCount.docs.length,
    };
  }

  // Admin: get all users with their subscription status
  Stream<QuerySnapshot> getUsersStream() {
    return _db
        .collection('users')
        .where('role', isNotEqualTo: 'admin')
        .snapshots();
  }

  // Update User Profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }
}
