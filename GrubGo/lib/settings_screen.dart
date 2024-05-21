import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grubgo/addresses_screen.dart';
import 'package:grubgo/country_selection_screen.dart';
import 'LoginPage.dart';
import 'profile_screen.dart';
import 'change_password_screen.dart';
import 'change_email_screen.dart';
import 'payment_options_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final String profilePictureUrl = 'assets/pfp.jpg';
  User? user = FirebaseAuth.instance.currentUser;

  Stream<DocumentSnapshot> _userStream() {
    return FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots();
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE1E1E1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Settings', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No user data found'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: <Widget>[
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(profilePictureUrl),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${userData['firstName']} ${userData['lastName']}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        userData['email'] ?? 'user@example.com',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                _buildSectionTitle('Account'),
                _buildSettingsButton(context, 'Profile', Icons.edit, _navigateToProfile),
                _buildSettingsButton(context, 'Change Email', Icons.email, _navigateToChangeEmail),
                _buildSettingsButton(context, 'Change Password', Icons.lock, _navigateToChangePassword),
                _buildSettingsButton(context, 'Addresses', Icons.location_on, _navigateToAddresses),
                _buildSettingsButton(context, 'Payment Options', Icons.payment, _navigateToPaymentOptions),
                _buildSettingsButton(context, 'Order History', Icons.history, _navigateToOrderHistory),
                _buildSettingsButton(context, 'Country', Icons.flag, _navigateToCountry),
                SizedBox(height: 20),
                _buildSectionTitle('General'),
                _buildSettingsButton(context, 'Support', Icons.support, _navigateToSupport),
                _buildSettingsButton(context, 'Terms of Service', Icons.description, _navigateToTermsOfService),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _logout(context),
                  child: Text('Log Out'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context, String text, IconData icon, Function(BuildContext) onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton.icon(
        onPressed: () => onTap(context),
        icon: Icon(icon, color: Colors.black54),
        label: Text(text, style: TextStyle(color: Colors.black87)),
        style: ElevatedButton.styleFrom(
          primary: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          textStyle: TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 1,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfileScreen())).then((_) {
      setState(() {});
    });
  }

  void _navigateToChangePassword(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChangePasswordScreen()));
  }

  void _navigateToChangeEmail(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChangeEmailScreen()));
  }

  void _navigateToPaymentOptions(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PaymentOptionsScreen()));
  }

  void _navigateToCountry(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CountrySelectionScreen()));
  }

  void _navigateToOrderHistory(BuildContext context) {
    // Navigate to Order History Page
  }

  void _navigateToAddresses(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddressesScreen()));
  }

  void _navigateToSupport(BuildContext context) {
    // Navigate to Support Page
  }

  void _navigateToTermsOfService(BuildContext context) {
    // Navigate to Terms of Service Page
  }
}
