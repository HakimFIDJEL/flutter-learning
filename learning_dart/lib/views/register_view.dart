// Register view
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:learning_dart/constants/routes.dart';
import 'package:learning_dart/services/auth/auth_exceptions.dart';
import 'package:learning_dart/services/auth/auth_service.dart';
import 'package:learning_dart/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Enter your email here',
            ),
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Enter your password here',
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () async {
                final email = _emailController.text;
                final password = _passwordController.text;

                try {
                  await AuthService.firebase().register(
                    email: email,
                    password: password,
                  );

                  final user = AuthService.firebase().currentUser;

                  if (user != null) {
                    await AuthService.firebase().sendEmailVerification();

                    Navigator.of(context).pushNamedAndRemoveUntil(
                      verifyEmailRoute,
                      (route) => false,
                    );
                  } else {
                    devtools.log('Failed to register user');
                    await showErrorDialog(
                      context,
                      'Failed to register user',
                    );
                  }
                } on WeakPasswordAuthException {
                  await showErrorDialog(
                    context,
                    'Password is too weak',
                  );
                } on EmailAlreadyInUseAuthException {
                  await showErrorDialog(
                    context,
                    'Email is already in use',
                  );
                } on InvalidEmailAuthException {
                  await showErrorDialog(
                    context,
                    'Invalid email',
                  );
                } on GenericAuthException {
                  await showErrorDialog(
                    context,
                    'Failed to register',
                  );
                } catch (e) {
                  devtools.log('Failed to register: $e');

                  await showErrorDialog(
                    context,
                    e.toString(),
                  );
                }
              },
              child: const Text('Register'),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
                (route) => false,
              );
            },
            child: const Text('Already have an account ? Login'),
          ),
        ],
      ),
    );
  }
}
