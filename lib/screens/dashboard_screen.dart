import 'package:flutter/material.dart';
import '../styles/app_styles.dart';

class DashboardScreen extends StatelessWidget {
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
              SizedBox(height: 60),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage('/placeholder.svg?height=80&width=80'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 40),
              _buildMenuButton('Perfil', () {}),
              SizedBox(height: 15),
              _buildMenuButton('Mis citas', () {}),
              SizedBox(height: 15),
              _buildMenuButton('Mis Vehículos', () {}),
              SizedBox(height: 15),
              _buildMenuButton('Ventas', () {}),
              Spacer(),
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
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
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

  Widget _buildMenuButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 15),
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
