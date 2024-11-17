import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mid_term/data/firebase_service/storage.dart';

import '../../util/exeption.dart';
import 'firestor.dart';

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> Login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
    } on FirebaseException catch (e) {
      throw exceptions(e.message.toString());
    }
  }

  Future<void> Signup({
    required String email,
    required String password,
    required String passwordConfirme,
    required String username,
    required String bio,
    required File profile,
  }) async {
    String URL;
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty) {
        if (password == passwordConfirme) {
          // create user with email and password
          UserCredential userCredential =
              await _auth.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
          // upload profile image on storage
          String? uid = userCredential.user?.uid;

          print('ID : $uid');

          if (profile != File('')) {
            URL = await StorageMethod()
                .uploadImageToFirebase(profile, 'Profile', uid);
          } else {
            URL = '';
          }

          // get information with firestor
          await Firebase_Firestor().CreateUser(
            uid: uid!,
            email: email,
            username: username,
            bio: bio,
            profile: URL == ''
                ? 'https://firebasestorage.googleapis.com/v0/b/instagram-8a227.appspot.com/o/person.png?alt=media&token=c6fcbe9d-f502-4aa1-8b4b-ec37339e78ab'
                : URL,
          );
        } else {
          throw exceptions('password and confirm password should be same');
        }
      } else {
        throw exceptions('enter all the fields');
      }
    } on FirebaseException catch (e) {
      throw exceptions(e.message.toString());
    }
  }

  Future signOut() async {
    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid);
      final userSnapshot = await userRef.get();
      if (userSnapshot.exists) {
        final time = DateTime.now().toString();
        await userRef.update({
          // 'name': user.displayName,
          'about': "Not available here at the moment",
          'lastActive': time,
          'isOnline': false,
        });
      }
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
