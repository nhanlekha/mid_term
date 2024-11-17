import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mid_term/data/model/usermodel.dart';
import 'package:mid_term/util/exeption.dart';

import 'package:uuid/uuid.dart';

class Firebase_Firestor {
  final _firebaseFirestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<bool> CreateUser({
    required String email,
    required String username,
    required String bio,
    required String profile,
    required String uid,
  }) async {
    final time = DateTime.now().toString();
    await _firebaseFirestore.collection('users').doc(uid).set({
      'id': uid,
      'email': email,
      'username': username,
      'bio': bio,
      'profile': profile,
      'followers': [],
      'following': [],
      'createAt': time,
      'isOnline': true,
      'lastActive': time,
      'pushToken': ''
    });
    return true;
  }

  UserModel? userFromUserFirebase(User? user) {
    // final FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(auth.currentUser!.uid)
    //     .snapshots()
    //     .map((snapshot) => UserModel.fromJson(snapshot.data()!))
    print("haha");
    return user != null
        ? UserModel(
            id: user.uid,
            username: user.displayName ?? '',
            email: user.email!,
            profile: user.photoURL ??
                'https://th.bing.com/th/id/R.d02061d59b1f9b5b1db20b5fa6749f48?rik=Gc3l1dJlfrfscQ&riu=http%3a%2f%2fcdn.onlinewebfonts.com%2fsvg%2fimg_166744.png&ehk=TJ62R7UEQzaUkJDJyF65LfVv88VY3IJnu55T0AgHOwg%3d&risl=&pid=ImgRaw&r=0',
          )
        : null;
  }

  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(userFromUserFirebase);
  }

  Future<UserModel> getUser({String? UID}) async {
    try {
      final user = await _firebaseFirestore
          .collection('users')
          .doc(UID ?? _auth.currentUser!.uid)
          .get();

      final snapuser = user.data()!;

      return UserModel(
          bio: snapuser['bio'],
          email: snapuser['email'],
          followers: snapuser['followers'],
          following: snapuser['following'],
          profile: snapuser['profile'],
          username: snapuser['username'],
          createAt: snapuser['createAt'],
          id: snapuser['id'],
          isOnline: snapuser['isOnline'],
          lastActive: snapuser['lastActive'],
          pushToken: snapuser['pushToken']);
    } on FirebaseException catch (e) {
      throw exceptions(e.message.toString());
    }
  }

  Future<bool> CreatePost({
    required String postImage,
    required String caption,
    required String location,
  }) async {
    var uid = Uuid().v4();
    DateTime data = DateTime.now();
    UserModel user = await getUser();
    await _firebaseFirestore.collection('posts').doc(uid).set({
      'postImage': postImage,
      'username': user.username,
      'profileImage': user.profile,
      'caption': caption,
      'location': location,
      'uid': _auth.currentUser!.uid,
      'postId': uid,
      'like': [],
      'time': data
    });
    return true;
  }

  Future<bool> CreatReels({
    required String video,
    required String caption,
  }) async {
    var uid = Uuid().v4();
    DateTime data = DateTime.now();
    UserModel user = await getUser();
    await _firebaseFirestore.collection('reels').doc(uid).set({
      'reelsvideo': video,
      'username': user.username,
      'profileImage': user.profile,
      'caption': caption,
      'uid': _auth.currentUser!.uid,
      'postId': uid,
      'like': [],
      'time': data
    });
    return true;
  }

  Future<bool> Comments({
    required String comment,
    required String type,
    required String uidd,
  }) async {
    var uid = Uuid().v4();
    UserModel user = await getUser();
    await _firebaseFirestore
        .collection(type)
        .doc(uidd)
        .collection('comments')
        .doc(uid)
        .set({
      'comment': comment,
      'username': user.username,
      'profileImage': user.profile,
      'CommentUid': uid,
    });
    return true;
  }

  Future<String> like({
    required List like,
    required String type,
    required String uid,
    required String postId,
  }) async {
    String res = 'some error';
    try {
      if (like.contains(uid)) {
        _firebaseFirestore.collection(type).doc(postId).update({
          'like': FieldValue.arrayRemove([uid])
        });
      } else {
        _firebaseFirestore.collection(type).doc(postId).update({
          'like': FieldValue.arrayUnion([uid])
        });
      }
      res = 'seccess';
    } on Exception catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> flollow({
    required String uid,
  }) async {
    DocumentSnapshot snap = await _firebaseFirestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();
    List following = (snap.data()! as dynamic)['following'];
    try {
      if (following.contains(uid)) {
        _firebaseFirestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({
          'following': FieldValue.arrayRemove([uid])
        });
        await _firebaseFirestore.collection('users').doc(uid).update({
          'followers': FieldValue.arrayRemove([_auth.currentUser!.uid])
        });
      } else {
        _firebaseFirestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({
          'following': FieldValue.arrayUnion([uid])
        });
        _firebaseFirestore.collection('users').doc(uid).update({
          'followers': FieldValue.arrayUnion([_auth.currentUser!.uid])
        });
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }
}
