import 'package:flutter/material.dart';
import '../services/api_service.dart';

class VentasScreen extends StatefulWidget {
  const VentasScreen({Key? key}) : super(key: key);

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> ventas = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargarVentas();
  }

  Future<void> cargarVentas() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final data = await apiService.obtenerVentas();
      setState(() {
        ventas = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // Método para pintar un estado con color
  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'pagada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ventas"),
        backgroundColor: const Color.fromARGB(255, 111, 67, 176), // morado
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: cargarVentas,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text("Error: $error"))
              : ventas.isEmpty
                  ? const Center(child: Text("No hay ventas registradas"))
                  : ListView.builder(
                      itemCount: ventas.length,
                      itemBuilder: (context, index) {
                        final venta = ventas[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  _colorEstado(venta["estado"] ?? "Pendiente"),
                              child: const Icon(Icons.receipt_long,
                                  color: Colors.white),
                            ),
                            title: Text(
                                "Venta #${venta['id'] ?? '-'} - Cliente: ${venta['cliente']?['nombre'] ?? 'N/A'}"),
                            subtitle: Text(
                                "Estado: ${venta['estado'] ?? 'Pendiente'}\nFecha: ${venta['fecha'] ?? ''}"),
                            isThreeLine: true,
                            onTap: () {
                              // 🚀 Aquí después llevaremos al DetalleVentaScreen
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Abrir detalle de venta #${venta['id']}"),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 111, 67, 176),
        child: const Icon(Icons.add),
        onPressed: () {
          // 🚀 Aquí abriremos la pantalla de crear venta
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ir a crear nueva venta")),
          );
        },
      ),
    );
  }
}
