import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedAddressId = '';
  String selectedPaymentMethodId = '';

  Stream<QuerySnapshot> _getAddressesStream() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('users').doc(user.uid).collection('addresses').snapshots();
    } else {
      return Stream.empty();
    }
  }

  Stream<QuerySnapshot> _getPaymentMethodsStream() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('users').doc(user.uid).collection('payment_methods').snapshots();
    } else {
      return Stream.empty();
    }
  }

  Stream<QuerySnapshot> _getCartItemsStream() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('users').doc(user.uid).collection('cart').snapshots();
    } else {
      return Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Text(
            'Select Address',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _getAddressesStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Something went wrong: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No saved addresses. Add a new address.'));
              }

              final addresses = snapshot.data!.docs;
              return Column(
                children: [
                  ...addresses.map((address) {
                    final data = address.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['address']),
                      leading: Radio<String>(
                        value: address.id,
                        groupValue: selectedAddressId,
                        onChanged: (String? value) {
                          setState(() {
                            selectedAddressId = value!;
                          });
                        },
                      ),
                    );
                  }).toList(),
                  ListTile(
                    leading: Icon(Icons.add),
                    title: Text('Add New Address'),
                    onTap: () {
                      // Navigate to add new address page
                    },
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 16),
          Text(
            'Order Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          StreamBuilder<QuerySnapshot>(
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

              double taxes = subtotal * 0.1; // Assuming 10% tax rate
              double deliveryFee = 5.0; // Assuming a flat delivery fee

              double total = subtotal + taxes + deliveryFee;

              return Column(
                children: [
                  ...cartItems.map((item) {
                    final data = item.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['name']),
                      subtitle: Text('Quantity: ${data['quantity']} • Total: \$${(data['totalPrice'] ?? 0.0).toStringAsFixed(2)}'),
                    );
                  }).toList(),
                  Divider(),
                  ListTile(
                    title: Text('Subtotal'),
                    trailing: Text('\$${subtotal.toStringAsFixed(2)}'),
                  ),
                  ListTile(
                    title: Text('Taxes'),
                    trailing: Text('\$${taxes.toStringAsFixed(2)}'),
                  ),
                  ListTile(
                    title: Text('Delivery Fee'),
                    trailing: Text('\$${deliveryFee.toStringAsFixed(2)}'),
                  ),
                  Divider(),
                  ListTile(
                    title: Text(
                      'Total',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 16),
          Text(
            'Select Payment Method',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _getPaymentMethodsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Something went wrong: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No saved payment methods. Add a new one.'));
              }

              final paymentMethods = snapshot.data!.docs;
              return Column(
                children: [
                  ...paymentMethods.map((method) {
                    final data = method.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['cardNumber']),
                      subtitle: Text(data['cardHolder']),
                      leading: Radio<String>(
                        value: method.id,
                        groupValue: selectedPaymentMethodId,
                        onChanged: (String? value) {
                          setState(() {
                            selectedPaymentMethodId = value!;
                          });
                        },
                      ),
                    );
                  }).toList(),
                  ListTile(
                    leading: Icon(Icons.add),
                    title: Text('Add New Payment Method'),
                    onTap: () {
                      // Navigate to add new payment method page
                    },
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Handle order placement
            },
            child: Text('Place Order'),
          ),
        ],
      ),
    );
  }
}
