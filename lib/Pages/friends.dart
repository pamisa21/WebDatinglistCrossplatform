import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'friend_controller.dart';
import 'friend_details.dart';
import 'friend_model.dart';
import 'my_profile.dart';

class Friends extends StatefulWidget {
  const Friends({Key? key});

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final FriendController _friendController = FriendController();

  // Sample notifications, you can replace this with actual notifications
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    _generateNotifications();
  }

  void _generateNotifications() {
    // Get current date
    DateTime currentDate = DateTime.now();

    // Retrieve friends from Firestore
    _friendController.getFriends().then((List<FriendModel>? friends) {
      if (friends != null) {
        for (var friend in friends) {
          // Check if friend's date matches the current date
          if (friend.updatedTime.year == currentDate.year &&
              friend.updatedTime.month == currentDate.month &&
              friend.updatedTime.day == currentDate.day) {
            // Add notification with friend's name
            notifications.add("Today's date with ${friend.name}");
          }
        }
      }
      setState(() {}); // Update UI with generated notifications
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DATING LIST!',
          style: GoogleFonts.lato(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.redAccent,
        elevation: 2,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.notifications),
            itemBuilder: (BuildContext context) {
              return notifications.map((String notification) {
                return PopupMenuItem<String>(
                  value: notification,
                  child: Text(notification),
                );
              }).toList();
            },
            onSelected: (String selectedNotification) {
              // Handle notification selection
              print('Selected notification: $selectedNotification');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<FriendModel>>(
        future: _friendController.getFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error loading friends: ${snapshot.error}');
            return Center(child: Text('Error loading friends'));
          } else {
            List<FriendModel>? allFriends = snapshot.data;
            // Get current date
            DateTime currentDate = DateTime.now();

            // Filter friends based on updated time greater than or equal to current date
            List<FriendModel>? futureFriends = allFriends
                ?.where((friend) =>
                    friend.updatedTime.isAfter(currentDate) ||
                    (friend.updatedTime.year == currentDate.year &&
                        friend.updatedTime.month == currentDate.month &&
                        friend.updatedTime.day == currentDate.day))
                .toList();

            return ListView.builder(
              itemCount: futureFriends?.length ?? 0,
              itemBuilder: (context, index) {
                FriendModel friend = futureFriends![index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendDetails(friend: friend),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16.0),
                                topRight: Radius.circular(16.0),
                              ),
                              child: Image.network(
                                friend.profileUrl.isNotEmpty
                                    ? friend.profileUrl
                                    : FriendModel.defaultProfileImageUrl,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _deleteFriend(friend.id);
                                    },
                                    icon: const Icon(Icons.delete),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _editFriend(friend);
                                    },
                                    icon: const Icon(Icons.edit),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                friend.name,
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                friend.description,
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Color.fromARGB(255, 217, 56, 56)),
                                  const SizedBox(width: 4),
                                  Text(
                                    friend.location,
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.calendar_today,
                                      color: Color.fromARGB(255, 19, 14, 14)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${friend.updatedTime.year}-${friend.updatedTime.month}-${friend.updatedTime.day}',
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.access_time,
                                      color: Color.fromARGB(255, 46, 26, 144)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${friend.updatedTime.hour % 12}:${friend.updatedTime.minute.toString().padLeft(2, '0')} ${friend.updatedTime.hour >= 12 ? 'PM' : 'AM'}',
                                    style: GoogleFonts.lato(
                                      textStyle: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      width:
                                          8), // Spacing between icon and tooltip
                                  Tooltip(
                                    message:
                                        'Last updated at ${friend.updatedTime}',
                                    child: Icon(
                                      Icons.info,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyProfile()),
          );
        },
        backgroundColor: Colors.redAccent,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      drawer: Drawer(
        child: FutureBuilder<List<FriendModel>>(
          future: _friendController.getFriends(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print('Error loading friends: ${snapshot.error}');
              return Center(child: Text('Error loading friends'));
            } else {
              List<FriendModel>? friends = snapshot.data;

              // Get current date and time
              DateTime now = DateTime.now();

              // Filter friends for pending and done dates
              List<FriendModel>? pendingFriends = friends
                  ?.where((friend) => friend.updatedTime.isAfter(now))
                  .toList();
              List<FriendModel>? doneFriends = friends
                  ?.where((friend) => friend.updatedTime.isBefore(now))
                  .toList();

              return ListView(
                children: [
                  const ListTile(
                    title: Text(
                      'Pending Dates',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: pendingFriends?.length ?? 0,
                    itemBuilder: (context, index) {
                      FriendModel friend = pendingFriends![index];
                      return ListTile(
                        title: Text(
                          friend.name,
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 18,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FriendDetails(friend: friend),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Done Dates',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: doneFriends?.length ?? 0,
                    itemBuilder: (context, index) {
                      FriendModel friend = doneFriends![index];
                      return ListTile(
                        title: Text(
                          friend.name,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FriendDetails(friend: friend),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  void _deleteFriend(String friendId) async {
    try {
      await FirebaseFirestore.instance
          .collection('friends')
          .doc(friendId)
          .delete();
      setState(() {
        // Refresh the UI after deletion
      });
    } catch (error) {
      print('Error deleting friend: $error');
      // Handle error
    }
  }

  void _editFriend(FriendModel friend) {
    // Navigate to edit screen with friend data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFriendScreen(friend: friend),
      ),
    );
  }
}

class EditFriendScreen extends StatefulWidget {
  final FriendModel friend;

  const EditFriendScreen({Key? key, required this.friend}) : super(key: key);

  @override
  State<EditFriendScreen> createState() => _EditFriendScreenState();
}

class _EditFriendScreenState extends State<EditFriendScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.friend.name);
    _descriptionController =
        TextEditingController(text: widget.friend.description);
    _locationController = TextEditingController(text: widget.friend.location);

    _selectedDate = widget.friend.updatedTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.friend.updatedTime);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // Get the updated values from text controllers and update friend data
    String newName = _nameController.text;
    String newDescription = _descriptionController.text;
    String newLocation = _locationController.text;
    DateTime updatedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Update Firestore document with new data
    FirebaseFirestore.instance
        .collection('friends')
        .doc(widget.friend.id)
        .update({
      'name': newName,
      'description': newDescription,
      'updatedTime': updatedDateTime,
      'location': newLocation,
    });

    // Navigate back to Friends screen
    Navigator.pop(context);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Friend'),
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Name',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter name',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Enter description',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'Enter location',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                      'Select Date: ${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}'),
                ),
                TextButton(
                  onPressed: () => _selectTime(context),
                  child: Text(
                      'Select Time: ${_selectedTime.hour}:${_selectedTime.minute}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
