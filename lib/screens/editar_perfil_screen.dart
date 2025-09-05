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
  final TextEditingController _tipoDocController = TextEditingController();
  final TextEditingController _documentoController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.usuario["nombre"] ?? "";
    _apellidoController.text = widget.usuario["apellido"] ?? "";
    _correoController.text = widget.usuario["correo"] ?? "";
    _telefonoController.text = widget.usuario["telefono"] ?? "";
    _direccionController.text = widget.usuario["direccion"] ?? "";
    _tipoDocController.text = widget.usuario["tipo_documento"] ?? "";
    _documentoController.text = widget.usuario["documento"]?.toString() ?? "";
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // 👇 Mezclamos el usuario completo y actualizamos solo los campos editados
        final updatedData = {
          ...widget.usuario,
          "nombre": _nombreController.text,
          "apellido": _apellidoController.text,
          "telefono": _telefonoController.text,
          "direccion": _direccionController.text,
        };

        await ApiService().actualizarMiPerfil(updatedData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil actualizado ✅")),
        );

        Navigator.pop(context, true);
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
              _buildField(_nombreController, "Nombre"),
              const SizedBox(height: 15),
              _buildField(_apellidoController, "Apellido"),
              const SizedBox(height: 15),
              _buildField(_correoController, "Correo", readOnly: true),
              const SizedBox(height: 15),
              _buildField(_tipoDocController, "Tipo Documento", readOnly: true),
              const SizedBox(height: 15),
              _buildField(_documentoController, "Documento", readOnly: true),
              const SizedBox(height: 15),
              _buildField(_telefonoController, "Teléfono",
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 15),
              _buildField(_direccionController, "Dirección"),
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

  Widget _buildField(TextEditingController controller, String label,
      {bool readOnly = false, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: TextStyle(color: readOnly ? Colors.white70 : Colors.white),
      decoration: _inputDecoration(label),
      validator: (val) {
        if (!readOnly && (val == null || val.isEmpty)) {
          return "Ingrese su $label";
        }
        return null;
      },
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
