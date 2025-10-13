import 'package:flutter/material.dart';
import 'package:hodorak/features/admin_employee_management/presentation/views/unified_sign_up_screen.dart';

class CreateEmployeesScreen extends StatelessWidget {
  const CreateEmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnifiedSignUpScreen(isEmployeeCreation: false);
  }
}
