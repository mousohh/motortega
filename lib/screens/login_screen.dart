import 'package:flutter/material.dart'; 
import '../styles/app_styles.dart';
import '../services/api_service.dart';
// Importa la pantalla de registro
import 'dashboard_screen.dart';
import 'register_screen.dart';
import 'forgot_your_password_screen.dart'; 
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool isFormValid = false; // ✅ Estado del formulario

  @override
  void initState() {
    super.initState();
    // Escuchamos cambios en los campos en tiempo real
    usernameController.addListener(validateForm);
    passwordController.addListener(validateForm);
  }

  void validateForm() {
    setState(() {
      isFormValid = usernameController.text.trim().isNotEmpty &&
          passwordController.text.trim().isNotEmpty;
    });
  }

  void login() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await apiService.login(
        usernameController.text.trim(),
        passwordController.text.trim(),
      );

      // Mostrar mensaje de bienvenida con el nombre del usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bienvenido, ${response['usuario']['nombre']}')),
      );

      // Navegar al Dashboard
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } catch (e) {
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/logo.png',
                width: 120,
                height: 120,
              ),
              SizedBox(height: 20),

              // Título
              Text(
                'Inicio de sesión',
                style: AppStyles.titleStyle,
              ),
              SizedBox(height: 20),

              // Campo de usuario
              TextField(
                controller: usernameController,
                style: TextStyle(color: AppStyles.textColor),
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  labelStyle: AppStyles.labelStyle,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppStyles.primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppStyles.primaryColor),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Campo de contraseña
              TextField(
                controller: passwordController,
                obscureText: true,
                style: TextStyle(color: AppStyles.textColor),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: AppStyles.labelStyle,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppStyles.primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppStyles.primaryColor),
                  ),
                ),
              ),
              SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ForgotYourPasswordScreen()), // Redirige a la pantalla de registro
                  );
                },
                child: Text(
                  '¿Olvidaste tu contraseña? Recuperarla',
                  style: AppStyles.linkStyle,
                ),
              ),

              // Botón de inicio de sesión
              ElevatedButton(
                onPressed: isFormValid ? login : null, // ✅ Se deshabilita si los campos están vacíos
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isFormValid ? AppStyles.primaryColor : Colors.grey,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: AppStyles.textColor)
                    : Text(
                        'Iniciar sesión',
                        style: TextStyle(
                            color: AppStyles.textColor, fontSize: 16),
                      ),
              ),
              SizedBox(height: 20),

              // Botón para redirigir al registro
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            RegisterScreen()), // Redirige a la pantalla de registro
                  );
                },
                child: Text(
                  '¿No tienes cuenta? Regístrate',
                  style: AppStyles.linkStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
