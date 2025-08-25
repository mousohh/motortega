import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'verify_code_screen.dart';

class ForgotYourPasswordScreen extends StatefulWidget {
  const ForgotYourPasswordScreen({super.key});

  @override
  State<ForgotYourPasswordScreen> createState() =>
      _ForgotYourPasswordScreenState();
}

class _ForgotYourPasswordScreenState extends State<ForgotYourPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _correoController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;

  Future<void> _solicitarCodigo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response =
          await _apiService.solicitarCodigo(_correoController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"] ?? "Código enviado al correo."),
          backgroundColor: Colors.green,
        ),
      );

      // 🚀 Redirige a VerifyCodeScreen con el correo
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VerifyCodeScreen(email: _correoController.text),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recuperar contraseña"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Ingresa tu correo electrónico y te enviaremos un código para recuperar tu contraseña.",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(
                  labelText: "Correo electrónico",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty ? "Ingrese su correo" : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _solicitarCodigo,
                      child: const Text("Enviar código"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
