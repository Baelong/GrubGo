import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginPage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  String? firstName;
  String? lastName;
  String? birthday;
  File? _profileImage;
  String? profileImageUrl;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    if (user != null) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot userData = await _firestore.collection('users').doc(user!.uid).get();
    setState(() {
      firstName = userData['firstName'];
      lastName = userData['lastName'];
      birthday = userData['birthday'];
      profileImageUrl = userData['profileImageUrl'];
      _firstNameController.text = firstName!;
      _lastNameController.text = lastName!;
      _birthdayController.text = birthday!;
    });
  }

  Future<void> _updateProfile() async {
    try {
      if (user != null) {
        String? newProfileImageUrl = profileImageUrl;
        if (_profileImage != null) {
          newProfileImageUrl = await _uploadProfileImage(_profileImage!);
        }
        await _firestore.collection('users').doc(user!.uid).update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'birthday': _birthdayController.text,
          'profileImageUrl': newProfileImageUrl,
        });
        await user!.updateProfile(
          displayName: '${_firstNameController.text} ${_lastNameController.text}',
          photoURL: newProfileImageUrl,
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    }
  }

  Future<String?> _uploadProfileImage(File image) async {
    // Implement the method to upload the profile image to your storage and return the URL
    return null;
  }

  Future<void> _deleteAccount() async {
    try {
      await _firestore.collection('users').doc(user!.uid).delete();
      await user!.delete();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    }
  }

  Future<void> _changeProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _profileImage = File(pickedFile.path);
      }
    });
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE1E1E1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Edit Profile', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _changeProfilePicture,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (profileImageUrl != null
                          ? NetworkImage(profileImageUrl!)
                          : AssetImage('assets/pfp.jpg')) as ImageProvider,
                      child: _profileImage == null ? Icon(Icons.camera_alt, color: Colors.white, size: 30) : null,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${firstName ?? ''} ${lastName ?? ''}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            _buildTextField('First Name', _firstNameController),
            _buildTextField('Last Name', _lastNameController),
            GestureDetector(
              onTap: () => _selectBirthday(context),
              child: AbsorbPointer(
                child: _buildTextField('Birthday', _birthdayController),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Update Profile'),
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _deleteAccount,
              child: Text('Delete Account'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        obscureText: obscureText,
      ),
    );
  }
}
