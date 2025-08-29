import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../services/api_service.dart';

class EditarVehiculoScreen extends StatefulWidget {
  final Map<String, dynamic> vehiculo;

  const EditarVehiculoScreen({super.key, required this.vehiculo});

  @override
  State<EditarVehiculoScreen> createState() => _EditarVehiculoScreenState();
}

class _EditarVehiculoScreenState extends State<EditarVehiculoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  int? _marcaId;
  int? _referenciaId;

  bool _isLoading = false;
  List<dynamic> marcas = [];
  List<dynamic> referencias = [];

  @override
  void initState() {
    super.initState();
    _placaController.text = widget.vehiculo["placa"] ?? "";
    _colorController.text = widget.vehiculo["color"] ?? "";

    // Inicializar valores si vienen anidados
    final marca = widget.vehiculo["marca"];
    final referencia = widget.vehiculo["referencia"];

    _marcaId = marca != null
        ? (marca["id"] is String
            ? int.tryParse(marca["id"])
            : marca["id"])
        : null;

    _referenciaId = referencia != null
        ? (referencia["id"] is String
            ? int.tryParse(referencia["id"])
            : referencia["id"])
        : null;

    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      // ✅ Usamos los métodos correctos de ApiService
      final marcasData = await ApiService().obtenerMarcas();
      final referenciasData = await ApiService().obtenerReferencias();

      setState(() {
        marcas = marcasData;
        referencias = referenciasData;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cargando datos: $e")),
      );
    }
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ApiService().actualizarVehiculo(
          widget.vehiculo["id"],
          {
            "placa": _placaController.text,
            "color": _colorController.text,
            "marcaId": _marcaId,
            "referenciaId": _referenciaId,
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vehículo actualizado ✅")),
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
        title: const Text("EDITAR VEHÍCULO"),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Placa
              TextFormField(
                controller: _placaController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Placa",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purpleAccent),
                  ),
                ),
                validator: (val) =>
                    val!.isEmpty ? "Ingrese la placa" : null,
              ),
              const SizedBox(height: 15),

              // Color
              TextFormField(
                controller: _colorController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Color",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purpleAccent),
                  ),
                ),
                validator: (val) =>
                    val!.isEmpty ? "Ingrese el color" : null,
              ),
              const SizedBox(height: 15),

              // Marca
              DropdownButtonFormField<int>(
                value: _marcaId,
                decoration: const InputDecoration(
                  labelText: "Marca",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple),
                  ),
                ),
                dropdownColor: Colors.black,
                items: marcas.map<DropdownMenuItem<int>>((m) {
                  final rawId = m["id"] ?? m["id_marca"];
                  final id = rawId is String ? int.tryParse(rawId) : rawId;
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
                validator: (val) =>
                    val == null ? "Seleccione una marca" : null,
              ),
              const SizedBox(height: 15),

              // Referencia
              DropdownButtonFormField<int>(
                value: _referenciaId,
                decoration: const InputDecoration(
                  labelText: "Referencia",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple),
                  ),
                ),
                dropdownColor: Colors.black,
                items: referencias.map<DropdownMenuItem<int>>((r) {
                  final rawId = r["id"] ?? r["id_referencia"];
                  final id = rawId is String ? int.tryParse(rawId) : rawId;
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
}
