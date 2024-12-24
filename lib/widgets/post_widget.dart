import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mid_term/data/model/post.dart';
import 'package:mid_term/helpers/color.dart';
import 'package:mid_term/helpers/date_until.dart';

import '../data/firebase_service/firestor.dart';
import '../util/image_cached.dart';
import 'comment.dart';
import 'like_animation.dart';

class PostWidget extends StatefulWidget {
  final Post post;

  const PostWidget(this.post, {super.key});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isAnimating = false;
  late String userId;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: ColorData.backgroundColor,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, 3),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildImageSection(),
          _buildInteractionSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 50.w,
              height: 50.h,
              child: CachedImage(widget.post.profileImage!),
            ),
          ),
          SizedBox(width: 15.w),
          // If location is null or empty, center the username
          if (widget.post.location?.isEmpty ?? true)
            Center(
              child: Text(
                widget.post.username!,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.username!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  widget.post.location!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.grey.shade600),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return GestureDetector(
      onDoubleTap: _handleLike,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 375.w,
            height: 375.h,
            child: CachedImage(
              widget.post.postImage,
            ),
          ),
          AnimatedOpacity(
            duration: Duration(milliseconds: 200),
            opacity: isAnimating ? 1 : 0,
            child: LikeAnimation(
              isAnimating: isAnimating,
              duration: Duration(milliseconds: 400),
              iconlike: false,
              End: () {
                setState(() {
                  isAnimating = false;
                });
              },
              child: Icon(
                Icons.favorite,
                size: 100.w,
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInteractionSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildLikeButton(),
              SizedBox(width: 20.w),
              _buildCommentButton(),
              SizedBox(width: 20.w),
              _buildShareButton(),
              const Spacer(),
              _buildSaveButton(),
            ],
          ),
          SizedBox(height: 15.h),
          Text(
            '${widget.post.likes!.length} likes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
          ),
          SizedBox(height: 10.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${widget.post.username!}: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: widget.post.caption!,
                  style: TextStyle(fontSize: 14.sp, color: Colors.black),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            MyDateUtil.getFormatDateTimePost(
                widget.post.time ?? DateTime.now()),
            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeButton() {
    return GestureDetector(
      onTap: _handleLike,
      child: Icon(
        widget.post.isLikedByUser(widget.post)
            ? Icons.favorite
            : Icons.favorite_border,
        color:
            widget.post.isLikedByUser(widget.post) ? Colors.red : Colors.black,
        size: 30.w,
      ),
    );
  }

  Widget _buildCommentButton() {
    return GestureDetector(
      onTap: _showCommentsBottomSheet,
      child: Icon(
        Icons.comment,
        color: Colors.black,
        size: 28.w,
      ),
    );
  }

  Widget _buildShareButton() {
    return GestureDetector(
      onTap: () {},
      child: Icon(
        Icons.send,
        color: Colors.black,
        size: 28.w,
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: () {},
      child: Icon(
        Icons.bookmark_border,
        color: Colors.black,
        size: 28.w,
      ),
    );
  }

  void _handleLike() {
    Firebase_Firestor().like(
      like: widget.post.likes!,
      type: 'posts',
      uid: userId,
      postId: widget.post.postId!,
    );
    setState(() => isAnimating = true);
  }

  void _showCommentsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        maxChildSize: 0.6,
        initialChildSize: 0.6,
        minChildSize: 0.3,
        builder: (_, controller) => Comment('posts', widget.post.postId!),
      ),
    );
  }
}
