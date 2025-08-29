import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import 'editar_vehiculo_screen.dart';

class DetalleVehiculoScreen extends StatelessWidget {
  final Map<String, dynamic> vehiculo;

  const DetalleVehiculoScreen({super.key, required this.vehiculo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("INFORMACIÓN VEHÍCULO"),
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
        child: ListView(
          children: [
            const SizedBox(height: 15),

            // Placa
            _buildInfoField("Placa", vehiculo["placa"] ?? "-"),
            const SizedBox(height: 15),

            // Color
            _buildInfoField("Color", vehiculo["color"] ?? "-"),
            const SizedBox(height: 15),

            // Tipo vehículo
            _buildInfoField("Tipo vehículo", vehiculo["marca"]?["nombre"] ?? "-"),
            const SizedBox(height: 15),

            // Referencia
            _buildInfoField("Referencia", vehiculo["referencia"]?["nombre"] ?? "-"),
            const SizedBox(height: 30),

            // Botón volver
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Volver a vehículo",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 15),

            // Botón editar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditarVehiculoScreen(vehiculo: vehiculo),
                  ),
                );
              },
              child: const Text(
                "Editar vehículo",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
