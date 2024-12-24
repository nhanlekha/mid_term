import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mid_term/data/firebase_service/firebase_auth.dart';
import 'package:mid_term/data/firebase_service/post_service.dart';
import 'package:mid_term/data/firebase_service/user_list.dart';
import 'package:mid_term/data/model/post.dart';
import 'package:mid_term/helpers/color.dart';
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
  final authentication = Authentication();

  @override
  void initState() {
    super.initState();
    UserService().updateActiveStatus(true);
    SystemChannels.lifecycle.setMessageHandler((message) {
      log("Message: $message");
      if (message.toString().contains('paused')) {
        UserService().updateActiveStatus(false);
      }
      if (message.toString().contains('resumed')) {
        UserService().updateActiveStatus(true);
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorData.backGroundColorTextField,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 2,
      backgroundColor: ColorData.backGroundColorTextField,
      surfaceTintColor: ColorData.backGroundColorTextField,
      centerTitle: true,
      title: Image.asset(
        'assets/images/logo.png',
        height: 28,
      ),
      leading: IconButton(
        icon: Icon(Icons.camera_alt_outlined, color: Colors.black, size: 26),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const CameraScreens(),
          ));
        },
      ),
      actions: [
        StreamBuilder(
          stream: UserService().getUnreadConversationsStream(),
          builder: (context, snapshot) {
            final unreadCount = snapshot.data ?? 0;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(FontAwesomeIcons.solidMessage,
                      color: Colors.black, size: 22),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatPage()),
                    );
                  },
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.all(5.r),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        IconButton(
          icon:
              Icon(FontAwesomeIcons.signOutAlt, color: Colors.black, size: 22),
          onPressed: authentication.signOut,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return StreamBuilder(
      stream: PostService().getAllPostUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: ColorData.backgroundColor,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No posts available!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final posts =
            snapshot.data!.docs.map((e) => Post.fromJson(e.data())).toList();

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 10),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostWidget(posts[index]);
          },
        );
      },
    );
  }
}
