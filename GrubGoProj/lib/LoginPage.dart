import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'RegistrationPage.dart';
import 'database_helper.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _message = '';
  static const Color backgroundColor = Color(0xFFE1E1E1);
  static const Color mainColor = Color(0xFF000080);

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var user = await DatabaseHelper.instance.getUserByEmailAndPassword(_email, _password);
      if (user != null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {
        setState(() {
          _message = 'Invalid email or password';
        });
      }
    }
  }

  void _goToRegister() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => RegistrationPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
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
                  onPressed: _login,
                  child: Text('Login'),
                  style: ElevatedButton.styleFrom(primary: mainColor),
                ),
                if (_message.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(_message, style: TextStyle(color: Colors.red)),
                  ),
                TextButton(
                  onPressed: _goToRegister,
                  child: Text('Need an account? Register now'),
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
