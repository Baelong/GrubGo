import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItemDetailsPage extends StatefulWidget {
  final String restaurantId;
  final String itemId;

  ItemDetailsPage({required this.restaurantId, required this.itemId});

  @override
  _ItemDetailsPageState createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DocumentSnapshot itemSnapshot;
  late DocumentSnapshot restaurantSnapshot;
  bool isLoading = true;
  String selectedSideSize = "";
  String selectedDrinkSize = "";
  String selectedSide = "";
  String selectedDrink = "";
  String selectedSize = "";
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _loadItemDetails();
  }

  Future<void> _loadItemDetails() async {
    DocumentSnapshot itemSnapshot = await _firestore
        .collection('restaurants')
        .doc(widget.restaurantId)
        .collection('menu_items')
        .doc(widget.itemId)
        .get();

    DocumentSnapshot restaurantSnapshot = await _firestore
        .collection('restaurants')
        .doc(widget.restaurantId)
        .get();

    setState(() {
      this.itemSnapshot = itemSnapshot;
      this.restaurantSnapshot = restaurantSnapshot;
      totalPrice = double.parse(itemSnapshot['base_price'].toString());
      isLoading = false;
    });
  }

  void _updateTotalPrice() {
    double basePrice = double.parse(itemSnapshot['base_price'].toString());
    double sidePrice = 0.0;
    double drinkPrice = 0.0;
    double sizePrice = 0.0;

    if (selectedSide.isNotEmpty) {
      var selectedSideData = (itemSnapshot['sides'] as List).firstWhere((side) => side['side'] == selectedSide);
      var selectedSideSizeData = (selectedSideData['sizes'] as List).firstWhere((size) => size['size'] == selectedSideSize);
      sidePrice = double.parse(selectedSideSizeData['price_adjustment'].toString());
    }

    if (selectedDrink.isNotEmpty) {
      var selectedDrinkData = (itemSnapshot['drinks'] as List).firstWhere((drink) => drink['drink'] == selectedDrink);
      var selectedDrinkSizeData = (selectedDrinkData['sizes'] as List).firstWhere((size) => size['size'] == selectedDrinkSize);
      drinkPrice = double.parse(selectedDrinkSizeData['price_adjustment'].toString());
    }

    if (selectedSize.isNotEmpty) {
      var selectedSizeData = (itemSnapshot['sizes'] as List).firstWhere((size) => size['size'] == selectedSize);
      sizePrice = double.parse(selectedSizeData['price_adjustment'].toString());
    }

    setState(() {
      totalPrice = basePrice + sidePrice + drinkPrice + sizePrice;
    });
  }

  Future<void> _addToCart() async {
    User? user = _auth.currentUser;
    if (user != null) {
      var cartItemQuery = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .where('restaurantId', isEqualTo: widget.restaurantId)
          .where('name', isEqualTo: itemSnapshot['name'])
          .where('selectedSide', isEqualTo: selectedSide)
          .where('selectedSideSize', isEqualTo: selectedSideSize)
          .where('selectedDrink', isEqualTo: selectedDrink)
          .where('selectedDrinkSize', isEqualTo: selectedDrinkSize)
          .where('selectedSize', isEqualTo: selectedSize);

      var cartItemSnapshot = await cartItemQuery.get();

      if (cartItemSnapshot.docs.isNotEmpty) {
        var cartItemDoc = cartItemSnapshot.docs.first;
        var newQuantity = cartItemDoc['quantity'] + 1;
        var newTotalPrice = cartItemDoc['totalPrice'] + totalPrice;

        await cartItemDoc.reference.update({
          'quantity': newQuantity,
          'totalPrice': newTotalPrice,
        });
      } else {
        await _firestore.collection('users').doc(user.uid).collection('cart').add({
          'restaurantId': widget.restaurantId,
          'restaurantName': restaurantSnapshot['name'],
          'name': itemSnapshot['name'],
          'imageUrl': itemSnapshot['image_url'],
          'basePrice': itemSnapshot['base_price'],
          'selectedSide': selectedSide,
          'selectedSideSize': selectedSideSize,
          'selectedDrink': selectedDrink,
          'selectedDrinkSize': selectedDrinkSize,
          'selectedSize': selectedSize,
          'quantity': 1,
          'totalPrice': totalPrice,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF001F3F),
          title: Text('Item Details', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    var itemData = itemSnapshot.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF001F3F),
        title: Text(itemData['name'], style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              itemData['image_url'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16),
            Text(
              itemData['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Base Price: \$${itemData['base_price'].toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18),
            ),
            if (itemData['type'] == 'Trio') ...[
              SizedBox(height: 16),
              Text(
                'Select Side',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: selectedSide.isEmpty ? null : selectedSide,
                hint: Text('Select a side'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSide = newValue!;
                    selectedSideSize = "";
                  });
                  _updateTotalPrice();
                },
                items: (itemData['sides'] as List).map<DropdownMenuItem<String>>((side) {
                  return DropdownMenuItem<String>(
                    value: side['side'],
                    child: Text(side['side']),
                  );
                }).toList(),
              ),
              if (selectedSide.isNotEmpty)
                DropdownButton<String>(
                  value: selectedSideSize.isEmpty ? null : selectedSideSize,
                  hint: Text('Select a side size'),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSideSize = newValue!;
                    });
                    _updateTotalPrice();
                  },
                  items: (itemData['sides'] as List)
                      .firstWhere((side) => side['side'] == selectedSide)['sizes']
                      .map<DropdownMenuItem<String>>((size) {
                    final priceAdjustment = double.parse(size['price_adjustment'].toString());
                    final priceText = priceAdjustment == 0
                        ? ''
                        : (priceAdjustment > 0 ? '+\$${priceAdjustment.toStringAsFixed(2)}' : '-\$${(-priceAdjustment).toStringAsFixed(2)}');
                    return DropdownMenuItem<String>(
                      value: size['size'],
                      child: Text('${size['size']} $priceText'),
                    );
                  }).toList(),
                ),
              SizedBox(height: 16),
              Text(
                'Select Drink',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: selectedDrink.isEmpty ? null : selectedDrink,
                hint: Text('Select a drink'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDrink = newValue!;
                    selectedDrinkSize = "";
                  });
                  _updateTotalPrice();
                },
                items: (itemData['drinks'] as List).map<DropdownMenuItem<String>>((drink) {
                  return DropdownMenuItem<String>(
                    value: drink['drink'],
                    child: Text(drink['drink']),
                  );
                }).toList(),
              ),
              if (selectedDrink.isNotEmpty)
                DropdownButton<String>(
                  value: selectedDrinkSize.isEmpty ? null : selectedDrinkSize,
                  hint: Text('Select a drink size'),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDrinkSize = newValue!;
                    });
                    _updateTotalPrice();
                  },
                  items: (itemData['drinks'] as List)
                      .firstWhere((drink) => drink['drink'] == selectedDrink)['sizes']
                      .map<DropdownMenuItem<String>>((size) {
                    final priceAdjustment = double.parse(size['price_adjustment'].toString());
                    final priceText = priceAdjustment == 0
                        ? ''
                        : (priceAdjustment > 0 ? '+\$${priceAdjustment.toStringAsFixed(2)}' : '-\$${(-priceAdjustment).toStringAsFixed(2)}');
                    return DropdownMenuItem<String>(
                      value: size['size'],
                      child: Text('${size['size']} $priceText'),
                    );
                  }).toList(),
                ),
            ],
            if (itemData['type'] == 'Solo' && itemData.containsKey('sizes')) ...[
              SizedBox(height: 16),
              Text(
                'Select Size',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: selectedSize.isEmpty ? null : selectedSize,
                hint: Text('Select a size'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSize = newValue!;
                  });
                  _updateTotalPrice();
                },
                items: (itemData['sizes'] as List).map<DropdownMenuItem<String>>((size) {
                  final priceAdjustment = double.parse(size['price_adjustment'].toString());
                  final priceText = priceAdjustment == 0
                      ? ''
                      : (priceAdjustment > 0 ? '+\$${priceAdjustment.toStringAsFixed(2)}' : '-\$${(-priceAdjustment).toStringAsFixed(2)}');
                  return DropdownMenuItem<String>(
                    value: size['size'],
                    child: Text('${size['size']} $priceText'),
                  );
                }).toList(),
              ),
            ],
            Spacer(),
            Text(
              'Total Price: \$${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Center( // Center the button
              child: ElevatedButton(
                onPressed: () {
                  _addToCart();
                  Navigator.pop(context);
                },
                child: Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF001F3F),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 50),
                  textStyle: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
