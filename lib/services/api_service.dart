import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = 'https://api-final-8rw7.onrender.com';

  // 📦 storage seguro
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;

  /// Guardar token en memoria y en almacenamiento seguro
  Future<void> setToken(String token) async {
    _token = token;
    await _storage.write(key: 'token', value: token);
    print("✅ Token guardado: $token");
  }

  /// Cargar token guardado
  Future<void> loadToken() async {
    _token = await _storage.read(key: 'token');
    print("📂 Token cargado: $_token");
  }

  /// Eliminar token (logout)
  Future<void> clearToken() async {
    _token = null;
    await _storage.delete(key: 'token');
    print("🗑️ Token eliminado");
  }

  /// Headers comunes
  Map<String, String> _headers({bool withAuth = false}) {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth && _token != null) {
      headers['Authorization'] = '$_token'; // 🔧 Cambio aquí
    }
    print("📋 Headers enviados: $headers");
    return headers;
  }

  // ================== AUTH ==================
  Future<Map<String, dynamic>> login(String correo, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    try {
      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode({'correo': correo, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["token"] == null || data["usuario"] == null) {
          throw Exception("Respuesta inválida del servidor");
        }
        await setToken(data["token"]); // ✅ guardamos token
        return {
          "token": data["token"],
          "usuario": {
            "id": data["usuario"]["id"],
            "nombre": data["usuario"]["nombre"],
            "correo": data["usuario"]["correo"],
            "rol_id": data["usuario"]["rol_id"],
          }
        };
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
        headers: _headers(),
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

  // ================== RECUPERAR CONTRASEÑA ==================
  Future<dynamic> solicitarCodigo(String correo) async {
    final url = Uri.parse('$baseUrl/api/auth/solicitar-codigo');
    try {
      // 👀 DEBUG
      print("📤 [solicitarCodigo] Enviando correo: $correo");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'correo': correo}),
      );

      print("📡 [solicitarCodigo] Respuesta ${response.statusCode}: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body)['message'];
        throw Exception(error ?? 'Error al solicitar código');
      }
    } catch (e) {
      print("❌ [solicitarCodigo] Error: $e");
      throw Exception('Error de conexión: $e');
    }
  }

  Future<dynamic> verificarCodigo(String correo, String codigo) async {
    final url = Uri.parse('$baseUrl/api/auth/verificar-codigo');
    try {
      // 👀 DEBUG
      print("📤 [verificarCodigo] Enviando correo: $correo, código: $codigo");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'correo': correo,
          'codigo': codigo,
        }),
      );

      print("📡 [verificarCodigo] Respuesta ${response.statusCode}: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body)['message'];
        throw Exception(error ?? 'Código inválido o expirado');
      }
    } catch (e) {
      print("❌ [verificarCodigo] Error: $e");
      throw Exception('Error de conexión: $e');
    }
  }

  Future<dynamic> resetPassword(
      String correo, String codigo, String nuevaPassword) async {
    await loadToken(); // 🔧 Asegúrate de cargar el token primero
    final url = Uri.parse('$baseUrl/api/auth/nueva-password');
    try {
      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode({
          'correo': correo,
          'codigo': codigo,
          'nuevaPassword': nuevaPassword,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message'] ??
            'Error al cambiar contraseña');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// ================== USUARIOS ==================
  Future<Map<String, dynamic>> obtenerMiPerfil() async {
    await loadToken();
    final url = Uri.parse('$baseUrl/api/usuarios/mi-perfil');
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));

      print("📡 obtenerMiPerfil - Respuesta (${response.statusCode}): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 🔧 Normalizamos las claves para que Flutter siempre reciba los mismos nombres
        return {
          "id": data["id"] ?? data["usuario"]?["id"],
          "nombre": data["nombre"] ?? data["name"] ?? "",
          "apellido": data["apellido"] ?? "",
          "correo": data["correo"] ?? data["email"] ?? "",
          "tipo_documento": data["tipo_documento"] ?? "",
          "documento": data["documento"] ?? data["document"] ?? "",
          "telefono": data["telefono"] ?? "",
          "direccion": data["direccion"] ?? "",
          "estado": data["estado"] ?? "Activo",
          "rol_id": data["rol_id"] ?? "4",
        };
      } else {
        throw Exception('Error al obtener perfil: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> actualizarMiPerfil(Map<String, dynamic> data) async {
    await loadToken();
    final url = Uri.parse('$baseUrl/api/usuarios/mi-perfil');

    // 👇 Enviar TODOS los campos que tienes en "usuario"
    final body = Map<String, dynamic>.from(data);

    print("📦 Body enviado: ${jsonEncode(body)}");

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$_token', // 👈 ahora con Bearer
      },
      body: jsonEncode(body),
    );

    print("📡 Respuesta actualizar (${response.statusCode}): ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorMsg = jsonDecode(response.body)['error'] ?? 'Error al actualizar perfil';
      throw Exception(errorMsg);
    }
  }

  Future<Map<String, dynamic>> cambiarPassword(
      int usuarioId, String actual, String nueva) async {
    await loadToken(); // 🔧 Asegúrate de cargar el token primero
    final url = Uri.parse('$baseUrl/api/usuarios/$usuarioId/cambiar-password');
    try {
      final response = await http.put(
        url,
        headers: _headers(withAuth: true),
        body: jsonEncode({
          "password_actual": actual,
          "nueva_password": nueva,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message'] ??
            'Error al cambiar contraseña');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ================== VEHÍCULOS ==================
  Future<List<dynamic>> obtenerVehiculos() async {
    await loadToken(); // 🔧 Asegúrate de cargar el token primero
    final url = Uri.parse('$baseUrl/api/vehiculos');
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener vehículos');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> obtenerDetalleVehiculo(int vehiculoId) async {
    await loadToken();
    final url = Uri.parse('$baseUrl/api/vehiculos/cliente/detalle/$vehiculoId');
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));
      print("📡 obtenerDetalleVehiculo - (${response.statusCode}): ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Error al obtener detalle del vehículo');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<dynamic>> obtenerVehiculosPorCliente(int clienteId) async {
    await loadToken(); // 🔧 Asegúrate de cargar el token primero
    final url = Uri.parse('$baseUrl/api/vehiculos/cliente/$clienteId');
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener vehículos del cliente');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> crearMiVehiculo(Map<String, dynamic> data) async {
  await loadToken();
  final url = Uri.parse('$baseUrl/api/vehiculos/cliente/crear');

  final Map<String, dynamic> body = {};
  if (data.containsKey('placa')) body['placa'] = data['placa'];
  if (data.containsKey('color')) body['color'] = data['color'];
  if (data.containsKey('tipo_vehiculo')) body['tipo_vehiculo'] = data['tipo_vehiculo'];
  if (data.containsKey('referencia_id') && data['referencia_id'] != null) body['referencia_id'] = data['referencia_id'];
  if (data.containsKey('estado')) body['estado'] = data['estado'];
  if (data.containsKey('cliente_id')) body['cliente_id'] = data['cliente_id']; // 👈 Faltaba

  print("📦 crearMiVehiculo - Body enviado: ${jsonEncode(body)}");

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': '$_token',
    },
    body: jsonEncode(body),
  );

  print("📡 crearMiVehiculo - Respuesta (${response.statusCode}): ${response.body}");

  if (response.statusCode == 200 || response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    try {
      final parsed = jsonDecode(response.body);
      final errorMsg = parsed['error'] ?? parsed['message'] ?? response.body;
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Error al crear vehículo: ${response.body}');
    }
  }
}


  Future<Map<String, dynamic>> actualizarVehiculo(
      int id, Map<String, dynamic> data) async {
    await loadToken();
    final url = Uri.parse('$baseUrl/api/vehiculos/cliente/editar/$id');
    final response = await http.put(
      url,
      headers: _headers(withAuth: true),
      body: jsonEncode(data),
    );
    
    print("📡 actualizarVehiculo - (${response.statusCode}): ${response.body}");
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar vehículo: ${response.body}');
    }
  }

 Future<void> eliminarVehiculo(int id) async {
  await loadToken();
  final url = Uri.parse('$baseUrl/api/vehiculos/$id'); // 👈 cambio aquí
  try {
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$_token', // 👈 sin Bearer
      },
    );

    print("📡 eliminarVehiculo - (${response.statusCode}): ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Error al eliminar vehículo',
      );
    }
  } catch (e) {
    throw Exception('Error de conexión: $e');
  }
}



  Future<Map<String, dynamic>> cambiarEstadoVehiculo(int id) async {
    final url = Uri.parse('$baseUrl/api/vehiculos/$id/cambiar-estado');
    try {
      final response = await http.put(url, headers: _headers(withAuth: true));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception(
          jsonDecode(response.body)['error'] ?? 'Error al cambiar estado');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ================== MARCAS Y REFERENCIAS ==================
  Future<List<dynamic>> obtenerMarcas() async {
    final url = Uri.parse('$baseUrl/api/marcas');
    await loadToken(); 
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));
      print("📡 obtenerMarcas - (${response.statusCode}): ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      throw Exception('Error al obtener marcas');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<dynamic>> obtenerReferencias() async {
    final url = Uri.parse('$baseUrl/api/referencias');
    await loadToken();
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));
      print("📡 obtenerReferencias - (${response.statusCode}): ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      throw Exception('Error al obtener referencias');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<dynamic>> obtenerReferenciasPorMarca(int marcaId) async {
    final url = Uri.parse('$baseUrl/api/referencias/marca/$marcaId');
    await loadToken();
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));
      print("📡 obtenerReferenciasPorMarca($marcaId) - (${response.statusCode}): ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      throw Exception('Error al obtener referencias por marca');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ================== CITAS ==================
  Future<List<dynamic>> obtenerCitas() async {
    await loadToken(); // 🔧 Asegúrate de cargar el token primero
    final url = Uri.parse('$baseUrl/api/citas');
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener citas');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<dynamic>> obtenerCitasPorCliente(int clienteId) async {
    final url = Uri.parse('$baseUrl/api/citas/cliente/$clienteId');
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener citas del cliente');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> obtenerCitaPorId(int id) async {
    final url = Uri.parse('$baseUrl/api/citas/$id');
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          return Map<String, dynamic>.from(data.first);
        }
        if (data is Map<String, dynamic>) return data;
        throw Exception('Respuesta vacía');
      } else {
        throw Exception(
            jsonDecode(response.body)['message'] ?? 'Error al obtener cita');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> crearCita(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/citas');
    try {
      final response = await http.post(
        url,
        headers: _headers(withAuth: true),
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) return jsonDecode(response.body);
      throw Exception('Error al crear cita');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> cambiarEstadoCita(int id, int estadoId) async {
    final url = Uri.parse('$baseUrl/api/citas/$id/cambiar-estado');
    try {
      final response = await http.put(
        url,
        headers: _headers(withAuth: true),
        body: jsonEncode({'estado_id': estadoId, 'estadoId': estadoId}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception(jsonDecode(response.body)['message'] ??
          'Error al cambiar estado de la cita');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<dynamic>> obtenerEstadosCita() async {
    final url = Uri.parse('$baseUrl/api/estados-cita');
    try {
      final response = await http.get(url, headers: _headers());
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener estados de citas');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ================== MECÁNICOS ==================
  Future<List<dynamic>> obtenerMecanicos() async {
    final url = Uri.parse('$baseUrl/api/mecanicos');
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener mecánicos');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ================== VENTAS ==================
  Future<List<dynamic>> obtenerVentas() async {
    await loadToken(); // 🔧 Asegúrate de cargar el token primero
    final url = Uri.parse('$baseUrl/api/ventas');
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener ventas');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> crearVenta(Map<String, dynamic> data) async {
    await loadToken(); // 🔧 Asegúrate de cargar el token primero
    final url = Uri.parse('$baseUrl/api/ventas');
    try {
      final response = await http.post(
        url,
        headers: _headers(withAuth: true),
        body: jsonEncode(data),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception(
          jsonDecode(response.body)['message'] ?? 'Error al crear venta');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<dynamic>> obtenerVentasPorCliente(int clienteId) async {
    final url = Uri.parse('$baseUrl/api/ventas/cliente/$clienteId');
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener ventas por cliente');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<dynamic>> obtenerVentasPorEstado(int estadoId) async {
    final url = Uri.parse('$baseUrl/api/ventas/estado/$estadoId');
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener ventas por estado');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<dynamic>> obtenerVentasPorRango(
      String fechaInicio, String fechaFin) async {
    final url = Uri.parse(
        '$baseUrl/api/ventas/rango?fechaInicio=$fechaInicio&fechaFin=$fechaFin');
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener ventas por rango');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> cambiarEstadoVenta(int id, int estadoId) async {
    final url = Uri.parse('$baseUrl/api/ventas/$id/cambiar-estado');
    try {
      final response = await http.put(
        url,
        headers: _headers(withAuth: true),
        body: jsonEncode({'estado_venta_id': estadoId}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception(
          jsonDecode(response.body)['message'] ?? 'Error al cambiar estado');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> vincularVentaCita(
      int ventaId, int citaId, String observaciones) async {
    final url = Uri.parse('$baseUrl/api/ventas/$ventaId/vincular-cita');
    try {
      final response = await http.post(
        url,
        headers: _headers(withAuth: true),
        body: jsonEncode({
          'cita_id': citaId,
          'observaciones': observaciones,
        }),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception(
          jsonDecode(response.body)['message'] ?? 'Error al vincular cita');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<dynamic>> obtenerHistorialVenta(int id) async {
    final url = Uri.parse('$baseUrl/api/ventas/$id/historial');
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener historial de la venta');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<dynamic>> obtenerHistorialVentasPorCliente(int clienteId) async {
    final url = Uri.parse('$baseUrl/api/ventas/historial/cliente/$clienteId');
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener historial de ventas del cliente');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<dynamic>> obtenerHistorialVentasPorVehiculo(
      int vehiculoId) async {
    final url = Uri.parse('$baseUrl/api/ventas/historial/vehiculo/$vehiculoId');
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener historial de ventas del vehículo');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<dynamic>> obtenerEstadosVenta() async {
    final url = Uri.parse('$baseUrl/api/estados-venta');
    try {
      final response = await http.get(url, headers: _headers());
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener estados de venta');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ================== DETALLES DE VENTA ==================
  Future<List<dynamic>> obtenerDetallesVenta(int ventaId) async {
    final url = Uri.parse('$baseUrl/api/detalles-venta/venta/$ventaId');
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener detalles de la venta');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> agregarDetalleVenta(
      Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/detalles-venta');
    try {
      final response = await http.post(
        url,
        headers: _headers(withAuth: true),
        body: jsonEncode(data),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al agregar detalle de venta');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> actualizarDetalleVenta(
      int id, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/detalles-venta/$id');
    try {
      final response = await http.put(
        url,
        headers: _headers(withAuth: true),
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al actualizar detalle de venta');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> eliminarDetalleVenta(int id) async {
    final url = Uri.parse('$baseUrl/api/detalles-venta/$id');
    try {
      final response =
          await http.delete(url, headers: _headers(withAuth: true));
      if (response.statusCode != 200) {
        throw Exception('Error al eliminar detalle de venta');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ================== DASHBOARD ==================
  Future<Map<String, dynamic>> obtenerDashboard() async {
    final url = Uri.parse('$baseUrl/api/dashboard/estadisticas');
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener dashboard');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ================== CLIENTES ==================
  Future<List<dynamic>> obtenerClientes() async {
    final url = Uri.parse('$baseUrl/api/clientes');
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener clientes');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> obtenerClientePorId(int id) async {
    final url = Uri.parse('$baseUrl/api/clientes/$id');
    try {
      final response = await http.get(url, headers: _headers(withAuth: true));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener cliente por id');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
