import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseMethods {

  Future<String> uploadImageToFirebase(File imageFile, String id) async {

    if (imageFile == null) {
      throw Exception("Hình ảnh không hợp lệ!");
    }


    final storageRef = FirebaseStorage.instance.ref().child('images/$id');
      await storageRef.putFile(imageFile, SettableMetadata(
        cacheControl: 'max-age=3600',
        contentType: 'image/jpeg',
      ));
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
  }

  Future addProductDetails(
      Map<String, dynamic> productInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Product")
        .doc(id)
        .set(productInfoMap);
  }

  Future<Stream<QuerySnapshot>> getProductDetails() async{
    return await FirebaseFirestore.instance.collection("Product").snapshots();
  }

  Future updateProductDetails(String id,Map<String, dynamic> productInfoMap) async{
    return await FirebaseFirestore.instance.collection("Product").doc(id).update(productInfoMap);
  }

  Future deleteProductDetails(String id) async{
    return await FirebaseFirestore.instance.collection("Product").doc(id).delete();
  }
}
