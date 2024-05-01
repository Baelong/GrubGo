import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'LoginPage.dart';
import 'database_helper.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  static const Color backgroundColor = Color(0xFFE1E1E1);
  static const Color mainColor = Color(0xFF000080);

  void _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      int id = await DatabaseHelper.instance.addUser(_email, _password);
      print('User registered with id $id');
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: mainColor,
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Image.asset('assets/GrubGo.png', height: 120),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _register,
                  child: Text('Register'),
                  style: ElevatedButton.styleFrom(primary: mainColor),
                ),
                TextButton(
                  onPressed: _goToLogin,
                  child: Text('Already have an account? Log in'),
                  style: TextButton.styleFrom(primary: mainColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
