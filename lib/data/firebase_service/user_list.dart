import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mid_term/data/model/usermodel.dart';

class UserService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  User? get currentUser => auth.currentUser;

  Future<UserModel?> getUserModel() async {
    try {
      final stream = UserService().userModelStream;
      await for (var userModel in stream) {
        // Get the first emitted value or the latest value
        return userModel; // This will return the first emitted value and exit the loop
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
    return null;
  }

  Stream<UserModel?> get userModelStream {
    final uid = currentUser?.uid;
    if (uid == null) {
      throw Exception('User is not logged in');
    }
    return firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromJson(snapshot.data()!);
      } else {
        return null; // Or handle appropriately if no data exists
      }
    });
  }

  Stream<int> getUnreadConversationsStream() {
    final uid = currentUser?.uid;
    if (uid == null) {
      throw Exception('User is not logged in');
    }
    try {
      return firestore
          .collectionGroup('messages')
          // .collection('messages')
          .where('toId', isEqualTo: uid)
          .snapshots()
          .map((snapshot) {
        var unreadSenders = <String>{};
        for (var doc in snapshot.docs) {
          final readStatus = doc['read'];
          final fromId = doc['fromId'];
          if (fromId != null && (readStatus == null || readStatus == "")) {
            unreadSenders.add(fromId);
          }
        }
        return unreadSenders.length;
      });
    } catch (e) {
      print('Error fetching unread conversations: $e');
      throw Exception('Failed to fetch unread conversations: $e');
    }
  }

  Future<void> updateProfileImage(File file) async {
    final uid = currentUser?.uid;
    if (uid == null) {
      throw Exception('User is not logged in');
    }

    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profile_image/$uid.$ext');
    await ref.putFile(file, SettableMetadata(contentType: "image/$ext"));
    final image = await ref.getDownloadURL();

    await firestore.collection('users').doc(uid).update({'image': image});
  }

  Future<void> updateActiveStatus(bool isOnline) async {
    final uid = currentUser?.uid;
    if (uid == null) {
      throw Exception('User is not logged in');
    }

    await firestore.collection('users').doc(uid).update({
      'isOnline': isOnline,
      'lastActive': DateTime.now().toString(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getOnlineUsersStream() {
    final uid = currentUser?.uid;
    if (uid == null) {
      throw Exception('User is not logged in');
    }

    return firestore
        .collection('users')
        .where('isOnline', isEqualTo: true)
        .where('id', isNotEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    final uid = currentUser?.uid;
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: uid)
        .snapshots();
  }
}
