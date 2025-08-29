import 'package:flutter/material.dart';
import '../styles/app_styles.dart';

// 🔹 Importa tus pantallas
import 'citas_screen.dart';
import 'mis_vehiculos_screen.dart';
import 'ventas_screen.dart';
import 'perfil_screen.dart';

class DashboardScreen extends StatelessWidget {
  final int rolId; // ✅ Rol recibido desde login
  final int clienteId; // ✅ Id del cliente recibido desde login

  const DashboardScreen({
    super.key,
    required this.rolId,
    required this.clienteId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: AppStyles.primaryColor,
              size: 30,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey[400]!,
                AppStyles.primaryColor,
              ],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Avatar del usuario
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: AppStyles.primaryColor,
                ),
              ),
              const SizedBox(height: 40),

              // ✅ Opciones dinámicas según el rol
              ..._buildMenuOptions(context),

              const Spacer(),

              // Botón de cerrar sesión
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text(
              'Bienvenido\na MotOrtega',
              style: AppStyles.welcomeStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Menú dinámico según el rol
  List<Widget> _buildMenuOptions(BuildContext context) {
    switch (rolId) {
      case 1: // Admin
        return [
          _buildMenuButton('Perfil', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PerfilScreen()));
          }),
          const SizedBox(height: 15),
          _buildMenuButton('Mis citas', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CitasScreen()));
          }),
          const SizedBox(height: 15),
          _buildMenuButton('Mis Vehículos', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VehiculosScreen(clienteId: clienteId),
              ),
            );
          }),
          const SizedBox(height: 15),
          _buildMenuButton('Ventas', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const VentasScreen()));
          }),
        ];

      case 3: // Mecánico
        return [
          _buildMenuButton('Citas', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CitasScreen()));
          }),
        ];

      case 4: // Cliente
        return [
          _buildMenuButton('Perfil', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PerfilScreen()));
          }),
          const SizedBox(height: 15),
          _buildMenuButton('Mis citas', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CitasScreen()));
          }),
          const SizedBox(height: 15),
          _buildMenuButton('Mis Vehículos', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VehiculosScreen(clienteId: clienteId),
              ),
            );
          }),
        ];

      default:
        return [
          _buildMenuButton('Perfil', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PerfilScreen()));
          }),
        ];
    }
  }

  Widget _buildMenuButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 2,
          ),
          child: Text(
            text,
            style: AppStyles.buttonStyle,
          ),
        ),
      ),
    );
  }
}
