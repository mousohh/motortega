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

  String? _tipoVehiculo;
  int? _marcaId;
  int? _referenciaId;

  List<dynamic> _marcas = [];
  List<dynamic> _referencias = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarMarcas();
  }

  Future<void> _cargarMarcas() async {
    try {
      final marcas = await ApiService().obtenerMarcas();
      setState(() {
        _marcas = marcas;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar marcas: $e")),
      );
    }
  }

  Future<void> _cargarReferencias(int marcaId) async {
    try {
      final refs = await ApiService().obtenerReferenciasPorMarca(marcaId);
      setState(() {
        _referencias = refs;
        _referenciaId = null; // reset selección
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar referencias: $e")),
      );
    }
  }

  Future<void> _guardarVehiculo() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tipoVehiculo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleccione un tipo de vehículo")),
      );
      return;
    }
    if (_marcaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleccione una marca")),
      );
      return;
    }
    if (_referenciaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleccione una referencia")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final body = {
        "placa": _placaController.text.trim(),
        "color": _colorController.text.trim(),
        "tipo_vehiculo": _tipoVehiculo,
        "cliente_id": widget.clienteId,
        "estado": "Activo",
        "referencia_id": _referenciaId,
      };

      print("📦 Enviando vehículo: $body");

      await ApiService().crearMiVehiculo(body);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vehículo agregado ✅")),
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

              // Tipo de vehículo
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Tipo de vehículo"),
                dropdownColor: Colors.black,
                value: _tipoVehiculo,
                items: ["Carro", "Moto", "Camioneta"]
                    .map((tipo) => DropdownMenuItem(
                          value: tipo,
                          child: Text(
                            tipo,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _tipoVehiculo = val),
                validator: (val) =>
                    val == null ? "Seleccione un tipo de vehículo" : null,
              ),
              const SizedBox(height: 15),

              // Marca
              DropdownButtonFormField<int>(
                decoration: _inputDecoration("Marca"),
                dropdownColor: Colors.black,
                value: _marcaId,
                items: _marcas.map<DropdownMenuItem<int>>((m) {
                  final id = m["id"] ?? m["id_marca"];
                  final nombre = m["nombre"] ?? m["descripcion"] ?? "—";
                  return DropdownMenuItem<int>(
                    value: id is String ? int.tryParse(id) : id,
                    child: Text(
                      nombre,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _marcaId = val);
                  if (val != null) {
                    _cargarReferencias(val);
                  }
                },
                validator: (val) => val == null ? "Seleccione una marca" : null,
              ),
              const SizedBox(height: 15),

              // Referencia
              DropdownButtonFormField<int>(
                decoration: _inputDecoration("Referencia"),
                dropdownColor: Colors.black,
                value: _referenciaId,
                items: _referencias.map<DropdownMenuItem<int>>((r) {
                  final id = r["id"] ?? r["id_referencia"];
                  final nombre = r["nombre"] ?? r["descripcion"] ?? "—";
                  return DropdownMenuItem<int>(
                    value: id is String ? int.tryParse(id) : id,
                    child: Text(
                      nombre,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _referenciaId = val),
                validator: (val) =>
                    val == null ? "Seleccione una referencia" : null,
              ),
              const SizedBox(height: 30),

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
