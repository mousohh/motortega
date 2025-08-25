import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String codigo; // 👈 añadimos el código

  const ResetPasswordScreen({super.key, required this.email, required this.codigo});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;

  String? _validatePasswordMatch(String? value) {
    if (value == null || value.isEmpty) {
      return "Por favor confirma tu contraseña";
    }
    if (value != _passwordController.text) {
      return "Las contraseñas no coinciden";
    }
    return null;
  }

  Future<void> _cambiarPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('[DEBUG] Valores antes de enviar:');
      print('[DEBUG] Email: "${widget.email}" (${widget.email.runtimeType})');
      print('[DEBUG] Codigo: "${widget.codigo}" (${widget.codigo.runtimeType})');
      print('[DEBUG] Password: "${_passwordController.text}" (${_passwordController.text.runtimeType})');
      
      // Verificar que ningún valor sea null o vacío
      if (widget.email.isEmpty || widget.codigo.isEmpty || _passwordController.text.isEmpty) {
        throw Exception('Algún campo está vacío');
      }

      final response = await _apiService.resetPassword(
        widget.email,
        widget.codigo,
        _passwordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"] ?? "Contraseña actualizada correctamente"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Restablecer contraseña"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Nueva contraseña",
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 30, 30, 30),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                    value != null && value.length >= 6 ? null : "Mínimo 6 caracteres",
                onChanged: (value) {
                  if (_confirmController.text.isNotEmpty) {
                    _formKey.currentState!.validate();
                  }
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Confirmar contraseña",
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 30, 30, 30),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: _validatePasswordMatch,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.deepPurple)
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 111, 67, 176),
                      ),
                      onPressed: _cambiarPassword,
                      child: const Text("Cambiar contraseña", style: TextStyle(color: Colors.white)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
