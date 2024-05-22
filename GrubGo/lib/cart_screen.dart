import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'view_cart_page.dart';
import 'mcdonalds_menu.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> _getCartItemsStream() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('users').doc(user.uid).collection('cart').snapshots();
    } else {
      return Stream.empty();
    }
  }

  Future<DocumentSnapshot> _getRestaurantDetails(String restaurantId) {
    return _firestore.collection('restaurants').doc(restaurantId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getCartItemsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Your cart is empty'));
          }

          final cartItems = snapshot.data!.docs;
          final subtotal = cartItems.fold(0.0, (sum, item) => sum + (item['totalPrice'] ?? 0.0));
          final restaurantId = cartItems.first['restaurantId'];

          return FutureBuilder<DocumentSnapshot>(
            future: _getRestaurantDetails(restaurantId),
            builder: (context, restaurantSnapshot) {
              if (restaurantSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (restaurantSnapshot.hasError) {
                return Center(child: Text('Something went wrong: ${restaurantSnapshot.error}'));
              }
              if (!restaurantSnapshot.hasData || !restaurantSnapshot.data!.exists) {
                return Center(child: Text('Restaurant not found'));
              }

              final restaurantData = restaurantSnapshot.data!.data() as Map<String, dynamic>;

              return ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Image.network(
                            restaurantData['image_url'] ?? 'https://via.placeholder.com/50',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(restaurantData['name'] ?? 'Unknown Restaurant'),
                          subtitle: Text('${cartItems.length} item(s) • \$${subtotal.toStringAsFixed(2)}'),
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => McDonaldsMenuPage(),
                                  ),
                                );
                              },
                              child: Text('View store'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewCartPage(),
                                  ),
                                );
                              },
                              child: Text('View cart'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
