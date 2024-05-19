import 'package:cloud_firestore/cloud_firestore.dart';

class FriendModel {
  final String id;
  final String idNum;
  final String name;
  final String description;
  final String major;
  final String profileUrl;
  final String bannerUrl;
  final DateTime createdTime;
  final DateTime updatedTime;
  final String location;

  static const String defaultProfileImageUrl =
      'https://www.pixelstalk.net/wp-content/uploads/2016/05/Beautiful-Girl-Hd-Wallpapers-1080p-Free-Download.jpg';
  static const String defaultBannerImageUrl =
      'https://www.pixelstalk.net/wp-content/uploads/2016/05/Beautiful-Girl-Hd-Wallpapers-1080p-Free-Download.jpg';

  FriendModel({
    required this.id,
    required this.idNum,
    required this.name,
    required this.description,
    required this.major,
    required this.profileUrl,
    required this.bannerUrl,
    required this.createdTime,
    required this.updatedTime,
    required this.location,
  });

  factory FriendModel.fromDocument(DocumentSnapshot doc) {
    Timestamp createdTime = doc.get('createdTime');
    Timestamp updatedTime = doc.get('updatedTime');

    String profileUrl = doc.get('profileImageUrl') ?? defaultProfileImageUrl;
    String bannerUrl = doc.get('bannerImageUrl') ?? defaultBannerImageUrl;

    return FriendModel(
      id: doc.id,
      idNum: doc.get('idNum'),
      name: doc.get('name'),
      description: doc.get('description'),
      major: doc.get('major'),
      profileUrl: profileUrl,
      bannerUrl: bannerUrl,
      createdTime: createdTime.toDate(),
      updatedTime: updatedTime.toDate(),
      location: doc.get('location'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idNum': idNum,
      'name': name,
      'description': description,
      'major': major,
      'profileImageUrl': profileUrl,
      'bannerImageUrl': bannerUrl,
      'createdTime': createdTime,
      'updatedTime': updatedTime,
      'location': location,
    };
  }
}
