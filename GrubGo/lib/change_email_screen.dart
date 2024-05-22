import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangeEmailScreen extends StatefulWidget {
  @override
  _ChangeEmailScreenState createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();

  void _changeEmail() async {
    if (_newEmailController.text != _confirmEmailController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email addresses do not match')));
      return;
    }
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );

        await user.reauthenticateWithCredential(credential);

        await user.verifyBeforeUpdateEmail(_newEmailController.text);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('A verification link has been sent to the new email address. Please verify before changing the email.')));

        FirebaseAuth.instance.userChanges().listen((user) async {
          if (user != null && user.email == _newEmailController.text && user.emailVerified) {
            await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
              'email': _newEmailController.text,
            });

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email updated successfully')));
            Navigator.of(context).pop();
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE1E1E1),
      appBar: AppBar(
        backgroundColor: Color(0xFF001F3F),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Change Email', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildTextField('Current Password', _currentPasswordController, obscureText: true),
              _buildTextField('New Email', _newEmailController),
              _buildTextField('Confirm New Email', _confirmEmailController),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _changeEmail,
                child: Text('Change Email'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF001F3F),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
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
          border: OutlineInputBorder(),
        ),
        obscureText: obscureText,
      ),
    );
  }
}
