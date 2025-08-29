import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../styles/app_styles.dart';

class CambiarPasswordScreen extends StatefulWidget {
  final int usuarioId;

  const CambiarPasswordScreen({super.key, required this.usuarioId});

  @override
  State<CambiarPasswordScreen> createState() => _CambiarPasswordScreenState();
}

class _CambiarPasswordScreenState extends State<CambiarPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _passwordActualController =
      TextEditingController();
  final TextEditingController _nuevaPasswordController =
      TextEditingController();
  final TextEditingController _confirmarPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscureActual = true;
  bool _obscureNueva = true;
  bool _obscureConfirmar = true;

  Future<void> _cambiarPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await ApiService().cambiarPassword(
          widget.usuarioId,
          _passwordActualController.text,
          _nuevaPasswordController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contraseña actualizada ✅")),
        );

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Cambiar Contraseña"),
        backgroundColor: AppStyles.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Contraseña actual
              TextFormField(
                controller: _passwordActualController,
                obscureText: _obscureActual,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  "Contraseña actual",
                  toggle: () => setState(() => _obscureActual = !_obscureActual),
                  obscure: _obscureActual,
                ),
                validator: (val) =>
                    val!.isEmpty ? "Ingrese su contraseña actual" : null,
              ),
              const SizedBox(height: 15),

              // Nueva contraseña
              TextFormField(
                controller: _nuevaPasswordController,
                obscureText: _obscureNueva,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  "Nueva contraseña",
                  toggle: () => setState(() => _obscureNueva = !_obscureNueva),
                  obscure: _obscureNueva,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Ingrese su nueva contraseña";
                  }
                  if (val.length < 6) {
                    return "La contraseña debe tener al menos 6 caracteres";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Confirmar contraseña
              TextFormField(
                controller: _confirmarPasswordController,
                obscureText: _obscureConfirmar,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration(
                  "Confirmar contraseña",
                  toggle: () =>
                      setState(() => _obscureConfirmar = !_obscureConfirmar),
                  obscure: _obscureConfirmar,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Confirme su nueva contraseña";
                  }
                  if (val != _nuevaPasswordController.text) {
                    return "Las contraseñas no coinciden";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: _cambiarPassword,
                      child: const Text(
                        "CAMBIAR CONTRASEÑA",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label,
      {required VoidCallback toggle, required bool obscure}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepPurple),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      border: const OutlineInputBorder(),
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off : Icons.visibility,
          color: Colors.white70,
        ),
        onPressed: toggle,
      ),
    );
  }
}
