import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../services/api_service.dart';
import 'agregar_vehiculo_screen.dart';
import 'editar_vehiculo_screen.dart';
import 'detalle_vehiculo_screen.dart';

class VehiculosScreen extends StatefulWidget {
  final int clienteId;

  const VehiculosScreen({super.key, required this.clienteId});

  @override
  State<VehiculosScreen> createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> {
  List<dynamic> vehiculos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarVehiculos();
  }

 Future<void> _cargarVehiculos() async {
  try {
    final data = await ApiService().obtenerVehiculosPorCliente(widget.clienteId);

    // 🔧 Enriquecer cada vehículo con la referencia real
    final referencias = await ApiService().obtenerReferencias();
    for (var vehiculo in data) {
      final refId = vehiculo["referencia_id"];
      if (refId != null) {
        final ref = referencias.firstWhere(
          (r) => r["id"] == refId,
          orElse: () => {},
        );
        vehiculo["referencia"] = ref; // guardamos el objeto completo
      }
    }

    setState(() {
      vehiculos = data;
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error cargando vehículos: $e")),
    );
  }
}


  Future<void> _eliminarVehiculo(int id) async {
    try {
      await ApiService().eliminarVehiculo(id);
      setState(() {
        vehiculos.removeWhere((v) => v["id"] == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vehículo eliminado ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al eliminar: $e")),
      );
    }
  }

  void _mostrarDialogoEliminar(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Eliminar vehículo?"),
        content: const Text("¿Está seguro de eliminar este vehículo?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar",
                style: TextStyle(color: Colors.deepPurple)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _eliminarVehiculo(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "MIS VEHÍCULOS",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : vehiculos.isEmpty
              ? const Center(
                  child: Text("No tienes vehículos registrados",
                      style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  itemCount: vehiculos.length,
                  itemBuilder: (context, index) {
                    final vehiculo = vehiculos[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      color: Colors.grey[850],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(
                          "PLACA: ${vehiculo["placa"] ?? "N/A"}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Color: ${vehiculo["color"] ?? "N/A"}",
                                style: const TextStyle(color: Colors.white70)),
                            Text("Tipo: ${vehiculo["tipo_vehiculo"] ?? "N/A"}",
                                style: const TextStyle(color: Colors.white70)),
                            Text(
                                "Referencia: ${vehiculo["referencia"]?["nombre"] ?? vehiculo["referencia"]?["descripcion"] ?? "N/A"}",
                                style: const TextStyle(color: Colors.white70)),
                            Row(
                              children: [
                                const Text("Estado: ",
                                    style: TextStyle(color: Colors.white70)),
                                Icon(
                                  Icons.circle,
                                  size: 14,
                                  color: (vehiculo["estado"] == "Activo" ||
                                          vehiculo["estado"] == true)
                                      ? Colors.green
                                      : Colors.red,
                                )
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility,
                                  color: Colors.deepPurple),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetalleVehiculoScreen(
                                        vehiculo: vehiculo),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.deepPurple),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditarVehiculoScreen(vehiculo: vehiculo),
                                  ),
                                );
                                if (result == true) _cargarVehiculos();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _mostrarDialogoEliminar(vehiculo["id"]),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppStyles.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    AgregarVehiculoScreen(clienteId: widget.clienteId)),
          );
          if (result == true) _cargarVehiculos();
        },
      ),
    );
  }
}
