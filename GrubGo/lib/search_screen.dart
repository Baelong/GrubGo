import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mcdonalds_menu.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];

  void _searchRestaurants(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    final results = await _firestore
        .collection('restaurants')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    setState(() {
      _searchResults = results.docs;
    });
  }

  void _goToMenuScreen(Map<String, dynamic> restaurant) {
    if (restaurant['name'] == 'McDonalds') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => McDonaldsMenuPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE1E1E1), // Setting background color
      appBar: AppBar(
        backgroundColor: Color(0xFF001F3F),  // Dark navy blue color
        title: Text('Search Restaurants', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for restaurants',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                _searchRestaurants(query);
              },
            ),
            SizedBox(height: 10), // Adding some spacing
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final restaurant = _searchResults[index].data() as Map<String, dynamic>;
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          restaurant['image_url'] ?? 'https://via.placeholder.com/50',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(restaurant['name'] ?? 'No name'),
                      onTap: () => _goToMenuScreen(restaurant),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
