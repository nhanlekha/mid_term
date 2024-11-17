import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mid_term/data/model/message.dart';
import 'package:mid_term/data/model/usermodel.dart';

class ChatMessageService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static User get user => auth.currentUser!;

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      UserModel userChat) {
    return firestore
        .collection('chats/${getConversationID(userChat.id!)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future sendMessage(
      UserModel userChat, String message, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message mess = Message(
        toId: userChat.id!,
        msg: message,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time,
        isDelete: false);
    final ref = firestore
        .collection('chats/${getConversationID(userChat.id!)}/messages/');
    await ref.doc(time).set(mess.toJson());
  }

  static Future updateMessageRead(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      UserModel userModel) {
    return firestore
        .collection('chats/${getConversationID(userModel.id!)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future sendImageChat(UserModel userModel, File file) async {
    final ext = file.path.split('.').last;

    final ref = storage.ref().child(
        'images/${getConversationID(userModel.id!)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      print("Data: ${p0.bytesTransferred / 1000} kb");
    });

    final imageUrl = await ref.getDownloadURL();
    await sendMessage(userModel, imageUrl, Type.image);
  }

  static Future updateTextMessage(String message, Message messager) async {
    firestore
        .collection('chats/${getConversationID(messager.toId)}/messages/')
        .doc(messager.sent)
        .update({'msg': message});
  }

  static Future deleteTextMessage(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'isDelete': true});
  }
}
