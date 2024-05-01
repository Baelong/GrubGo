import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Color(0xFF273337),
      ),
      body: Center(
        child: Text('Welcome to the Home Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
