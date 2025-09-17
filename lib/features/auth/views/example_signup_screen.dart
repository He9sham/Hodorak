import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/providers/signup_notifier.dart';

class ExampleSignUpScreen extends ConsumerStatefulWidget {
  const ExampleSignUpScreen({super.key});

  @override
  ConsumerState<ExampleSignUpScreen> createState() =>
      _ExampleSignUpScreenState();
}

class _ExampleSignUpScreenState extends ConsumerState<ExampleSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signUpNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Create Employee (Admin)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email/Login'),
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Enter valid email'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) =>
                    (v == null || v.length < 3) ? 'Enter password' : null,
              ),
              const SizedBox(height: 20),
              if (state.error != null)
                Text(state.error!, style: const TextStyle(color: Colors.red)),
              if (state.message != null)
                Text(
                  state.message!,
                  style: const TextStyle(color: Colors.green),
                ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: state.isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        await ref
                            .read(signUpNotifierProvider.notifier)
                            .signUpEmployee(
                              name: _nameController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            );
                      },
                child: state.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
