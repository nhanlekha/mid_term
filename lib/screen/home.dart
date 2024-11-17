import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mid_term/data/firebase_service/firebase_auth.dart';
import 'package:mid_term/data/firebase_service/user_list.dart';
import 'package:mid_term/screen/chats/chat.dart';

import '../widgets/post_widget.dart';
import 'add_post_camera.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final authentication = Authentication();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    UserService.updateActiveOrUnactive(true);
    SystemChannels.lifecycle.setMessageHandler((message) {
      log("Message: $message");
      if (message.toString().contains('paused'))
        UserService.updateActiveOrUnactive(false);
      if (message.toString().contains('resumed'))
        UserService.updateActiveOrUnactive(true);
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: SizedBox(
          width: 105.w,
          height: 28.h,
          child: Image.asset('images/instagram.jpg'),
        ),
        leading: GestureDetector(
          onTap: () async {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CameraScreens(),
            ));
          },
          child: Image.asset('images/camera.jpg'),
        ),
        actions: [
          IconButton(
              onPressed: () {
                authentication.signOut();
              },
              icon: Icon(FontAwesomeIcons.outdent)),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(),
                    ));
              },
              icon: Icon(FontAwesomeIcons.message))
        ],
        backgroundColor: const Color(0xffFAFAFA),
      ),
      body: CustomScrollView(
        slivers: [
          StreamBuilder(
            stream: _firebaseFirestore
                .collection('posts')
                .orderBy('time', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return PostWidget(snapshot.data!.docs[index].data());
                  },
                  childCount:
                      snapshot.data == null ? 0 : snapshot.data!.docs.length,
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
