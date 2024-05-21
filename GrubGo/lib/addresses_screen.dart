import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'address_search_screen.dart';

class AddressesScreen extends StatefulWidget {
  @override
  _AddressesScreenState createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: "AIzaSyC60Ado0xtCvhht-Bk_UA6kBnFf8lnFtgE");

  void _addAddress() async {
    Prediction? prediction = await PlacesAutocomplete.show(
      context: context,
      apiKey: "AIzaSyC60Ado0xtCvhht-Bk_UA6kBnFf8lnFtgE",
      mode: Mode.overlay,
      language: "en",
      components: [Component(Component.country, "us"), Component(Component.country, "ca")],
    );

    if (prediction != null) {
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(prediction.placeId!);
      String address = detail.result.formattedAddress!;
      setState(() {
        _saveAddress(address);
      });
    }
  }

  Future<void> _saveAddress(String address) async {
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

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Color(0xFFE1E1E1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Addresses', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
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
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              final address = addresses[index];
              return ListTile(
                title: Text(address['address']),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteAddress(address.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAddress,
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
    );
  }
}
