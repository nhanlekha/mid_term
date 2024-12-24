import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PostService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllPostUser() {
    return firestore
        .collection('posts')
        .orderBy('time', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPostsInProfile() {
    return firestore
        .collection('posts')
        .where('uid', isEqualTo: auth.currentUser!.uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPostsByUid(String uid) {
    return firestore
        .collection('posts')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllPosts() {
    return firestore.collection('posts').snapshots();
  }

  // Lấy tất cả người dùng theo username (tìm kiếm)
  Stream<QuerySnapshot<Map<String, dynamic>>> searchUsers(String query) {
    return firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .snapshots();
  }

  Future<void> updateReport(String postId, List<String> reports) async {
    int reportCount = reports.length;

    await firestore.collection('posts').doc(postId).update({
      'report': reports,
      'reportCount': reportCount,
    });
  }
}
