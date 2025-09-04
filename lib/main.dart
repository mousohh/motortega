import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 🔹 Importa tus pantallas
import 'screens/login_screen.dart';
import 'screens/forgot_your_password_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/editar_perfil_screen.dart';
import 'screens/verify_code_screen.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;
  int? _rolId;
  int? _clienteId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    String? savedToken = await _storage.read(key: 'token');
    String? savedRol = await _storage.read(key: 'rolId');
    String? savedCliente = await _storage.read(key: 'clienteId');

    setState(() {
      _token = savedToken;
      _rolId = savedRol != null ? int.tryParse(savedRol) : null;
      _clienteId = savedCliente != null ? int.tryParse(savedCliente) : null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: const Center(
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 111, 67, 176),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taller MotOrtega',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color.fromARGB(255, 111, 67, 176),
        scaffoldBackgroundColor: Colors.black,
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

      // 🔹 Home dinámico según token
      home: _token == null
          ? LoginScreen()
          : DashboardScreen(
              rolId: _rolId ?? 0,
              clienteId: _clienteId ?? 0,
            ),

      routes: {
        '/login': (context) => LoginScreen(),
        '/forgot-password': (context) => ForgotYourPasswordScreen(),
        '/home': (context) => DashboardScreen(
              rolId: _rolId ?? 0,
              clienteId: _clienteId ?? 0,
            ),
      },

      onGenerateRoute: (settings) {
  if (settings.name == '/editarPerfil') {
    final args = settings.arguments as Map<String, dynamic>;
    return MaterialPageRoute(
      builder: (context) => EditarPerfilScreen(usuario: args),
    );
  }
  if (settings.name == '/verifyCode') {
    final args = settings.arguments as Map<String, dynamic>;
    return MaterialPageRoute(
      builder: (context) => VerifyCodeScreen(email: args["email"]),
    );
  }
  return null;
},

    );
  }
}
