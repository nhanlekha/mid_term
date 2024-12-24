import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mid_term/data/model/post.dart';
import 'package:mid_term/screen/post_screen.dart';
import 'package:mid_term/screen/profile_screen.dart';
import '../util/image_cached.dart';
import '../data/firebase_service/post_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController searchController = TextEditingController();
  bool showPosts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildSearchBox(),
            showPosts ? _buildPostGrid() : _buildUserList(),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSearchBox() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Container(
          height: 36.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.search, color: Colors.black),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      showPosts = value.isEmpty;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search User',
                    hintStyle: TextStyle(color: Colors.black),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: PostService().getAllPosts(),
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
            .map((e) => Post.fromJson(e.data() as Map<String, dynamic>))
            .toList();
        return SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final post = posts[index];
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
          gridDelegate: SliverQuiltedGridDelegate(
            crossAxisCount: 3,
            mainAxisSpacing: 3,
            crossAxisSpacing: 3,
            pattern: [
              QuiltedGridTile(2, 1),
              QuiltedGridTile(2, 2),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 1),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: PostService().searchUsers(searchController.text),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text("No users found")),
          );
        }

        final users = snapshot.data!.docs;

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final user = users[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(Uid: user.id),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 23.r,
                          backgroundImage: NetworkImage(user['profile']),
                        ),
                        SizedBox(width: 15.w),
                        Text(user['username']),
                      ],
                    ),
                  ),
                );
              },
              childCount: users.length,
            ),
          ),
        );
      },
    );
  }
}
