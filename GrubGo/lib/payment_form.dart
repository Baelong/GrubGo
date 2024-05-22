import 'package:flutter/material.dart';
import 'payment_model.dart';

class PaymentForm extends StatefulWidget {
  final Payment? payment;

  PaymentForm({this.payment});

  @override
  _PaymentFormState createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _cardHolderNameController;
  late TextEditingController _cardNumberController;
  late TextEditingController _expiryDateController;
  late TextEditingController _cvvController;

  @override
  void initState() {
    super.initState();
    _cardHolderNameController = TextEditingController(text: widget.payment?.cardHolderName ?? '');
    _cardNumberController = TextEditingController(text: widget.payment?.cardNumber ?? '');
    _expiryDateController = TextEditingController(text: widget.payment?.expiryDate ?? '');
    _cvvController = TextEditingController(text: widget.payment?.cvv ?? '');
  }

  @override
  void dispose() {
    _cardHolderNameController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final payment = Payment(
        id: widget.payment?.id ?? '',
        cardHolderName: _cardHolderNameController.text,
        cardNumber: _cardNumberController.text,
        expiryDate: _expiryDateController.text,
        cvv: _cvvController.text,
      );
      Navigator.of(context).pop(payment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE1E1E1),
      appBar: AppBar(
        backgroundColor: Color(0xFF001F3F),
        title: Text('Add/Edit Payment', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Card Holder Name', _cardHolderNameController),
              _buildTextField('Card Number', _cardNumberController, TextInputType.number),
              _buildTextField('Expiry Date (MM/YY)', _expiryDateController),
              _buildTextField('CVV', _cvvController, TextInputType.number),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF001F3F),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller, [TextInputType keyboardType = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $labelText';
          }
          return null;
        },
      ),
    );
  }
}
