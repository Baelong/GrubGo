import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'payment_model.dart';
import 'payment_form.dart';

class PaymentOptionsScreen extends StatefulWidget {
  final bool isSelecting;

  PaymentOptionsScreen({this.isSelecting = false});

  @override
  _PaymentOptionsScreenState createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addPayment(Payment payment) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('payments').add(payment.toFirestore());
    }
  }

  Future<void> _updatePayment(Payment payment) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('payments').doc(payment.id).update(payment.toFirestore());
    }
  }

  Future<void> _deletePayment(String id) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('payments').doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Color(0xFFE1E1E1),
      appBar: AppBar(
        backgroundColor: Color(0xFF001F3F),
        title: Text('Payment Options', style: TextStyle(color: Colors.white)),
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
          ? Center(child: Text('Please log in to manage payment options'))
          : StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').doc(user.uid).collection('payments').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final payments = snapshot.data!.docs.map((doc) {
            return Payment.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: ListTile(
                  title: Text(payment.cardHolderName),
                  subtitle: Text('**** **** **** ${payment.cardNumber.substring(payment.cardNumber.length - 4)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.black),
                        onPressed: () async {
                          final updatedPayment = await Navigator.of(context).push<Payment>(
                            MaterialPageRoute(builder: (context) => PaymentForm(payment: payment)),
                          );
                          if (updatedPayment != null) {
                            await _updatePayment(updatedPayment);
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _deletePayment(payment.id);
                        },
                      ),
                    ],
                  ),
                  onTap: widget.isSelecting
                      ? () {
                    Navigator.pop(context, payment);
                  }
                      : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newPayment = await Navigator.of(context).push<Payment>(
            MaterialPageRoute(builder: (context) => PaymentForm()),
          );
          if (newPayment != null) {
            await _addPayment(newPayment);
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF001F3F),
      ),
    );
  }
}
