import 'package:flutter/material.dart';

class AppStyles {
  static const Color primaryColor = Color(0xFF6A1B9A); // Color morado
  static const Color backgroundColor = Color(0xFF121212); // Color negro
  static const Color textColor = Colors.white; // Color blanco
  
  static const TextStyle titleStyle = TextStyle(
    color: textColor,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle labelStyle = TextStyle(
    color: textColor,
    fontSize: 16,
  );
  
  static const TextStyle linkStyle = TextStyle(
    color: primaryColor,
    fontSize: 14,
    decoration: TextDecoration.underline,
  );
  
  static const TextStyle welcomeStyle = TextStyle(
    color: Colors.black,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle buttonStyle = TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}
