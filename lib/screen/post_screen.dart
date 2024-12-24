import 'package:flutter/material.dart';
import 'package:mid_term/data/model/post.dart';

import '../widgets/post_widget.dart';

class PostScreen extends StatelessWidget {
  final Post post;
  const PostScreen(this.post, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: PostWidget(post)),
    );
  }
}
