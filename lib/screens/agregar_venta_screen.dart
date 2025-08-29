import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AgregarVentaScreen extends StatefulWidget {
  const AgregarVentaScreen({super.key});

  @override
  State<AgregarVentaScreen> createState() => _AgregarVentaScreenState();
}

class _AgregarVentaScreenState extends State<AgregarVentaScreen> {
  final _formKey = GlobalKey<FormState>();

  // Listas tipadas
  List<Map<String, dynamic>> clientes = [];
  List<Map<String, dynamic>> mecanicos = [];
  List<Map<String, dynamic>> estadosVenta = [];
  List<Map<String, dynamic>> citas = [];

  // Valores seleccionados
  int? clienteId;
  int? mecanicoId;
  int? estadoVentaId;
  int? citaId;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final clientesData = await ApiService().obtenerClientes();
      final mecanicosData = await ApiService().obtenerMecanicos();
      final estadosData = await ApiService().obtenerEstadosVenta();
      final citasData = await ApiService().obtenerCitas();

      setState(() {
        clientes = List<Map<String, dynamic>>.from(clientesData);
        mecanicos = List<Map<String, dynamic>>.from(mecanicosData);
        estadosVenta = List<Map<String, dynamic>>.from(estadosData);
        citas = List<Map<String, dynamic>>.from(citasData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar datos: $e")),
      );
    }
  }

  Future<void> guardarVenta() async {
    if (_formKey.currentState!.validate()) {
      try {
        final nuevaVenta = {
          "cliente_id": clienteId,
          "mecanico_id": mecanicoId,
          "estado_id": estadoVentaId,
          "cita_id": citaId,
        };

        await ApiService().crearVenta(nuevaVenta);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Venta creada correctamente ✅")),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar venta: $e")),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.black,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color.fromARGB(255, 111, 67, 176)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Agregar Venta"),
        backgroundColor: const Color.fromARGB(255, 111, 67, 176),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Cliente
                    DropdownButtonFormField<int>(
                      decoration: _inputDecoration("Cliente"),
                      dropdownColor: Colors.black,
                      value: clienteId,
                      items: clientes
                          .map((c) => DropdownMenuItem<int>(
                                value: c["id"],
                                child: Text(
                                  c["nombre"] ?? "Sin nombre",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => clienteId = val),
                      validator: (val) =>
                          val == null ? "Seleccione un cliente" : null,
                    ),
                    const SizedBox(height: 16),

                    // Mecánico
                    DropdownButtonFormField<int>(
                      decoration: _inputDecoration("Mecánico"),
                      dropdownColor: Colors.black,
                      value: mecanicoId,
                      items: mecanicos
                          .map((m) => DropdownMenuItem<int>(
                                value: m["id"],
                                child: Text(
                                  m["nombre"] ?? "Sin nombre",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => mecanicoId = val),
                      validator: (val) =>
                          val == null ? "Seleccione un mecánico" : null,
                    ),
                    const SizedBox(height: 16),

                    // Estado de venta
                    DropdownButtonFormField<int>(
                      decoration: _inputDecoration("Estado de venta"),
                      dropdownColor: Colors.black,
                      value: estadoVentaId,
                      items: estadosVenta
                          .map((e) => DropdownMenuItem<int>(
                                value: e["id"],
                                child: Text(
                                  e["nombre"] ?? "Sin nombre",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => estadoVentaId = val),
                      validator: (val) =>
                          val == null ? "Seleccione un estado" : null,
                    ),
                    const SizedBox(height: 16),

                    // Cita (opcional)
                    DropdownButtonFormField<int>(
                      decoration: _inputDecoration("Cita (opcional)"),
                      dropdownColor: Colors.black,
                      value: citaId,
                      items: citas
                          .map((c) => DropdownMenuItem<int>(
                                value: c["id"],
                                child: Text(
                                  "Cita #${c["id"]} - ${c["fecha"] ?? ''}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => citaId = val),
                    ),
                    const SizedBox(height: 24),

                    // Botón Guardar
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 111, 67, 176),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text(
                        "Guardar Venta",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: guardarVenta,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
