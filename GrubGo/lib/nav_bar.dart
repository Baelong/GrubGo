import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:badges/badges.dart' as badges;
import 'home_screen.dart';
import 'search_screen.dart';
import 'cart_screen.dart';
import 'settings_screen.dart';

class NavBar extends StatefulWidget {
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _updateCartCount();
  }

  void _updateCartCount() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .snapshots()
          .listen((snapshot) {
        setState(() {
          _cartCount = snapshot.docs.isEmpty ? 0 : 1; // Update count based on unique restaurant orders
        });
      });
    }
  }

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SearchScreen(),
    CartScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: badges.Badge(
              showBadge: _cartCount > 0,
              badgeContent: Text(
                '$_cartCount',
                style: TextStyle(color: Colors.white),
              ),
              child: Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: _selectedItemColor(),
        unselectedItemColor: _unselectedItemColor(),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Color _selectedItemColor() {
    switch (_selectedIndex) {
      case 0:
        return Colors.blue; // Home
      case 1:
        return Colors.green; // Search
      case 2:
        return Colors.red; // Cart
      case 3:
        return Colors.grey; // Settings
      default:
        return Colors.amber[800]!;
    }
  }

  Color _unselectedItemColor() {
    return Colors.black54;
  }
}
