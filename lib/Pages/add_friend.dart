import 'dart:typed_data';
import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'friend_model.dart';
import 'friends.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';

class AddFriend extends StatefulWidget {
  const AddFriend({Key? key}) : super(key: key);

  @override
  _AddFriendState createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  final TextEditingController _idNumController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();

  String profileUrl = '';
  String coverUrl = '';
  DateTime currentDate = DateTime.now();
  TimeOfDay currentTime = TimeOfDay.now();
  String currentLocation = '';

  static const String defaultProfileImageUrl =
      'https://www.pixelstalk.net/wp-content/uploads/2016/05/Beautiful-Girl-Hd-Wallpapers-1080p-Free-Download.jpg';
  static const String defaultCoverImageUrl =
      'https://www.pixelstalk.net/wp-content/uploads/2016/05/Beautiful-Girl-Hd-Wallpapers-1080p-Free-Download.jpg';

  @override
  void dispose() {
    _idNumController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _majorController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      // Permission granted, do nothing
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Storage permission is required to select images."),
      ));
    }
  }

  Future<void> _uploadImage(String imageType) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await showDialog<XFile>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Image Source'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () async {
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                Navigator.pop(context, pickedFile);
              },
              child: const Text('Gallery'),
            ),
            SimpleDialogOption(
              onPressed: () async {
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.camera);
                Navigator.pop(context, pickedFile);
              },
              child: const Text('Camera'),
            ),
          ],
        );
      },
    );

    if (image != null) {
      Uint8List fileData = await image.readAsBytes();
      String fileName = image.name;
      String mimeType = 'image/jpeg';

      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot
          .child(imageType == 'profile' ? 'profile_images' : 'banner_images');
      Reference referenceImagetoUpload = referenceDirImages.child(fileName);

      try {
        await referenceImagetoUpload.putData(
            fileData, SettableMetadata(contentType: mimeType));
        String downloadUrl = await referenceImagetoUpload.getDownloadURL();

        setState(() {
          if (imageType == 'profile') {
            profileUrl = downloadUrl;
          } else {
            coverUrl = downloadUrl;
          }
        });
      } catch (e) {
        print("Error uploading image: $e");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: const Text("Error uploading image. Please try again."),
        ));
      }
    } else {
      print("No file selected.");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No file selected."),
      ));
    }
  }

  Future<void> _addFriend() async {
    if (_idNumController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _majorController.text.isEmpty ||
        currentLocation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fill in all fields."),
      ));
      return;
    }

    await _addFriendToFirestore();
  }

  Future<void> _addFriendToFirestore() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference friendsCollection = firestore.collection('friends');

    FriendModel newFriend = FriendModel(
      id: '',
      idNum: _idNumController.text,
      name: _nameController.text,
      description: _descriptionController.text,
      major: _majorController.text,
      profileUrl: profileUrl.isNotEmpty ? profileUrl : defaultProfileImageUrl,
      bannerUrl: coverUrl.isNotEmpty ? coverUrl : defaultCoverImageUrl,
      createdTime: DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        currentTime.hour,
        currentTime.minute,
      ),
      updatedTime: DateTime.now(),
      location: currentLocation,
    );

    await friendsCollection.add(newFriend.toMap());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Data added successfully."),
    ));
    setState(() {
      _idNumController.clear();
      _nameController.clear();
      _descriptionController.clear();
      _majorController.clear();
      profileUrl = '';
      coverUrl = '';
      currentDate = DateTime.now();
      currentTime = TimeOfDay.now();
      currentLocation = '';
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Friends()),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
    );
  }

  Widget _buildImageButton(String buttonText, String imageType) {
    return ElevatedButton(
      onPressed: () => _uploadImage(imageType),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.file_upload),
          const SizedBox(width: 8),
          Text(buttonText),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Image.network(
        imageUrl,
        height: 100,
        width: 100,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildDateAndTimePickers() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: currentDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (selectedDate != null) {
              setState(() {
                currentDate = selectedDate;
              });
            }
          },
          child: Text(
              'Select Date: ${currentDate.year}-${currentDate.month}-${currentDate.day}'),
        ),
        ElevatedButton(
          onPressed: () async {
            final selectedTime = await showTimePicker(
              context: context,
              initialTime: currentTime,
            );
            if (selectedTime != null) {
              setState(() {
                currentTime = selectedTime;
              });
            }
          },
          child: Text('Select Time: ${currentTime.hour}:${currentTime.minute}'),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      onChanged: (value) {
        setState(() {
          currentLocation = value;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Location',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friend'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(_idNumController, 'ID Number'),
            _buildTextField(_nameController, 'Name'),
            _buildTextField(_descriptionController, 'Description'),
            _buildTextField(_majorController, 'Major'),
            const SizedBox(height: 20),
            _buildImageButton('Select Profile Image', 'profile'),
            if (profileUrl.isNotEmpty) _buildImagePreview(profileUrl),
            const SizedBox(height: 20),
            _buildImageButton('Select Cover Image', 'banner'),
            if (coverUrl.isNotEmpty) _buildImagePreview(coverUrl),
            const SizedBox(height: 20),
            _buildDateAndTimePickers(),
            _buildLocationField(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addFriend,
              child: const Text('Add Friend'),
            ),
          ],
        ),
      ),
    );
  }
}
