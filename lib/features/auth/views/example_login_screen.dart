import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hodorak/core/providers/login_notifier.dart';

class ExampleLoginScreen extends ConsumerStatefulWidget {
  const ExampleLoginScreen({super.key});

  @override
  ConsumerState<ExampleLoginScreen> createState() => _ExampleLoginScreenState();
}

class _ExampleLoginScreenState extends ConsumerState<ExampleLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(loginNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
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
              if (session.error != null)
                Text(session.error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: session.isLoading
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        try {
                          final route = await ref
                              .read(loginNotifierProvider.notifier)
                              .login(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              );
                          if (!mounted) return;
                          Navigator.of(context).pushReplacementNamed(route);
                        } catch (_) {}
                      },
                child: session.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
