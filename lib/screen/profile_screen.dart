import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mid_term/data/firebase_service/post_service.dart';
import 'package:mid_term/data/model/post.dart';
import 'package:mid_term/helpers/extensions.dart';
import 'package:mid_term/screen/post_screen.dart';
import 'package:mid_term/widgets/status_card.dart';

import '../data/firebase_service/firestor.dart';
import '../data/model/usermodel.dart';
import '../util/image_cached.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  String Uid;
  ProfileScreen({super.key, required this.Uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int post_lenght = 0;
  bool yourse = false;
  List following = [];
  bool follow = false;

  @override
  void initState() {
    super.initState();
    getdata();
    if (widget.Uid == _auth.currentUser!.uid) {
      setState(() {
        yourse = true;
      });
    }
  }

  getdata() async {
    DocumentSnapshot snap = await _firebaseFirestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();
    // Sử dụng giá trị mặc định nếu 'following' là null
    following = (snap.data()! as dynamic)['following'] ?? [];
    if (following.contains(widget.Uid)) {
      setState(() {
        follow = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: FutureBuilder(
                  future: Firebase_Firestor().getUser(UID: widget.Uid),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Head(snapshot.data!);
                  },
                ),
              ),
              StreamBuilder(
                stream: PostService().getPostsInProfile(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(child: Text("No posts available")),
                    );
                  }
                  final posts = snapshot.data!.docs
                      .map((e) => Post.fromJson(e.data()))
                      .toList();

                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PostScreen(posts[index]),
                              ),
                            );
                          },
                          child: CachedImage(
                            posts[index].postImage,
                          ),
                        );
                      },
                      childCount: posts.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget Head(UserModel user) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: context.mediaQueryWidth * 0.25,
                  height: context.mediaQueryWidth * 0.25,
                  child: CachedImage(user.profile ?? ''),
                ),
              ),
              SizedBox(width: 30),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatCard(
                      label: 'Posts',
                      count: post_lenght,
                    ),
                    StatCard(
                      label: 'Followers',
                      count: user.followers?.length ?? 0,
                    ),
                    StatCard(
                      label: 'Following',
                      count: user.following?.length ?? 0,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.username ??
                    'Unknown', // Dùng 'Unknown' nếu 'username' là null
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                user.bio ??
                    'No bio available', // Dùng 'No bio available' nếu 'bio' là null
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w300),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Follow/Unfollow button
          Visibility(
            visible: !follow,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 13),
              child: GestureDetector(
                onTap: () {
                  if (yourse == false) {
                    Firebase_Firestor().flollow(uid: widget.Uid);
                    setState(() {
                      follow = true;
                    });
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: yourse ? Colors.white : Colors.blue,
                    borderRadius: BorderRadius.circular(5.r),
                    border: Border.all(
                        color: yourse ? Colors.grey.shade400 : Colors.blue),
                  ),
                  child: yourse
                      ? Text('Edit Your Profile',
                          style: TextStyle(color: Colors.black))
                      : Text(
                          'Follow',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ),
          ),
          // Unfollow button
          Visibility(
            visible: follow,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 13),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Firebase_Firestor().flollow(uid: widget.Uid);
                        setState(() {
                          follow = false;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 40,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(5.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text('Unfollow'),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      height: 40,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(5.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text('Message'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          // Tab Bar
          SizedBox(
            width: double.infinity,
            height: 40,
            child: const TabBar(
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.black,
              indicatorColor: Colors.black,
              tabs: [
                Icon(Icons.grid_on),
                Icon(Icons.video_collection),
                Icon(Icons.person),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
