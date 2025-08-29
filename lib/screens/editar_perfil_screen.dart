import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../styles/app_styles.dart';

class EditarPerfilScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const EditarPerfilScreen({super.key, required this.usuario});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.usuario["name"] ?? "";
    _apellidoController.text = widget.usuario["apellido"] ?? "";
    _correoController.text = widget.usuario["email"] ?? "";
    _telefonoController.text = widget.usuario["telefono"] ?? "";
    _direccionController.text = widget.usuario["direccion"] ?? "";
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ApiService().actualizarMiPerfil({
          "name": _nombreController.text,
          "apellido": _apellidoController.text,
          "email": _correoController.text,
          "telefono": _telefonoController.text,
          "direccion": _direccionController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil actualizado ✅")),
        );

        Navigator.pop(context, true); // ✅ Volvemos con éxito
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al actualizar: $e")),
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
        title: const Text("Editar Perfil"),
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
              // Nombre
              TextFormField(
                controller: _nombreController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Nombre"),
                validator: (val) =>
                    val!.isEmpty ? "Ingrese su nombre" : null,
              ),
              const SizedBox(height: 15),

              // Apellido
              TextFormField(
                controller: _apellidoController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Apellido"),
                validator: (val) =>
                    val!.isEmpty ? "Ingrese su apellido" : null,
              ),
              const SizedBox(height: 15),

              // Correo
              TextFormField(
                controller: _correoController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Correo"),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Ingrese su correo";
                  if (!val.contains("@")) return "Correo inválido";
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Teléfono
              TextFormField(
                controller: _telefonoController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Teléfono"),
                keyboardType: TextInputType.phone,
                validator: (val) =>
                    val!.isEmpty ? "Ingrese su teléfono" : null,
              ),
              const SizedBox(height: 15),

              // Dirección
              TextFormField(
                controller: _direccionController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Dirección"),
              ),
              const SizedBox(height: 30),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: _guardarCambios,
                      child: const Text(
                        "GUARDAR CAMBIOS",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
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
    );
  }
}
