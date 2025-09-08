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
  String? _tipoVehiculo;
  String? _estado; // 🔥 Nuevo campo

  bool _isLoading = false;
  List<dynamic> marcas = [];
  List<dynamic> referencias = [];

  @override
  void initState() {
    super.initState();

    _placaController.text = widget.vehiculo["placa"] ?? "";
    _colorController.text = widget.vehiculo["color"] ?? "";
    _tipoVehiculo = widget.vehiculo["tipo_vehiculo"];
    _estado = widget.vehiculo["estado"]; // 🔥 Guardamos estado

    _cargarDatosCompletos();
  }

  Future<void> _cargarDatosCompletos() async {
    setState(() => _isLoading = true);
    
    try {
      final vehiculoCompleto =
          await ApiService().obtenerDetalleVehiculo(widget.vehiculo["id"]);

      await _extraerYBuscarReferencia(vehiculoCompleto);

      // actualizar estado si viene en la respuesta
      if (vehiculoCompleto["estado"] != null) {
        _estado = vehiculoCompleto["estado"];
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cargando datos del vehículo: $e")),
      );
      await _cargarMarcas();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _extraerYBuscarReferencia(
      Map<String, dynamic> vehiculoCompleto) async {
    if (vehiculoCompleto["referencia_id"] != null) {
      _referenciaId = vehiculoCompleto["referencia_id"] is String
          ? int.tryParse(vehiculoCompleto["referencia_id"])
          : vehiculoCompleto["referencia_id"];
    }

    if (_referenciaId != null) {
      await _cargarMarcas();
      await _buscarMarcaPorReferenciaId(_referenciaId!);
    } else {
      await _cargarMarcas();
    }
  }

  Future<void> _buscarMarcaPorReferenciaId(int referenciaId) async {
    try {
      for (var marca in marcas) {
        final marcaId =
            marca["id"] is String ? int.tryParse(marca["id"]) : marca["id"];

        try {
          final refs = await ApiService().obtenerReferenciasPorMarca(marcaId);

          final referenciaEncontrada = refs.firstWhere(
            (r) =>
                (r["id"] is String ? int.tryParse(r["id"]) : r["id"]) ==
                referenciaId,
            orElse: () => null,
          );

          if (referenciaEncontrada != null) {
            _marcaId = marcaId;
            _referenciaId = referenciaId;
            await _cargarReferencias(marcaId);
            return;
          }
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> _cargarMarcas() async {
    try {
      final marcasData = await ApiService().obtenerMarcas();
      setState(() => marcas = marcasData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cargando marcas: $e")),
      );
    }
  }

  Future<void> _cargarReferencias(int marcaId) async {
    try {
      final refs = await ApiService().obtenerReferenciasPorMarca(marcaId);
      setState(() => referencias = refs);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cargando referencias: $e")),
      );
    }
  }

  Future<void> _guardarCambios() async {
    // 🔥 Siempre mandamos todos los campos al backend
    final Map<String, dynamic> datos = {
      "placa": _placaController.text.trim().isNotEmpty
          ? _placaController.text.trim()
          : widget.vehiculo["placa"],
      "color": _colorController.text.trim().isNotEmpty
          ? _colorController.text.trim()
          : widget.vehiculo["color"],
      "tipo_vehiculo": _tipoVehiculo ?? widget.vehiculo["tipo_vehiculo"],
      "estado": _estado ?? widget.vehiculo["estado"], // 🔥 Se manda estado
      "marca_id": _marcaId ??
          (widget.vehiculo["referencia"]?["marca"]?["id"] ??
              widget.vehiculo["marca_id"]),
      "referencia_id": _referenciaId ??
          (widget.vehiculo["referencia"]?["id"] ??
              widget.vehiculo["referencia_id"]),
    };

    print("📦 ===== DATOS A ENVIAR AL BACKEND =====");
    print("ID Vehículo: ${widget.vehiculo["id"]}");
    datos.forEach((key, value) {
      print("➡️ $key : $value");
    });

    setState(() => _isLoading = true);
    try {
      await ApiService().actualizarVehiculo(widget.vehiculo["id"], datos);

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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _placaController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Placa"),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _colorController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Color"),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<int>(
                      value: _marcaId,
                      decoration: _inputDecoration("Marca"),
                      dropdownColor: Colors.black,
                      items: marcas.map<DropdownMenuItem<int>>((m) {
                        final id = m["id"] is String
                            ? int.tryParse(m["id"])
                            : m["id"];
                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(
                            m["nombre"] ?? "—",
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _marcaId = val;
                          _referenciaId = null;
                          referencias = [];
                        });
                        if (val != null) _cargarReferencias(val);
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<int>(
                      value: _referenciaId,
                      decoration: _inputDecoration("Referencia"),
                      dropdownColor: Colors.black,
                      items: referencias.map<DropdownMenuItem<int>>((r) {
                        final id = r["id"] is String
                            ? int.tryParse(r["id"])
                            : r["id"];
                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(
                            r["nombre"] ?? "—",
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _referenciaId = val),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
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
        borderSide: BorderSide(color: Colors.purpleAccent),
      ),
    );
  }
}
