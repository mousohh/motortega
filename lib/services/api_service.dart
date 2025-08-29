import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = 'https://api-final-8rw7.onrender.com';

  // ================== AUTH ==================
  Future<Map<String, dynamic>> login(String correo, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': correo, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["token"] == null || data["usuario"] == null) {
          throw Exception("Respuesta inválida del servidor");
        }
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

  Future<dynamic> resetPassword(
      String correo, String codigo, String nuevaPassword) async {
    final url = Uri.parse('$baseUrl/api/auth/nueva-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
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

  // ================== USUARIO ==================
  Future<Map<String, dynamic>> obtenerMiPerfil() async {
    final url = Uri.parse('$baseUrl/api/usuarios/mi-perfil');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener perfil');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> actualizarMiPerfil(
      Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/usuarios/mi-perfil');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al actualizar perfil');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// ✅ NUEVO: cambiar contraseña de usuario
  Future<Map<String, dynamic>> cambiarPassword(
      int usuarioId, String actual, String nueva) async {
    final url = Uri.parse('$baseUrl/api/usuarios/$usuarioId/cambiar-password');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "password_actual": actual,
          "nueva_password": nueva,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            jsonDecode(response.body)['message'] ?? 'Error al cambiar contraseña');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ================== VEHÍCULOS ==================
  Future<List<dynamic>> obtenerVehiculos() async {
    final url = Uri.parse('$baseUrl/api/vehiculos');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener vehículos');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<dynamic>> obtenerVehiculosPorCliente(int clienteId) async {
    final url = Uri.parse('$baseUrl/api/vehiculos/cliente/$clienteId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener vehículos del cliente');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> crearVehiculo(
      Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/vehiculos');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) return jsonDecode(response.body);
      throw Exception(
          jsonDecode(response.body)['error'] ?? 'Error al crear vehículo');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> actualizarVehiculo(
      int id, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/vehiculos/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception(jsonDecode(response.body)['error'] ??
          'Error al actualizar vehículo');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> eliminarVehiculo(int id) async {
    final url = Uri.parse('$baseUrl/api/vehiculos/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode != 200) {
        throw Exception(jsonDecode(response.body)['error'] ??
            'Error al eliminar vehículo');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> cambiarEstadoVehiculo(int id) async {
    final url = Uri.parse('$baseUrl/api/vehiculos/$id/cambiar-estado');
    try {
      final response =
          await http.put(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception(jsonDecode(response.body)['error'] ??
          'Error al cambiar estado');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ================== MARCAS Y REFERENCIAS ==================
  Future<List<dynamic>> obtenerMarcas() async {
    final url = Uri.parse('$baseUrl/api/marcas');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener marcas');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<dynamic>> obtenerReferencias() async {
    final url = Uri.parse('$baseUrl/api/referencias');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener referencias');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<dynamic>> obtenerReferenciasPorMarca(int marcaId) async {
    final url = Uri.parse('$baseUrl/api/referencias/marca/$marcaId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener referencias por marca');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ================== CITAS ==================
  Future<List<dynamic>> obtenerCitas() async {
    final url = Uri.parse('$baseUrl/api/citas');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener citas');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<dynamic>> obtenerCitasPorCliente(int clienteId) async {
    final url = Uri.parse('$baseUrl/api/citas/cliente/$clienteId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener citas del cliente');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> obtenerCitaPorId(int id) async {
    final url = Uri.parse('$baseUrl/api/citas/$id');
    try {
      final response = await http.get(url);
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
        headers: {'Content-Type': 'application/json'},
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
        headers: {'Content-Type': 'application/json'},
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
      final response = await http.get(url);
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
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener mecánicos');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ================== VENTAS ==================

  /// Obtener todas las ventas
  Future<List<dynamic>> obtenerVentas() async {
    final url = Uri.parse('$baseUrl/api/ventas');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener ventas');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Crear una nueva venta
  Future<Map<String, dynamic>> crearVenta(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/ventas');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
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

  /// Obtener ventas por cliente
  Future<List<dynamic>> obtenerVentasPorCliente(int clienteId) async {
    final url = Uri.parse('$baseUrl/api/ventas/cliente/$clienteId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener ventas por cliente');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener ventas por estado
  Future<List<dynamic>> obtenerVentasPorEstado(int estadoId) async {
    final url = Uri.parse('$baseUrl/api/ventas/estado/$estadoId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener ventas por estado');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener ventas por rango de fechas
  Future<List<dynamic>> obtenerVentasPorRango(
      String fechaInicio, String fechaFin) async {
    final url = Uri.parse(
        '$baseUrl/api/ventas/rango?fechaInicio=$fechaInicio&fechaFin=$fechaFin');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener ventas por rango');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Cambiar estado de una venta
  Future<Map<String, dynamic>> cambiarEstadoVenta(int id, int estadoId) async {
    final url = Uri.parse('$baseUrl/api/ventas/$id/cambiar-estado');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'estado_venta_id': estadoId}),
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception(
          jsonDecode(response.body)['message'] ?? 'Error al cambiar estado');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Vincular venta con cita
  Future<Map<String, dynamic>> vincularVentaCita(
      int ventaId, int citaId, String observaciones) async {
    final url = Uri.parse('$baseUrl/api/ventas/$ventaId/vincular-cita');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
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

  /// Historial de una venta
  Future<List<dynamic>> obtenerHistorialVenta(int id) async {
    final url = Uri.parse('$baseUrl/api/ventas/$id/historial');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener historial de la venta');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Historial de ventas por cliente
  Future<List<dynamic>> obtenerHistorialVentasPorCliente(int clienteId) async {
    final url = Uri.parse('$baseUrl/api/ventas/historial/cliente/$clienteId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener historial de ventas del cliente');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Historial de ventas por vehículo
  Future<List<dynamic>> obtenerHistorialVentasPorVehiculo(int vehiculoId) async {
    final url = Uri.parse('$baseUrl/api/ventas/historial/vehiculo/$vehiculoId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener historial de ventas del vehículo');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Obtener estados de venta
  Future<List<dynamic>> obtenerEstadosVenta() async {
    final url = Uri.parse('$baseUrl/api/estados-venta');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Error al obtener estados de venta');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
    // ================== DETALLES DE VENTA ==================

  /// Obtener los detalles de una venta
  Future<List<dynamic>> obtenerDetallesVenta(int ventaId) async {
    final url = Uri.parse('$baseUrl/api/detalles-venta/venta/$ventaId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener detalles de la venta');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Agregar un nuevo detalle a la venta
  Future<Map<String, dynamic>> agregarDetalleVenta(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/detalles-venta');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
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

  /// Actualizar un detalle de la venta
  Future<Map<String, dynamic>> actualizarDetalleVenta(int id, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/detalles-venta/$id');
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
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

  /// Eliminar un detalle de la venta
  Future<void> eliminarDetalleVenta(int id) async {
    final url = Uri.parse('$baseUrl/api/detalles-venta/$id');
    try {
      final response = await http.delete(url);
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
      final response = await http.get(url);
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
      final response = await http.get(url);
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
      final response = await http.get(url);
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
