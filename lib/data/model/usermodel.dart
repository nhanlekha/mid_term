class UserModel {
  late String? email;
  late String? username;
  late String? bio;
  late String? profile;
  late List? following;
  late List? followers;
  late String? createAt;
  late bool? isOnline;
  late String? id;
  late String? lastActive;
  late String? pushToken;

  UserModel({
    this.email,
    this.username,
    this.bio,
    this.profile,
    this.following,
    this.followers,
    this.createAt,
    this.isOnline,
    this.id,
    this.lastActive,
    this.pushToken,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    username = json['username'] ?? '';
    bio = json['bio'] ?? '';
    profile = json['profile'] ?? '';
    following = json['following'] ?? '';
    followers = json['followers'] ?? '';
    createAt = json['createAt'] ?? '';
    isOnline = json['isOnline'] ?? false;
    id = json['id'] ?? '';
    lastActive = json['lastActive'] ?? '';
    pushToken = json['pushToken'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'bio': bio,
      'profile': profile,
      'following': following,
      'followers': followers,
      'createAt': createAt,
      'isOnline': isOnline,
      'id': id,
      'lastActive': lastActive,
      'pushToken': pushToken,
    };
  }
}
