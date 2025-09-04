import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../styles/app_styles.dart';
import 'editar_perfil_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final ApiService apiService = ApiService();
  Map<String, dynamic>? usuario;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cargarPerfil();
  }

  Future<void> cargarPerfil() async {
    try {
      final data = await apiService.obtenerMiPerfil();
      setState(() {
        usuario = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar perfil: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        backgroundColor: AppStyles.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : usuario == null
              ? const Center(
                  child: Text("No se pudo cargar el perfil",
                      style: TextStyle(color: Colors.white)),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppStyles.primaryColor,
                        child: const Icon(Icons.person,
                            size: 60, color: Colors.white),
                      ),
                      const SizedBox(height: 20),

                      // Nombre completo
                      Text(
                        "${usuario!["nombre"] ?? ""} ${usuario!["apellido"] ?? ""}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Rol
                      Text(
                        usuario!["rol"]?["nombre"] ?? "Usuario",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Info detallada
                      _infoItem(Icons.email, "Correo", usuario!["correo"]),
                      _infoItem(Icons.phone, "Teléfono", usuario!["telefono"]),
                      _infoItem(Icons.home, "Dirección", usuario!["direccion"]),
                      const SizedBox(height: 30),

                      // Botón Editar perfil
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.primaryColor,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                        ),
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text("Editar perfil",
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          Navigator.pushNamed(context, "/editarPerfil",
                              arguments: usuario);
                        },
                      ),
                      const SizedBox(height: 10),

                     // Botón Cambiar contraseña
ElevatedButton.icon(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.deepPurple,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
  ),
  icon: const Icon(Icons.lock, color: Colors.white),
  label: const Text(
    "Cambiar contraseña",
    style: TextStyle(color: Colors.white),
  ),
  onPressed: () async {
    final correo = usuario!["correo"]; // 👈 tomamos el correo del perfil

    if (correo == null || correo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("El usuario no tiene correo registrado."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // 🚀 Enviamos directamente el correo a la API
      final response = await apiService.solicitarCodigo(correo);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"] ?? "Código enviado al correo."),
          backgroundColor: Colors.green,
        ),
      );

      // 👉 Redirigimos a VerifyCodeScreen
      Navigator.pushNamed(
        context,
        "/verifyCode",
        arguments: {"email": correo},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al enviar código: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
),


                      // Botón Cerrar sesión
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                        ),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text("Cerrar sesión",
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, "/login");
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _infoItem(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppStyles.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$label: ${value ?? "—"}",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
