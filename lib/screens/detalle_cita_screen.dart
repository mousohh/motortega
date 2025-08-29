import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DetalleCitaScreen extends StatefulWidget {
  final int citaId;

  const DetalleCitaScreen({super.key, required this.citaId});

  @override
  State<DetalleCitaScreen> createState() => _DetalleCitaScreenState();
}

class _DetalleCitaScreenState extends State<DetalleCitaScreen> {
  final ApiService apiService = ApiService();

  Map<String, dynamic>? cita;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cargarDetalleCita();
  }

  Future<void> cargarDetalleCita() async {
    setState(() => isLoading = true);
    try {
      final data = await apiService.obtenerCitaPorId(widget.citaId);
      if (!mounted) return;
      setState(() {
        cita = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar la cita: $e")),
      );
    }
  }

  Future<void> cambiarEstado(int estadoId, String nuevoEstado) async {
    try {
      await apiService.cambiarEstadoCita(widget.citaId, estadoId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Estado actualizado a $nuevoEstado")),
      );
      await cargarDetalleCita();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar estado: $e")),
      );
    }
  }

  // Helper: obtener String de un Map con claves alternativas
  String _getStr(Map<String, dynamic>? source, List<String> keys, {String fallback = "—"}) {
    if (source == null) return fallback;
    for (var key in keys) {
      if (source[key] != null) return source[key].toString();
    }
    return fallback;
  }

  String get clienteNombre {
    // Soporta: cliente_nombre | clienteNombre | cliente { nombre, apellido }
    final nested = (cita?['cliente'] is Map)
        ? (cita!['cliente'] as Map<String, dynamic>)
        : null;

    if (nested != null) {
      final nombre = _getStr(nested, ['nombre', 'name']);
      final apellido = _getStr(nested, ['apellido', 'last_name'], fallback: '');
      return (nombre == '—' ? '' : nombre) +
          (apellido.isEmpty ? '' : ' $apellido');
    }
    return _getStr(cita, ['cliente_nombre', 'clienteNombre', 'cliente']);
  }

  String get mecanicoNombre {
    final nested = (cita?['mecanico'] is Map)
        ? (cita!['mecanico'] as Map<String, dynamic>)
        : null;

    if (nested != null) return _getStr(nested, ['nombre']);
    return _getStr(cita, ['mecanico_nombre', 'mecanicoNombre']);
  }

  String get vehiculoPlaca {
    final nested = (cita?['vehiculo'] is Map)
        ? (cita!['vehiculo'] as Map<String, dynamic>)
        : null;

    if (nested != null) return _getStr(nested, ['placa']);
    return _getStr(cita, ['vehiculo_placa', 'vehiculoPlaca', 'placa']);
  }

  String get estadoNombre {
    final nested = (cita?['estado'] is Map)
        ? (cita!['estado'] as Map<String, dynamic>)
        : null;

    if (nested != null) return _getStr(nested, ['nombre', 'estado']);
    return _getStr(cita, ['estado_nombre', 'estado', 'estadoNombre']);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Detalle de Cita",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 111, 67, 176),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : cita == null
              ? const Center(
                  child: Text(
                    "No se pudo cargar la información",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView(
                        children: [
                          _detalleItem("Cliente", clienteNombre),
                          _detalleItem("Vehículo", vehiculoPlaca),
                          _detalleItem("Mecánico", mecanicoNombre),
                          _detalleItem("Fecha", _getStr(cita, ['fecha', 'fecha_cita'])),
                          _detalleItem("Hora", _getStr(cita, ['hora'])),
                          _detalleItem("Estado", estadoNombre),
                          _detalleItem("Descripción", _getStr(cita, ['descripcion', 'descripcion_cita'])),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 111, 67, 176),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => cambiarEstado(3, "Completada"),
                                child: const Text("Finalizar"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => cambiarEstado(4, "Cancelada"),
                                child: const Text("Cancelar"),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _detalleItem(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$titulo: ",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
