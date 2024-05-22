import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'item_details_page.dart';

class McDonaldsMenuPage extends StatefulWidget {
  @override
  _McDonaldsMenuPageState createState() => _McDonaldsMenuPageState();
}

class _McDonaldsMenuPageState extends State<McDonaldsMenuPage> {
  final String restaurantId = "KNkZ17Od5ubJFuzS8d1x";
  String searchQuery = '';
  String selectedCategory = 'All';

  Stream<QuerySnapshot> _getMenuItemsStream() {
    if (selectedCategory == 'All') {
      return FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu_items')
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('menu_items')
          .where('category', isEqualTo: selectedCategory)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.white),
            ),
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          ),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                switch (index) {
                  case 0:
                    selectedCategory = 'All';
                    break;
                  case 1:
                    selectedCategory = 'Trio';
                    break;
                  case 2:
                    selectedCategory = 'Burgers';
                    break;
                  case 3:
                    selectedCategory = 'Sides';
                    break;
                  case 4:
                    selectedCategory = 'Beverages';
                    break;
                }
              });
            },
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Trio'),
              Tab(text: 'Burgers'),
              Tab(text: 'Sides'),
              Tab(text: 'Beverages'),
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _getMenuItemsStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print('Error: ${snapshot.error}');
              return Center(child: Text('Something went wrong: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              print('No menu items available');
              return Center(child: Text('No menu items available'));
            }

            var menuItems = snapshot.data!.docs;
            if (searchQuery.isNotEmpty) {
              menuItems = menuItems.where((item) {
                var data = item.data() as Map<String, dynamic>;
                return data['name'].toLowerCase().contains(searchQuery.toLowerCase());
              }).toList();
            }

            return ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final menuItem = menuItems[index];
                final imageUrl = menuItem.get('image_url');
                final basePrice = menuItem.get('base_price');
                final name = menuItem.get('name');

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailsPage(
                              restaurantId: restaurantId,
                              itemId: menuItem.id,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '\$${basePrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(15.0),
                                bottomRight: Radius.circular(15.0),
                              ),
                              child: Image.network(
                                imageUrl,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.network(
                                    'https://via.placeholder.com/100',
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
