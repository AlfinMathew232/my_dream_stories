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
}
