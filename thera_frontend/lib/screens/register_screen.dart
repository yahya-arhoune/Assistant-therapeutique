import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  final passwordController = TextEditingController();
  String _selectedRole = 'USER';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: ['USER', 'ADMIN']
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedRole = val!),
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await AuthService().register(
                    nameController.text,
                    emailController.text,
                    passwordController.text,
                    _selectedRole,
                  );
                  if (!context.mounted) return;
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Registration successful! Please login.')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Registration failed: $e')),
                  );
                }
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
