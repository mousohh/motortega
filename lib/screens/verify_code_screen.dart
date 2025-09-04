import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'reset_password_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({super.key, required this.email});

  @override
  _VerifyCodeScreenState createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;

  Future<void> _verificarCodigo() async {
    if (_codeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El código debe tener 6 dígitos")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print("📧 Enviando correo a la API: ${widget.email}");
      print("🔑 Código ingresado: ${_codeController.text}");

      final response = await _apiService.verificarCodigo(
        widget.email.trim(), // 👈 trim para evitar espacios
        _codeController.text.trim(),
      );

      print("✅ Respuesta de API: $response");

      // 🚀 Si es correcto, redirige a ResetPasswordScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(
            email: widget.email,
            codigo: _codeController.text,
          ),
        ),
      );
    } catch (e) {
      print("❌ Error al verificar: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al verificar: $e"), backgroundColor: Colors.red),
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
        title: const Text("Verificar código"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Se envió un código a ${widget.email}",
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Campo para ingresar código
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 10,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color.fromARGB(255, 30, 30, 30),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botón verificar
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 111, 67, 176),
                    ),
                    onPressed: _verificarCodigo,
                    child: const Text(
                      "Verificar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
