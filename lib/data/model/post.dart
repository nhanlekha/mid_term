import 'package:firebase_auth/firebase_auth.dart';

class Post {
  final String? caption;
  final List<String>? likes;
  final String? location;
  final String? postId;
  final String? postImage;
  final String? profileImage;
  final String? time;
  final String? uid;
  final String? username;
  final List<String>? report; // Thêm trường report
  final int? reportCount;

  Post({
    this.caption,
    this.likes,
    this.location,
    this.postId,
    this.postImage,
    this.profileImage,
    this.time,
    this.uid,
    this.username,
    this.report, // Thêm vào constructor
    this.reportCount,
  });

  // Factory method to create a Post from a map (Firebase document snapshot)
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      caption: json['caption'] as String?,
      likes: (json['like'] as List<dynamic>?)?.cast<String>(),
      location: json['location'] as String?,
      postId: json['postId'] as String?,
      postImage: json['postImage'] as String?,
      profileImage: json['profileImage'] as String?,
      time: json['time'] as String?,
      uid: json['uid'] as String?,
      username: json['username'] as String?,
      report:
          (json['report'] as List<dynamic>?)?.cast<String>(), // Parse report
      reportCount: json['reportCount'] as int?,
    );
  }

  // Method to convert a Post object into a map (to send back to Firebase)
  Map<String, dynamic> toJson() {
    return {
      'caption': caption,
      'like': likes,
      'location': location,
      'postId': postId,
      'postImage': postImage,
      'profileImage': profileImage,
      'time': time.toString(),
      'uid': uid,
      'username': username,
      'report': report, // Serialize report
      'reportCount': reportCount,
    };
  }

  bool isLikedByUser(Post post) {
    return post.likes!.contains(FirebaseAuth.instance.currentUser!.uid);
  }

  bool isReportedByUser(Post post) {
    // Kiểm tra xem user hiện tại có trong danh sách report không
    return post.report!.contains(FirebaseAuth.instance.currentUser!.uid);
  }
}
