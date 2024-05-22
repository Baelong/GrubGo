import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'address_search_screen.dart';
import 'address_model.dart';

class AddressesScreen extends StatefulWidget {
  final bool isSelecting;

  AddressesScreen({this.isSelecting = false});

  @override
  _AddressesScreenState createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addAddress(String address) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('addresses').add({
        'address': address,
      });
    }
  }

  Future<void> _deleteAddress(String docId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('addresses').doc(docId).delete();
    }
  }

  void _searchAddress() async {
    final selectedAddress = await showSearch<String?>(
      context: context,
      delegate: AddressSearch(),
    );

    if (selectedAddress != null) {
      setState(() {
        _addAddress(selectedAddress);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Color(0xFFE1E1E1),
      appBar: AppBar(
        backgroundColor: Color(0xFF001F3F),
        title: Text('Addresses', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: user == null
          ? Center(child: Text('Please log in to manage addresses'))
          : StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').doc(user.uid).collection('addresses').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final addresses = snapshot.data!.docs;
          return ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final addressData = addresses[index];
              final address = Address.fromFirestore(addressData.data() as Map<String, dynamic>, addressData.id);
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 2.0,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  title: Text(
                    address.address,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteAddress(address.id),
                  ),
                  onTap: widget.isSelecting
                      ? () {
                    Navigator.pop(context, address);
                  }
                      : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _searchAddress,
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF001F3F),
      ),
    );
  }
}
