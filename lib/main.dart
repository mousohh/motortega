import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_your_password_screen.dart';
// Si luego agregas más pantallas del flujo de recuperación, aquí las importas:
// import 'screens/verify_code_screen.dart';
// import 'screens/reset_password_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taller MotOrtega',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color.fromARGB(255, 111, 67, 176), // morado
        scaffoldBackgroundColor: Colors.black, // fondo negro
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 111, 67, 176),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/forgot-password': (context) => ForgotYourPasswordScreen(),
        // '/verify-code': (context) => VerifyCodeScreen(),
        // '/reset-password': (context) => ResetPasswordScreen(),
      },
    );
  }
}
