import 'dart:math';
import 'package:flutter/material.dart';

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isCorrect = false;
  Offset? buttonPosition;
  bool usernameError = false;
  bool passwordError = false;
  final Random random = Random();
  int attemptCount = 0; // Add this at the top

  void handleLogin() {
    setState(() {
      usernameError = usernameController.text != "admin";
      passwordError = passwordController.text != "admin123";
      isCorrect = !usernameError && !passwordError;

      if (isCorrect) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🎉 Login Successful!")),
        );
        buttonPosition = null;
        attemptCount = 0; // Reset attempts
      } else {
        attemptCount++;
        moveButton();
      }
    });
  }

  void moveButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Define safe zone (form area)
    final safeLeft = screenWidth * 0.2;
    final safeRight = screenWidth * 0.8;
    final safeTop = screenHeight * 0.3;
    final safeBottom = screenHeight * 0.7;

    final positions = [
      Offset(50, 50), // Top-left
      Offset(screenWidth - 150, 50), // Top-right
      Offset(50, screenHeight - 150), // Bottom-left
      Offset(screenWidth - 150, screenHeight - 150), // Bottom-right
      Offset(
        random.nextDouble() * (screenWidth - 150),
        random.nextDouble() * (screenHeight - 150),
      ), // Random anywhere except form
    ];

    final filteredPositions = positions.where((pos) {
      return !(pos.dx > safeLeft &&
          pos.dx < safeRight - 150 &&
          pos.dy > safeTop &&
          pos.dy < safeBottom - 50);
    }).toList();

    setState(() {
      buttonPosition =
          filteredPositions[random.nextInt(filteredPositions.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: usernameController,
                        onChanged: (_) {
                          setState(() {
                            usernameError = false;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color:
                                    usernameError ? Colors.red : Colors.blue),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color:
                                    usernameError ? Colors.red : Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        onChanged: (_) {
                          setState(() {
                            passwordError = false;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color:
                                    passwordError ? Colors.red : Colors.blue),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color:
                                    passwordError ? Colors.red : Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (buttonPosition == null)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.blueAccent,
                          ),
                          onPressed: handleLogin,
                          child: const Text("Login",
                              style: TextStyle(color: Colors.white)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (buttonPosition != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              left: buttonPosition!.dx,
              top: buttonPosition!.dy,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                        color: Colors.white, width: 1), // White border
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: handleLogin,
                child:
                    const Text("Login", style: TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
