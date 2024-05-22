import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'mcdonalds_menu.dart';
import 'CheckoutPage.dart';

class ViewCartPage extends StatefulWidget {
  @override
  _ViewCartPageState createState() => _ViewCartPageState();
}

class _ViewCartPageState extends State<ViewCartPage> {
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

  Future<void> _removeItemFromCart(String itemId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('cart').doc(itemId).delete();
    }
  }

  Future<void> _updateItemQuantity(String itemId, int quantity, double basePrice) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference<Map<String, dynamic>> docRef = _firestore.collection('users').doc(user.uid).collection('cart').doc(itemId);
      double newItemTotalPrice = basePrice * quantity;
      await docRef.update({'quantity': quantity, 'totalPrice': newItemTotalPrice});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE1E1E1),
      appBar: AppBar(
        backgroundColor: Color(0xFF001F3F), // Dark navy blue
        title: Text('Cart Details', style: TextStyle(color: Colors.white)),
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
          double subtotal = cartItems.fold(0.0, (sum, item) {
            final data = item.data() as Map<String, dynamic>;
            return sum + (data['totalPrice'] ?? 0.0);
          });

          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              ...cartItems.map((item) {
                final data = item.data() as Map<String, dynamic>;
                final quantity = data['quantity']?.toDouble() ?? 1.0;
                final basePrice = (data['basePrice'] ?? 0.0).toDouble();

                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    leading: Image.network(
                      data.containsKey('imageUrl') ? data['imageUrl'] : 'https://via.placeholder.com/50',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(data.containsKey('name') ? data['name'] : 'Unknown Item'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data.containsKey('selectedSide') && data['selectedSide'].isNotEmpty)
                          Text('Side: ${data['selectedSide']} (${data['selectedSideSize']})'),
                        if (data.containsKey('selectedDrink') && data['selectedDrink'].isNotEmpty)
                          Text('Drink: ${data['selectedDrink']} (${data['selectedDrinkSize']})'),
                        Text('Total: \$${(data.containsKey('totalPrice') ? data['totalPrice'] : 0.0).toStringAsFixed(2)}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(quantity > 1 ? Icons.remove : Icons.delete),
                          onPressed: () {
                            if (quantity > 1) {
                              _updateItemQuantity(item.id, quantity.toInt() - 1, basePrice);
                            } else {
                              _removeItemFromCart(item.id);
                            }
                          },
                        ),
                        Text('$quantity'),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            _updateItemQuantity(item.id, quantity.toInt() + 1, basePrice);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => McDonaldsMenuPage()),
                  );
                },
                child: Text('+ Add Items', style: TextStyle(color: Colors.black),),
              ),
              Text(
                'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(),
                      ),
                    );
                  },
                  child: Text('Go to Checkout'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                    textStyle: TextStyle(fontSize: 18),
                    primary: Color(0xFF001F3F),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
