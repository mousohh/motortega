import 'package:flutter/material.dart'; 
import '../styles/app_styles.dart';
import '../services/api_service.dart';

// Importa pantallas
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
  bool isFormValid = false; 

  @override
  void initState() {
    super.initState();
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

    final usuario = response['usuario'];
    final rolId = usuario['rol_id'];
    final clienteId = usuario['id']; // 👈 Ajusta el nombre de la clave si en tu API se llama diferente (ej: cliente_id)

    // Mensaje de bienvenida
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bienvenido, ${usuario['nombre']}')),
    );

    // 🔹 Redirigimos al Dashboard con rol y clienteId
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(
          rolId: rolId,
          clienteId: clienteId,
        ),
      ),
    );
  } catch (e) {
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

              // Olvidé mi contraseña
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotYourPasswordScreen(),
                    ),
                  );
                },
                child: Text(
                  '¿Olvidaste tu contraseña? Recuperarla',
                  style: AppStyles.linkStyle,
                ),
              ),

              // Botón de inicio de sesión
              ElevatedButton(
                onPressed: isFormValid ? login : null,
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
                          color: AppStyles.textColor, 
                          fontSize: 16,
                        ),
                      ),
              ),
              SizedBox(height: 20),

              // Registro
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegisterScreen()),
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