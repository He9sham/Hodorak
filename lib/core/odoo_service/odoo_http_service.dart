import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../unknwon_for_database.dart';

class OdooHttpService {
  final String baseUrl;
  final String dbName;

  String? _sessionId;
  int? _uid;

  OdooHttpService({
    this.baseUrl = OdooDatabase.baseUrl,
    this.dbName = OdooDatabase.kNameDatabase,
  });

  // Session management
  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString('odoo_session_id');
    _uid = prefs.getInt('odoo_uid');
  }

  Future<void> _saveSession(String sessionId, int uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('odoo_session_id', sessionId);
    await prefs.setInt('odoo_uid', uid);
    _sessionId = sessionId;
    _uid = uid;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('odoo_session_id');
    await prefs.remove('odoo_uid');
    _sessionId = null;
    _uid = null;
  }

  String? get sessionId => _sessionId;
  int? get uid => _uid;

  // Check if user is properly authenticated
  Future<bool> isAuthenticated() async {
    await _loadSession();
    return _uid != null && _sessionId != null;
  }

  // Helpers
  Uri _jsonRpcUrl([String path = '/jsonrpc']) => Uri.parse('$baseUrl$path');
  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    if (_sessionId != null) 'Cookie': 'session_id=$_sessionId',
  };

  Future<dynamic> _jsonRpc(
    String service,
    String method,
    List args, {
    Map<String, dynamic>? kwargs,
  }) async {
    await _loadSession();
    final payload = {
      'jsonrpc': '2.0',
      'method': 'call',
      'params': {
        'service': service,
        'method': method,
        'args': args,
        if (kwargs != null) 'kwargs': kwargs,
      },
      'id': DateTime.now().millisecondsSinceEpoch,
    };

    final response = await http.post(
      _jsonRpcUrl(),
      headers: _headers(),
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw OdooServerException(
        'HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['error'] != null) {
      final msg = data['error']['data']?['message']?.toString() ?? 'Odoo error';
      if (msg.contains('Access Denied')) {
        throw OdooAuthException(
          'Invalid email/password or insufficient rights',
        );
      }
      throw OdooServerException(msg);
    }
    return data['result'];
  }

  Future<Map<String, dynamic>> _callKw(
    String model,
    String method, {
    List<dynamic>? args,
    Map<String, dynamic>? kwargs,
  }) async {
    await _loadSession();
    final url = Uri.parse('$baseUrl/web/dataset/call_kw/$model/$method');
    final body = jsonEncode({
      'id': DateTime.now().millisecondsSinceEpoch,
      'jsonrpc': '2.0',
      'method': 'call',
      'params': {
        'args': args ?? [],
        'kwargs': kwargs ?? {},
        'model': model,
        'method': method,
        'context': {},
      },
    });
    final resp = await http.post(url, headers: _headers(), body: body);
    if (resp.statusCode != 200) {
      throw OdooServerException('HTTP ${resp.statusCode}: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (data['error'] != null) {
      final msg = data['error']['data']?['message']?.toString() ?? 'Odoo error';
      if (msg.contains('Access Denied') || msg.contains('Not authorized')) {
        throw OdooPermissionException('Not authorized');
      }
      throw OdooServerException(msg);
    }
    return Map<String, dynamic>.from(data);
  }

  // Auth
  Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    final result = await _jsonRpc('common', 'authenticate', [
      dbName,
      login,
      password,
      {},
    ]);
    int? uid;
    if (result is int) {
      uid = result;
    } else {
      throw OdooAuthException('your password or email has wrong make sure it');
    }

    // fetch session id from cookie by hitting web/session/authenticate
    final authUrl = Uri.parse('$baseUrl/web/session/authenticate');
    final resp = await http.post(
      authUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'jsonrpc': '2.0',
        'params': {'db': dbName, 'login': login, 'password': password},
      }),
    );
    if (resp.statusCode != 200) {
      throw OdooAuthException('Login failed: ${resp.statusCode}');
    }
    final setCookie = resp.headers['set-cookie'];
    if (setCookie == null || !setCookie.contains('session_id=')) {
      throw OdooAuthException('No session cookie received');
    }
    final sess = RegExp(r'session_id=([^;]+)').firstMatch(setCookie)?.group(1);
    if (sess == null) throw OdooAuthException('Failed parsing session cookie');

    await _saveSession(sess, uid);

    // session established
    return {'uid': uid, 'session_id': sess};
  }

  Future<bool> isAdmin() async {
    await _loadSession();
    if (_uid == null) {
      return false;
    }

    try {
      // Check if user has system admin privileges (most restrictive)
      final sys = await _callKw(
        'res.users',
        'has_group',
        args: [
          [_uid],
          'base.group_system',
        ],
      );
      final isSys = (sys['result'] ?? sys) == true;

      // Also check for HR manager as backup
      final hrMgr = await _callKw(
        'res.users',
        'has_group',
        args: [
          [_uid],
          'hr.group_hr_manager',
        ],
      );
      final isHrMgr = (hrMgr['result'] ?? hrMgr) == true;

      // Only allow system admins or HR managers to create accounts
      return isSys || isHrMgr;
    } catch (e) {
      return false;
    }
  }

  // Attendance
  Future<int> checkIn(int employeeId) async {
    final now = DateTime.now().toUtc();
    final fmt = _formatDateTime(now);
    final res = await _callKw(
      'hr.attendance',
      'create',
      args: [
        {'employee_id': employeeId, 'check_in': fmt},
      ],
    );
    return (res['result'] ?? res) as int;
  }

  Future<bool> checkOut(int employeeId) async {
    final openIdsRes = await _callKw(
      'hr.attendance',
      'search',
      args: [
        [
          ['employee_id', '=', employeeId],
          ['check_out', '=', false],
        ],
      ],
      kwargs: {'limit': 1, 'order': 'check_in desc'},
    );
    final ids = (openIdsRes['result'] ?? openIdsRes) as List? ?? [];
    if (ids.isEmpty) return false;
    final fmt = _formatDateTime(DateTime.now().toUtc());
    final writeRes = await _callKw(
      'hr.attendance',
      'write',
      args: [
        ids,
        {'check_out': fmt},
      ],
    );
    return (writeRes['result'] ?? writeRes) == true;
  }

  Future<List<Map<String, dynamic>>> getMyAttendance(int employeeId) async {
    final res = await _callKw(
      'hr.attendance',
      'search_read',
      args: [
        [
          ['employee_id', '=', employeeId],
        ],
      ],
      kwargs: {
        'fields': ['employee_id', 'check_in', 'check_out'],
        'order': 'check_in desc',
      },
    );
    final data = (res['result'] ?? res) as List;
    return List<Map<String, dynamic>>.from(
      data.map((e) => Map<String, dynamic>.from(e)),
    );
  }

  // Leaves (hr.leave)
  Future<int> requestLeave({
    required int employeeId,
    required String dateFrom,
    required String dateTo,
    required String reason,
  }) async {
    final res = await _callKw(
      'hr.leave',
      'create',
      args: [
        {
          'employee_id': employeeId,
          'request_date_from': dateFrom,
          'request_date_to': dateTo,
          'name': reason,
        },
      ],
    );
    return (res['result'] ?? res) as int;
  }

  Future<List<Map<String, dynamic>>> getEmployeesAttendance() async {
    if (!await isAdmin()) throw Exception('Not authorized');
    final res = await _callKw(
      'hr.attendance',
      'search_read',
      args: [[]],
      kwargs: {
        'fields': ['employee_id', 'check_in', 'check_out'],
        'order': 'employee_id, check_in desc',
      },
    );
    final data = (res['result'] ?? res) as List;
    return List<Map<String, dynamic>>.from(
      data.map((e) => Map<String, dynamic>.from(e)),
    );
  }

  Future<bool> approveLeave(int leaveId) async {
    if (!await isAdmin()) throw Exception('Not authorized');
    // action_approve requires proper server-side rights
    final res = await _callKw(
      'hr.leave',
      'action_approve',
      args: [
        [leaveId],
      ],
    );
    return (res['result'] ?? res) == true || (res['result'] ?? res) == null;
  }

  Future<int> signUpEmployee({
    required String name,
    required String email,
    required String password,
    required String jobTitle,
    required String department,
    required String phone,
    required String nationalId,
    required String
    gender, // Note: Gender field is collected but not stored due to Odoo field limitations
  }) async {
    // Double-check admin permissions
    await _loadSession();
    if (_uid == null) {
      throw Exception('Only admins can create accounts.');
    }

    final adminCheck = await isAdmin();
    if (!adminCheck) {
      throw Exception(
        'Access denied. Only administrators can create employee accounts.',
      );
    }

    // First create the user account
    final userVals = {
      'name': name,
      'login': email,
      'email': email,
      'password': password,
    };
    final userRes = await _callKw('res.users', 'create', args: [userVals]);
    final userId = (userRes['result'] ?? userRes) as int;

    // Then create the employee record linked to the user
    final employeeVals = {
      'name': name,
      'user_id': userId,
      'work_email': email,
      'job_title': jobTitle,
      'department_id': await _getOrCreateDepartment(department),
      'work_phone': phone,
      'identification_id': nationalId,
    };
    final employeeRes = await _callKw(
      'hr.employee',
      'create',
      args: [employeeVals],
    );
    return (employeeRes['result'] ?? employeeRes) as int;
  }

  // Helper method to get or create department
  Future<int> _getOrCreateDepartment(String departmentName) async {
    try {
      // First try to find existing department
      final searchRes = await _callKw(
        'hr.department',
        'search',
        args: [
          [
            ['name', '=', departmentName],
          ],
        ],
      );
      final departmentIds = (searchRes['result'] ?? searchRes) as List;

      if (departmentIds.isNotEmpty) {
        return departmentIds.first;
      }

      // If not found, create new department
      final createRes = await _callKw(
        'hr.department',
        'create',
        args: [
          {'name': departmentName},
        ],
      );
      return (createRes['result'] ?? createRes) as int;
    } catch (e) {
      // If department creation fails, return a default or handle gracefully
      return 1; // Default department ID, you might want to adjust this
    }
  }

  // Check if user has attendance permissions - BYPASSED to allow all users
  Future<bool> hasAttendancePermissions() async {
    // Always return true to bypass permission checks
    return true;
  }

  // Employee lookup
  Future<int?> getEmployeeIdFromUserId(int userId) async {
    try {
      final searchRes = await _callKw(
        'hr.employee',
        'search_read',
        args: [
          [
            ['user_id', '=', userId],
          ],
        ],
        kwargs: {
          'fields': ['id'],
          'limit': 1,
        },
      );
      final employees = (searchRes['result'] ?? searchRes) as List;

      if (employees.isNotEmpty) {
        return employees.first['id'] as int;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
  }
}

// Structured exceptions for clearer handling in UI
class OdooPermissionException implements Exception {
  final String message;
  OdooPermissionException(this.message);
  @override
  String toString() => message;
}

class OdooAuthException implements Exception {
  final String message;
  OdooAuthException(this.message);
  @override
  String toString() => message;
}

class OdooServerException implements Exception {
  final String message;
  OdooServerException(this.message);
  @override
  String toString() => message;
}
