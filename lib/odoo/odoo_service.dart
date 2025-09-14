import 'package:hodorak/constance.dart';
import 'package:hodorak/unknwon_for_database.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class OdooService {
  final String baseUrl;
  final String dbName;
  late final OdooClient client;

  // Store login credentials for re-authentication
  String? _email;
  String? _password;
  bool _isAuthenticated = false;

  OdooService({
    this.baseUrl = OdooDatabase.baseUrl,
    this.dbName = OdooDatabase.kNameDatabase,
  }) {
    client = OdooClient(baseUrl);
  }

  /// Login User for Odoo
  Future<void> login(String email, String password) async {
    _email = email.trim();
    _password = password.trim();
    await client.authenticate(dbName, _email!, _password!);
    _isAuthenticated = true;
  }

  /// Re-authenticate if session expired
  Future<void> _reAuthenticate() async {
    if (_email != null && _password != null) {
      try {
        await client.authenticate(dbName, _email!, _password!);
        _isAuthenticated = true;
      } catch (e) {
        _isAuthenticated = false;
        throw Exception('Re-authentication failed: $e');
      }
    } else {
      throw Exception('No stored credentials for re-authentication');
    }
  }

  /// Execute Odoo call with automatic re-authentication on session expiry
  Future<dynamic> _executeWithRetry(
    Future<dynamic> Function() operation,
  ) async {
    try {
      return await operation();
    } on OdooSessionExpiredException {
      print('Session expired, attempting re-authentication...');
      await _reAuthenticate();
      // Retry the operation once after re-authentication
      return await operation();
    } catch (e) {
      rethrow;
    }
  }

  /// Read the latest attendance records
  Future<List<Map<String, dynamic>>> fetchAttendance({int limit = 20}) async {
    final result = await _executeWithRetry(() async {
      return await client.callKw({
        'model': Constance.model,
        'method': Constance.methodSearchRead,
        'args': [
          [], // no domain (كل السجلات)
        ],
        'kwargs': {
          'fields': ['employee_id', 'check_in', 'check_out'],
          'order': 'check_in desc',
          'limit': limit,
        },
      });
    });
    return List<Map<String, dynamic>>.from(result);
  }

  /// Check-in for one employee
  Future<int> checkIn(int employeeId) async {
    final now = _odooDateTime();
    final createdId = await _executeWithRetry(() async {
      return await client.callKw({
        'model': Constance.model,
        'method': Constance.methodCreate,
        'args': [
          {'employee_id': employeeId, 'check_in': now},
        ],
        'kwargs': {},
      });
    });
    return createdId as int;
  }

  /// Check-out: بيقفل آخر حضور مفتوح لنفس الموظف (لو موجود)
  Future<bool> checkOut(int employeeId) async {
    // دور على سجل مفتوح (check_out = false/null)
    final ids = await _executeWithRetry(() async {
      return await client.callKw({
        'model': Constance.model,
        'method': Constance.methodSearch,
        'args': [
          [
            ['employee_id', '=', employeeId],
            ['check_out', '=', false],
          ],
        ],
        'kwargs': {'order': 'check_in desc', 'limit': 1},
      });
    });

    final List found = ids is List ? ids : [];
    if (found.isEmpty) return false;

    final now = _odooDateTime();
    final ok = await _executeWithRetry(() async {
      return await client.callKw({
        'model': Constance.model,
        'method': Constance.methodWrite,
        'args': [
          found, // [attendance_id]
          {'check_out': now},
        ],
        'kwargs': {},
      });
    });
    return (ok == true);
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _isAuthenticated;

  /// Get stored email
  String? get email => _email;

  /// Logout and clear credentials
  Future<void> logout() async {
    _email = null;
    _password = null;
    _isAuthenticated = false;
    // Note: OdooClient doesn't have a logout method,
    // but clearing credentials prevents further operations
  }

  /// Test connection to Odoo server
  Future<bool> testConnection() async {
    try {
      // Try to get server version info
      await client.callKw({
        'model': 'ir.config_parameter',
        'method': 'get_param',
        'args': ['database.uuid'],
        'kwargs': {},
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// صيغة وقت مناسبة لأودو: "YYYY-MM-DD HH:MM:SS"
  String _odooDateTime() {
    final dt = DateTime.now().toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
        '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
  }
}
