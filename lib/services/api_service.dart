import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = 'https://api-final-8rw7.onrender.com';

  Future<dynamic> login(String correo, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': correo, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Credenciales incorrectas');
      } else {
        final error = jsonDecode(response.body)['message'];
        throw Exception(error ?? 'Error desconocido');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<dynamic> register(
    String nombre,
    String apellido,
    String correo,
    String tipodocumento,
    String documento,
    String password,  
    String telefono,
    String direccion,
  ) async {
    final url = Uri.parse('$baseUrl/api/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nombre,
          'apellido': apellido,
          'email': correo,
          'tipo_documento': tipodocumento,
          'document': documento,
          'telefono': telefono,
          'contraseña': password,
          'direccion': direccion,
          'estado': 'Activo',
          'rol_id': '4',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body)['message'];
        throw Exception(error ?? 'Error desconocido al registrar usuario');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<dynamic> solicitarCodigo(String correo) async {
    final url = Uri.parse('$baseUrl/api/auth/solicitar-codigo');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': correo}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body)['message'];
        throw Exception(error ?? 'Error desconocido al solicitar código');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // 🔹 NUEVO: verificar código
  Future<dynamic> verificarCodigo(String correo, String codigo) async {
    final url = Uri.parse('$baseUrl/api/auth/verificar-codigo');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': correo, 'codigo': codigo}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body)['message'];
        throw Exception(error ?? 'Código inválido o expirado');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // 🔹 NUEVO: resetear contraseña
  Future<dynamic> resetPassword(String correo, String codigo, String nuevaPassword) async {
    final url = Uri.parse('$baseUrl/api/auth/nueva-password');
    
    final String correoStr = correo?.toString() ?? '';
    final String codigoStr = codigo?.toString() ?? '';
    final String passwordStr = nuevaPassword?.toString() ?? '';
    
    print('[DEBUG] Enviando request a: $url');
    print('[DEBUG] Datos: correo=$correoStr, codigo=$codigoStr, nuevaPassword=$passwordStr');
    
    if (correoStr.isEmpty || codigoStr.isEmpty || passwordStr.isEmpty) {
      throw Exception('Todos los campos son requeridos');
    }
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': correoStr, 
          'codigo': codigoStr,
          'nuevaPassword': passwordStr
        }),
      ).timeout(Duration(seconds: 30));

      print('[DEBUG] Status Code: ${response.statusCode}');
      print('[DEBUG] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        final error = errorBody['message'] ?? errorBody['error'] ?? 'Error HTTP ${response.statusCode}';
        throw Exception(error);
      }
    } catch (e) {
      print('[DEBUG] Error en resetPassword: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Timeout: El servidor no responde');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Sin conexión a internet');
      } else {
        throw Exception('Error de conexión: $e');
      }
    }
  }
}
