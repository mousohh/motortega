import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AgregarCitaScreen extends StatefulWidget {
  const AgregarCitaScreen({super.key});

  @override
  _AgregarCitaScreenState createState() => _AgregarCitaScreenState();
}

class _AgregarCitaScreenState extends State<AgregarCitaScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();

  // Valores seleccionados
  int? _vehiculoId;
  int? _mecanicoId;
  int? _ventaId;

  // Listas de datos
  List<dynamic> vehiculos = [];
  List<dynamic> mecanicos = [];
  List<dynamic> ventas = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final vehiculosData = await ApiService().obtenerVehiculos();
      final mecanicosData = await ApiService().obtenerMecanicos();
      final ventasData = await ApiService().obtenerVentas();

      setState(() {
        vehiculos = vehiculosData;
        mecanicos = mecanicosData;
        ventas = ventasData;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar datos: $e")),
      );
    }
  }

  Future<void> _crearCita() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final response = await ApiService().crearCita({
          "vehiculoId": _vehiculoId,
          "mecanicoId": _mecanicoId,
          "ventaId": _ventaId,
          "descripcion": _descripcionController.text,
          "fecha": _fechaController.text,
          "hora": _horaController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cita creada exitosamente ✅")),
        );
        Navigator.pop(context, true); // volver con éxito
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al crear cita: $e")),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  // Selección de fecha
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      _fechaController.text = picked.toIso8601String().split("T")[0];
    }
  }

  // Selección de hora
  Future<void> _selectTime() async {
    TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      final hora = picked.hour.toString().padLeft(2, '0');
      final minuto = picked.minute.toString().padLeft(2, '0');
      _horaController.text = "$hora:$minuto";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Cita")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Vehículo
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: "Vehículo"),
                value: _vehiculoId,
                items: vehiculos.isNotEmpty
                    ? vehiculos.map<DropdownMenuItem<int>>((v) {
                        return DropdownMenuItem<int>(
                          value: v["id"],
                          child: Text("${v["placa"]} - ${v["modelo"]}"),
                        );
                      }).toList()
                    : [],
                onChanged: (val) => setState(() => _vehiculoId = val),
                validator: (val) =>
                    val == null ? "Seleccione un vehículo" : null,
              ),

              // Mecánico
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: "Mecánico"),
                value: _mecanicoId,
                items: mecanicos.isNotEmpty
                    ? mecanicos.map<DropdownMenuItem<int>>((m) {
                        return DropdownMenuItem<int>(
                          value: m["id"],
                          child: Text(m["nombre"]),
                        );
                      }).toList()
                    : [],
                onChanged: (val) => setState(() => _mecanicoId = val),
                validator: (val) =>
                    val == null ? "Seleccione un mecánico" : null,
              ),

              // Venta
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: "Venta"),
                value: _ventaId,
                items: ventas.isNotEmpty
                    ? ventas.map<DropdownMenuItem<int>>((v) {
                        return DropdownMenuItem<int>(
                          value: v["id"],
                          child: Text("Venta #${v["id"]} - ${v["total"]}"),
                        );
                      }).toList()
                    : [],
                onChanged: (val) => setState(() => _ventaId = val),
                validator: (val) => val == null ? "Seleccione una venta" : null,
              ),

              // Descripción
              TextFormField(
                controller: _descripcionController,
                decoration:
                    const InputDecoration(labelText: "Descripción"),
                validator: (val) =>
                    val!.isEmpty ? "Ingrese una descripción" : null,
              ),

              // Fecha
              TextFormField(
                controller: _fechaController,
                readOnly: true,
                decoration: const InputDecoration(labelText: "Fecha"),
                onTap: _selectDate,
                validator: (val) =>
                    val!.isEmpty ? "Seleccione una fecha" : null,
              ),

              // Hora
              TextFormField(
                controller: _horaController,
                readOnly: true,
                decoration: const InputDecoration(labelText: "Hora"),
                onTap: _selectTime,
                validator: (val) =>
                    val!.isEmpty ? "Seleccione una hora" : null,
              ),

              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _crearCita,
                      child: const Text("Crear Cita"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
