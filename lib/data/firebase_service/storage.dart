import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMethod {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var uid_rd = Uuid().v4();

  Future<String> uploadImageToStorage(String name, File file) async {
    Reference ref =
        _storage.ref().child(name).child(_auth.currentUser!.uid).child(uid_rd);

    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadImageToFirebase(File imageFile,String name, String? id) async {

    if (imageFile == null) {
      throw Exception("Hình ảnh không hợp lệ!");
    }

    final storageRef = FirebaseStorage.instance.ref().child(name).child(id!).child(uid_rd);
    await storageRef.putFile(imageFile, SettableMetadata(
      cacheControl: 'max-age=3600',
      contentType: 'image/jpeg',
    ));
    String downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  }
}
