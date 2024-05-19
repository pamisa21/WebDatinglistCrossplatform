// friend_controller.dart
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'friend_model.dart';

class FriendController {
  final CollectionReference _friendCollection =
      FirebaseFirestore.instance.collection('friends');

  Future<List<FriendModel>> getFriends() async {
    QuerySnapshot querySnapshot = await _friendCollection.get();
    return querySnapshot.docs
        .map((doc) => FriendModel.fromDocument(doc))
        .toList();
  }

  Future<int> getFriendsCount() async {
    QuerySnapshot querySnapshot = await _friendCollection.get();
    return querySnapshot.docs.length;
  }

  Future<int> countPendingDates() async {
    DateTime now = DateTime.now();
    List<FriendModel> friends = await getFriends();
    int pendingCount = friends
        .where((friend) =>
            friend.updatedTime.isAfter(now) ||
            friend.updatedTime.isAtSameMomentAs(now))
        .length;
    return pendingCount;
  }

  Future<int> countCompleteDates() async {
    DateTime now = DateTime.now();
    List<FriendModel> friends = await getFriends();
    int completeCount =
        friends.where((friend) => friend.updatedTime.isBefore(now)).length;
    return completeCount;
  }

  Future<void> addFriend(
      String idNum,
      String name,
      String description,
      String major,
      String profileImageUrl,
      String bannerImageUrl,
      String location) async {
    try {
      DateTime createdTime = DateTime.now();
      DateTime updatedTime = DateTime.now();
      await _friendCollection
          .add({
            'idNum': idNum,
            'name': name,
            'description': description,
            'major': major,
            'profileImageUrl': profileImageUrl,
            'bannerImageUrl': bannerImageUrl,
            'createdTime': createdTime,
            'updatedTime': updatedTime,
            'location': location,
          })
          .then((value) => print("Friend Added"))
          .catchError((error) => print("Failed to add friend: $error"));
    } catch (e) {
      print(e);
    }
  }
}
