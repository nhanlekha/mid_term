import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mid_term/data/model/usermodel.dart';

class UserService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  static late UserModel userMod;

  static User get user => auth.currentUser!;

  Stream<UserModel> get Usermodel {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .snapshots()
        .map((snapshot) => UserModel.fromJson(snapshot.data()!));
  }

  static Future getSelfInfo() async {
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((value) => userMod = UserModel.fromJson(value.data()!));
  }

  static Future userExist() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUsersOn() {
    return firestore
        .collection('users')
        .where('isOnline', isEqualTo: true)
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    print(user.uid);
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future updateProfileImage(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profile_image/${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: "image/$ext"))
        .then((p0) {
      print('Data: ${p0.bytesTransferred / 1000} kb');
    });
    String image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({'image': image});
  }

  static Future updateActiveOrUnactive(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update(
        {'isOnline': isOnline, 'lastActive': DateTime.now().toString()});
  }
}
