import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../styles/app_styles.dart';

class DetalleVentaScreen extends StatefulWidget {
  final int ventaId;

  const DetalleVentaScreen({super.key, required this.ventaId});

  @override
  State<DetalleVentaScreen> createState() => _DetalleVentaScreenState();
}

class _DetalleVentaScreenState extends State<DetalleVentaScreen> {
  List<dynamic> detalles = [];
  bool isLoading = true;
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    _cargarDetalles();
  }

  Future<void> _cargarDetalles() async {
    try {
      final data = await ApiService().obtenerDetallesVenta(widget.ventaId);
      setState(() {
        detalles = data;
        total = _calcularTotal();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cargando detalles: $e")),
      );
    }
  }

  double _calcularTotal() {
    return detalles.fold(0.0, (sum, d) => sum + (d["precio"] * d["cantidad"]));
  }

  void _mostrarDialogoAgregar() {
    String tipo = "Repuesto";
    int? itemId;
    int cantidad = 1;
    double precio = 0;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Agregar detalle"),
          content: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: tipo,
                    items: ["Repuesto", "Servicio"]
                        .map((t) =>
                            DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setModalState(() => tipo = val!),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Cantidad"),
                    onChanged: (val) =>
                        setModalState(() => cantidad = int.tryParse(val) ?? 1),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Precio"),
                    onChanged: (val) =>
                        setModalState(() => precio = double.tryParse(val) ?? 0),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              child: const Text("Agregar"),
              onPressed: () {
                setState(() {
                  detalles.add({
                    "tipo": tipo,
                    "nombre": tipo == "Repuesto"
                        ? "Repuesto X"
                        : "Servicio Y", // luego lo conectamos a la API
                    "cantidad": cantidad,
                    "precio": precio,
                  });
                  total = _calcularTotal();
                });
                Navigator.pop(ctx);
              },
            ),
          ],
        );
      },
    );
  }
Future<void> _guardarDetalles() async {
  try {
    for (var detalle in detalles) {
      if (detalle["id"] != null) {
        // ✅ Si ya existe en la base de datos -> actualizar
        await ApiService().actualizarDetalleVenta(detalle["id"], {
          "venta_id": widget.ventaId,
          "tipo": detalle["tipo"],
          "descripcion": detalle["descripcion"],
          "cantidad": detalle["cantidad"],
          "precio": detalle["precio"],
        });
      } else {
        // ✅ Si es nuevo -> crearlo
        await ApiService().agregarDetalleVenta({
          "venta_id": widget.ventaId,
          "tipo": detalle["tipo"],
          "descripcion": detalle["descripcion"],
          "cantidad": detalle["cantidad"],
          "precio": detalle["precio"],
        });
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Detalles de venta guardados ✅")),
    );
    Navigator.pop(context, true);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error al guardar: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de Venta"),
        backgroundColor: AppStyles.primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: detalles.length,
                    itemBuilder: (context, index) {
                      final d = detalles[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text("${d["tipo"]}: ${d["nombre"]}"),
                          subtitle: Text(
                              "Cantidad: ${d["cantidad"]}  |  Precio: \$${d["precio"]}"),
                          trailing: Text(
                              "Subtotal: \$${d["precio"] * d["cantidad"]}"),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[300],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("TOTAL:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("\$$total",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _mostrarDialogoAgregar,
                          child: const Text("Agregar Detalle"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _guardarDetalles,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          child: const Text("Guardar"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
