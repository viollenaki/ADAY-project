import 'package:flutter/material.dart';
import 'package:personal_finance/database/database_helper.dart';
import 'package:personal_finance/database/globals.dart';
import 'package:personal_finance/generated/l10n.dart';
import '../main.dart';

class Loginregister extends StatefulWidget {
  const Loginregister({super.key});

  @override
  State<Loginregister> createState() => _LoginregisterState();
}

class _LoginregisterState extends State<Loginregister> {
  bool _isLogin = true; // Track if it's login or register page
  bool _isPasswordVisible = false; // Track password visibility

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController =
      TextEditingController(); // For registration

  final _formKey = GlobalKey<FormState>(); // Form key for validation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Logo or Title
                        const Icon(
                          Icons.account_circle,
                          size: 80,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isLogin ? S.of(context).welcomeBack : S.of(context).createAccount,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Username Field
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            labelText: S.of(context).username,
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return S.of(context).pleaseEnterAUsername;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            labelText: S.of(context).password,
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return S.of(context).pleaseEnterAPassword;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Email Field (for registration)
                        if (!_isLogin)
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              labelText: S.of(context).email,
                              prefixIcon: const Icon(Icons.email),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return S.of(context).pleaseEnterAnEmail;
                              }
                              if (!value.contains('@')) {
                                return S.of(context).pleaseEnterAValidEmail;
                              }
                              return null;
                            },
                          ),
                        if (!_isLogin) const SizedBox(height: 16),
                        // Login/Register Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                if (_isLogin) {
                                  currentUsername = _usernameController.text;
                                  // Navigate to home page (Login action)
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const MainNavigationScreen(),
                                    ),
                                  );
                                } else {
                                  final dbHelper = DatabaseHelper();
                                  final name = _usernameController.text;
                                  final email = _emailController.text;
                                  final password = _passwordController.text;

                                  dbHelper.insertUser(name, email, password).then((id) {
                                    if (id > 0) {
                                      currentUsername = name;
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => const MainNavigationScreen(),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(S.of(context).userAlreadyExistsOrRegistrationFailed)),
                                      );
                                    }
                                  });
                                  print("Registering user...");
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                    color: Colors.deepPurple, width: 2),
                              ),
                              backgroundColor: Colors.deepPurple,
                            ),
                            child: Text(
                              _isLogin ? S.of(context).login : S.of(context).register,
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Toggle between Login and Register
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin =
                                  !_isLogin; // Toggle between Login and Register
                            });
                          },
                          child: Text(
                            _isLogin
                                ? S.of(context).dontHaveAnAccountRegister
                                : S.of(context).alreadyHaveAnAccountLogin,
                            style: const TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
