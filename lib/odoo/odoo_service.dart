import 'package:hodorak/constance.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class OdooService {
  final String baseUrl;
  final String dbName;
  late final OdooClient _client;

  OdooService({
    this.baseUrl = 'https://heshamhemdan1.odoo.com',
    this.dbName = 'heshamhemdan1',
  }) {
    _client = OdooClient(baseUrl);
  }

  /// Login User for Odoo
  Future<void> login(String email, String password) async {
    await _client.authenticate(dbName, email.trim(), password.trim());
  }

  /// Read the latest attendance records
  Future<List<Map<String, dynamic>>> fetchAttendance({int limit = 20}) async {
    final result = await _client.callKw({
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
    return List<Map<String, dynamic>>.from(result);
  }

  /// Check-in for one employee
  Future<int> checkIn(int employeeId) async {
    final now = _odooDateTime();
    final createdId = await _client.callKw({
      'model': Constance.model,
      'method': Constance.methodCreate,
      'args': [
        {'employee_id': employeeId, 'check_in': now},
      ],
      'kwargs': {},
    });
    return createdId as int;
  }

  /// Check-out: بيقفل آخر حضور مفتوح لنفس الموظف (لو موجود)
  Future<bool> checkOut(int employeeId) async {
    // دور على سجل مفتوح (check_out = false/null)
    final ids = await _client.callKw({
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

    final List found = ids is List ? ids : [];
    if (found.isEmpty) return false;

    final now = _odooDateTime();
    final ok = await _client.callKw({
      'model': Constance.model,
      'method': Constance.methodWrite,
      'args': [
        found, // [attendance_id]
        {'check_out': now},
      ],
      'kwargs': {},
    });
    return (ok == true);
  }

  /// صيغة وقت مناسبة لأودو: "YYYY-MM-DD HH:MM:SS"
  String _odooDateTime() {
    final dt = DateTime.now().toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
        '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
  }
}
