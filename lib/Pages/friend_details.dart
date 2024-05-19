import 'package:flutter/material.dart';
import 'friend_model.dart';
import 'friends.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FriendDetails extends StatelessWidget {
  final FriendModel friend;

  const FriendDetails({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(friend.name, style: const TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Friends()),
            );
          },
        ),
      ),
      body: ListView(
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 144 / 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: CachedNetworkImage(
                    imageUrl: friend.bannerUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
              Positioned(
                top: 250 - 144 / 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the last friend stored in the database
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.all(20),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 30),
                    CircleAvatar(
                      radius: 75,
                      backgroundColor: Colors.grey.shade800,
                      backgroundImage:
                          CachedNetworkImageProvider(friend.profileUrl),
                    ),
                    const SizedBox(width: 30),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the first friend stored in the database
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.all(20),
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildFloatingInfoBox('ID Number', friend.idNum),
          const SizedBox(height: 20),
          _buildFloatingInfoBox('Description', friend.description),
          const SizedBox(height: 20),
          _buildFloatingInfoBox('Major', friend.major),
          const SizedBox(height: 20),
          _buildFloatingInfoBox('Date', friend.updatedTime.toString()),
          const SizedBox(height: 20),
          _buildFloatingInfoBox('Location', friend.location),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFloatingInfoBox(String label, String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            text,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
