import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'payment_model.dart';
import 'payment_options_screen.dart';
import 'address_model.dart';
import 'addresses_screen.dart';

class CheckoutPage extends StatefulWidget {
  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Address? selectedAddress;
  Payment? selectedPaymentMethod;
  double subtotal = 0.0;
  double taxes = 0.0;
  double deliveryFee = 3.0;
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotal();
  }

  Stream<QuerySnapshot> _getCartItemsStream() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('users').doc(user.uid).collection('cart').snapshots();
    } else {
      return Stream.empty();
    }
  }

  void _selectAddress() async {
    final address = await Navigator.push<Address>(
      context,
      MaterialPageRoute(builder: (context) => AddressesScreen(isSelecting: true)),
    );

    if (address != null) {
      setState(() {
        selectedAddress = address;
      });
    }
  }

  void _selectPaymentMethod() async {
    final payment = await Navigator.push<Payment>(
      context,
      MaterialPageRoute(builder: (context) => PaymentOptionsScreen(isSelecting: true)),
    );

    if (payment != null) {
      setState(() {
        selectedPaymentMethod = payment;
      });
    }
  }

  void _calculateTotal() {
    _getCartItemsStream().listen((snapshot) {
      double newSubtotal = snapshot.docs.fold(0.0, (sum, item) {
        final data = item.data() as Map<String, dynamic>;
        final itemPrice = (data['totalPrice'] ?? 0.0) as double;
        return sum + itemPrice;
      });

      setState(() {
        subtotal = newSubtotal;
        taxes = subtotal * 0.15;
        total = subtotal + taxes + deliveryFee;
      });
    });
  }

  void _placeOrder() async {
    User? user = _auth.currentUser;
    if (user != null && selectedAddress != null && selectedPaymentMethod != null) {
      final cartSnapshot = await _getCartItemsStream().first;

      final orderData = {
        'address': selectedAddress!.toFirestore(),
        'paymentMethod': selectedPaymentMethod!.toFirestore(),
        'orderDate': FieldValue.serverTimestamp(),
        'subtotal': subtotal,
        'taxes': taxes,
        'deliveryFee': deliveryFee,
        'total': total,
        'items': cartSnapshot.docs.map((doc) => doc.data()).toList(),
      };

      await _firestore.collection('users').doc(user.uid).collection('orders').add(orderData);

      for (var doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }

      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/cart');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE1E1E1),
      appBar: AppBar(
        backgroundColor: Color(0xFF001F3F), // Dark navy blue
        title: Text('Checkout', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Text(
            'Select Address',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          ListTile(
            title: Text(
              selectedAddress != null
                  ? selectedAddress!.address
                  : 'No address selected',
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: _selectAddress,
            ),
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
            'Payment Method',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          ListTile(
            title: Text(
              selectedPaymentMethod != null
                  ? '**** **** **** ${selectedPaymentMethod!.cardNumber.substring(selectedPaymentMethod!.cardNumber.length - 4)}'
                  : 'No payment method selected',
            ),
            subtitle: Text(
              selectedPaymentMethod != null
                  ? selectedPaymentMethod!.cardHolderName
                  : 'Please select a payment method',
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: _selectPaymentMethod,
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: _placeOrder,
              child: Text('Place Order'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                textStyle: TextStyle(fontSize: 18),
                primary: Color(0xFF001F3F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
