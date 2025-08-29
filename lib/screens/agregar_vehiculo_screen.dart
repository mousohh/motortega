import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../styles/app_styles.dart';

class AgregarVehiculoScreen extends StatefulWidget {
  final int clienteId;
  const AgregarVehiculoScreen({super.key, required this.clienteId});

  @override
  _AgregarVehiculoScreenState createState() => _AgregarVehiculoScreenState();
}

class _AgregarVehiculoScreenState extends State<AgregarVehiculoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  int? _marcaId;
  int? _referenciaId;

  List<dynamic> _marcas = [];
  List<dynamic> _referencias = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final marcas = await ApiService().obtenerMarcas();
      final refs = await ApiService().obtenerReferencias();

      setState(() {
        _marcas = marcas;
        _referencias = refs;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al cargar datos: $e")));
    }
  }

  Future<void> _guardarVehiculo() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final response = await ApiService().crearVehiculo({
          "placa": _placaController.text,
          "color": _colorController.text,
          "estado": "Activo",
          "cliente_id": widget.clienteId,
          "marca_id": _marcaId,
          "referencia_id": _referenciaId,
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Vehículo agregado ✅")));
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
        title: const Text("AGREGAR VEHÍCULO"),
        backgroundColor: Colors.black,
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
              const Text(
                "Llena los siguientes datos.",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // Placa
              TextFormField(
                controller: _placaController,
                decoration: _inputDecoration("Placa"),
                style: const TextStyle(color: Colors.white),
                validator: (val) => val!.isEmpty ? "Ingrese la placa" : null,
              ),
              const SizedBox(height: 15),

              // Color
              TextFormField(
                controller: _colorController,
                decoration: _inputDecoration("Color"),
                style: const TextStyle(color: Colors.white),
                validator: (val) => val!.isEmpty ? "Ingrese el color" : null,
              ),
              const SizedBox(height: 15),

              // Marca
              DropdownButtonFormField<int>(
                decoration: _inputDecoration("Marca"),
                dropdownColor: Colors.black,
                value: _marcaId,
                items:
                    _marcas.map<DropdownMenuItem<int>>((m) {
                      // Asegurar que el id siempre sea int
                      final id =
                          (m["id"] ?? m["id_marca"]) is String
                              ? int.tryParse(m["id"] ?? m["id_marca"])
                              : m["id"] ?? m["id_marca"];

                      final nombre = m["nombre"] ?? m["descripcion"] ?? "—";

                      return DropdownMenuItem<int>(
                        value: id,
                        child: Text(
                          nombre,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                onChanged: (val) => setState(() => _marcaId = val),
                validator: (val) => val == null ? "Seleccione una marca" : null,
              ),

              // Referencia
              DropdownButtonFormField<int>(
                decoration: _inputDecoration("Referencia"),
                dropdownColor: Colors.black,
                value: _referenciaId,
                items:
                    _referencias.map<DropdownMenuItem<int>>((r) {
                      final id =
                          (r["id"] ?? r["id_referencia"]) is String
                              ? int.tryParse(r["id"] ?? r["id_referencia"])
                              : r["id"] ?? r["id_referencia"];

                      final nombre = r["nombre"] ?? r["descripcion"] ?? "—";

                      return DropdownMenuItem<int>(
                        value: id,
                        child: Text(
                          nombre,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                onChanged: (val) => setState(() => _referenciaId = val),
                validator:
                    (val) => val == null ? "Seleccione una referencia" : null,
              ),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _guardarVehiculo,
                    child: const Text(
                      "Agregar vehículo",
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
