import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import 'agregar_cita_screen.dart';
import 'detalle_cita_screen.dart';
import '../services/api_service.dart';

class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService apiService = ApiService();

  List<dynamic> citas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cargarCitas();
  }

  Future<void> cargarCitas() async {
    try {
      final data = await apiService.obtenerCitas();
      setState(() {
        citas = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar citas: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "MIS CITAS",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: AppStyles.primaryColor),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔍 Buscador
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Buscar por vehículo...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),

                // 📌 Lista de citas
                Expanded(
                  child: citas.isEmpty
                      ? const Center(child: Text("No hay citas disponibles"))
                      : ListView.builder(
                          itemCount: citas.length,
                          itemBuilder: (context, index) {
                            final cita = citas[index];

                            // 🔎 Filtro por vehículo
                            if (_searchController.text.isNotEmpty &&
                                !cita["vehiculoPlaca"]
                                    .toLowerCase()
                                    .contains(_searchController.text.toLowerCase())) {
                              return const SizedBox.shrink();
                            }

                            return _buildCitaCard(cita);
                          },
                        ),
                ),
              ],
            ),

      // ➕ Botón agregar cita
      floatingActionButton: FloatingActionButton(
  backgroundColor: AppStyles.primaryColor,
  child: const Icon(Icons.edit, color: Colors.white),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AgregarCitaScreen()), // ❌ sin const
    ).then((_) => cargarCitas()); // 🔄 Recargar al volver
  },
),

    );
  }

  Widget _buildCitaCard(Map<String, dynamic> cita) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetalleCitaScreen(citaId: cita["id"])),
        ).then((_) => cargarCitas()); // 🔄 Refrescar al volver
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.grey[400],
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("FECHA: ${cita["fecha"]}", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("HORA: ${cita["hora"]}"),
              Text("VEHÍCULO: ${cita["vehiculoPlaca"]}"),
              Text("MECÁNICO: ${cita["mecanicoNombre"] ?? "Sin asignar"}"),
              Row(
                children: [
                  const Text("ESTADO: "),
                  Icon(
                    Icons.circle,
                    size: 16,
                    color: cita["estado"] == "Finalizada"
                        ? Colors.green
                        : (cita["estado"] == "Cancelada" ? Colors.red : Colors.orange),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.event, color: Colors.deepPurple),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DetalleCitaScreen(citaId: cita["id"])),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
