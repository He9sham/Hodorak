import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/services/data_migration_service.dart';
import 'package:hodorak/core/services/supabase_setup_service.dart';

class MigrationAdminScreen extends ConsumerStatefulWidget {
  const MigrationAdminScreen({super.key});

  @override
  ConsumerState<MigrationAdminScreen> createState() =>
      _MigrationAdminScreenState();
}

class _MigrationAdminScreenState extends ConsumerState<MigrationAdminScreen> {
  final DataMigrationService _migrationService = DataMigrationService();
  final SupabaseSetupService _setupService = SupabaseSetupService();
  bool _isLoading = false;
  String _status = 'Ready to migrate';
  Map<String, dynamic> _setupStatus = {};

  @override
  void initState() {
    super.initState();
    _checkSetupStatus();
  }

  Future<void> _checkSetupStatus() async {
    try {
      final status = await _setupService.getSetupStatus();
      setState(() {
        _setupStatus = status;
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to check setup status: $e';
      });
    }
  }

  Future<void> _createAdminUser() async {
    final nameController = TextEditingController(text: 'Admin User');
    final emailController = TextEditingController(text: 'admin@hodorak.com');
    final passwordController = TextEditingController(text: 'admin123456');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Admin User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
        _status = 'Creating admin user...';
      });

      try {
        final success = await _setupService.createAdminUser(
          name: nameController.text,
          email: emailController.text,
          password: passwordController.text,
        );

        if (success) {
          setState(() {
            _status = 'Admin user created successfully!';
          });
          await _checkSetupStatus();
        } else {
          setState(() {
            _status = 'Failed to create admin user';
          });
        }
      } catch (e) {
        setState(() {
          _status = 'Error creating admin user: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _runMigration() async {
    setState(() {
      _isLoading = true;
      _status = 'Starting migration...';
    });

    try {
      await _migrationService.runCompleteMigration();
      setState(() {
        _status = 'Migration completed successfully!';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Migration completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = 'Migration failed: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Migration failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createSampleData() async {
    setState(() {
      _isLoading = true;
      _status = 'Creating sample data...';
    });

    try {
      await _migrationService.migrateUsers();
      await _migrationService.migrateAttendance();
      await _migrationService.migrateCalendarEvents();

      setState(() {
        _status = 'Sample data created successfully!';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample data created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = 'Failed to create sample data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will delete ALL data from the database. This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
        _status = 'Clearing all data...';
      });

      try {
        await _migrationService.clearAllData();
        setState(() {
          _status = 'All data cleared successfully!';
        });
      } catch (e) {
        setState(() {
          _status = 'Failed to clear data: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Migration Admin'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Setup Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_setupStatus.isNotEmpty) ...[
                      Text(
                        'Database Ready: ${_setupStatus['database_ready'] ? '✅' : '❌'}',
                      ),
                      Text('Total Users: ${_setupStatus['total_users']}'),
                      Text('Admin Users: ${_setupStatus['admin_users']}'),
                      if (_setupStatus['needs_admin'] == true)
                        const Text(
                          '⚠️ Admin user needed',
                          style: TextStyle(color: Colors.orange),
                        ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: TextStyle(
                        color:
                            _status.contains('failed') ||
                                _status.contains('Failed')
                            ? Colors.red
                            : _status.contains('success') ||
                                  _status.contains('completed')
                            ? Colors.green
                            : Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Setup Actions
            if (_setupStatus['needs_admin'] == true)
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _createAdminUser,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.admin_panel_settings),
                label: const Text('Create Admin User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

            if (_setupStatus['needs_admin'] == true) const SizedBox(height: 12),

            // Migration Actions
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _runMigration,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload),
              label: const Text('Run Complete Migration'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _createSampleData,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.person_add),
              label: const Text('Create Sample Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _clearAllData,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_forever),
              label: const Text('Clear All Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 24),

            // Instructions
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Run Complete Migration: Migrates all data from Odoo to Supabase\n'
                      '2. Create Sample Data: Creates test data for development\n'
                      '3. Clear All Data: Removes all data (use with caution)\n\n'
                      'Make sure your Supabase configuration is correct before running migration.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
