import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _documentoController = TextEditingController();
  String? _tipo_documento; 
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  // Dropdown de tipo de documento

  bool _isLoading = false;

  // 👉 Aquí pon la URL de tu API
  final String apiUrl = "https://api-final-8rw7.onrender.com/api/auth/register";

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tipo_documento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona un tipo de documento")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre": _nombreController.text,
          "apellido": _apellidoController.text,
          "correo": _correoController.text,
          "tipo_documento": _tipo_documento,
          "password": _passwordController.text,
          "telefono": _telefonoController.text,
          "direccion": _direccionController.text,
          "documento": _documentoController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registro exitoso: ${data['mensaje'] ?? 'Usuario creado'}")),
        );
        Navigator.pop(context); // Regresa al login
      } else if (response.statusCode == 400 && data["faltantes"] != null) {
        // 🚨 Mostrar campos faltantes
        String faltantes = (data["faltantes"] as List).join(", ");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Faltan campos: $faltantes")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${data['mensaje'] ?? 'Error en el registro'}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (value) =>
                    value!.isEmpty ? "Ingrese su nombre" : null,
              ),
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: "Apellido"),
                validator: (value) =>
                    value!.isEmpty ? "Ingrese su apellido" : null,
              ),
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(labelText: "Correo electrónico"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty ? "Ingrese su correo" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Tipo de documento"),
                value: _tipo_documento,
                items: const [
                  DropdownMenuItem(value: "Cedula de ciudadanía", child: Text("Cedula de ciudadanía")),
                  DropdownMenuItem(value: "Tarjeta de identidad", child: Text("Tarjeta de identidad")),
                  DropdownMenuItem(value: "Cedula de extranjería", child: Text("Cedula de extranjería")),
                  DropdownMenuItem(value: "Pasaporte", child: Text("Pasaporte")),
                  DropdownMenuItem(value: "NIT", child: Text("NIT")),
                  DropdownMenuItem(value: "Otro", child: Text("Otro")),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipo_documento = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Seleccione un tipo de documento" : null,
              ),
              TextFormField(
                controller: _documentoController,
                decoration: const InputDecoration(labelText: "Número de documento"),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? "Ingrese su documento" : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Contraseña"),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? "Ingrese su contraseña" : null,
              ),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: "Teléfono"),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? "Ingrese su teléfono" : null,
              ),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: "Dirección"),
                validator: (value) =>
                    value!.isEmpty ? "Ingrese su dirección" : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text("Registrarse",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
