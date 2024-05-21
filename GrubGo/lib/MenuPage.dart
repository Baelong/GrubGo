import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuPage extends StatelessWidget {
  final String restaurantId;
  final String restaurantName;

  MenuPage({required this.restaurantId, required this.restaurantName});

  @override
  Widget build(BuildContext context) {
    final CollectionReference menuItems = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(restaurantId)
        .collection('menu_items');

    return Scaffold(
      appBar: AppBar(
        title: Text(restaurantName),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: menuItems.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final menuItems = snapshot.data!.docs;
          return ListView.builder(
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final menuItem = menuItems[index];
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(menuItem['image_url']),
                      ),
                    ),
                  ),
                  title: Text(menuItem['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menuItem['description'],
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '\$${menuItem['price']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blue, // Adjust the color to make it more visible
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: () {
                      //functionality after
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
