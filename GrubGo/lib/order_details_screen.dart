import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  OrderDetailsScreen({required this.orderId, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final items = orderData['items'] as List<dynamic>;
    final address = orderData['address']['address'];
    final cardNumber = orderData['paymentMethod']['cardNumber'] as String;
    final lastFourDigits = cardNumber.substring(cardNumber.length - 4);
    final subtotal = orderData['subtotal'];
    final taxes = orderData['taxes'];
    final deliveryFee = orderData['deliveryFee'];
    final total = orderData['total'];
    final Timestamp orderTimestamp = orderData['orderDate'];
    final DateTime orderDate = orderTimestamp.toDate();
    final String formattedDate = DateFormat.yMMMd().format(orderDate);

    return Scaffold(
      backgroundColor: Color(0xFFE1E1E1),
      appBar: AppBar(
        backgroundColor: Color(0xFF001F3F),
        title: Text('Order Details', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: $orderId', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Date: $formattedDate', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Total: \$${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text('Items:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...items.map((item) {
              final itemData = item as Map<String, dynamic>;
              return ListTile(
                title: Text(itemData['name']),
                subtitle: Text('Quantity: ${itemData['quantity']} • Total: \$${(itemData['totalPrice'] ?? 0.0).toStringAsFixed(2)}'),
              );
            }).toList(),
            Divider(),
            ListTile(
              title: Text('Address'),
              subtitle: Text(address),
            ),
            ListTile(
              title: Text('Payment Method'),
              subtitle: Text('**** **** **** $lastFourDigits'),
            ),
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
            ListTile(
              title: Text('Total'),
              trailing: Text('\$${total.toStringAsFixed(2)}'),
            ),
          ],
        ),
      ),
    );
  }
}
