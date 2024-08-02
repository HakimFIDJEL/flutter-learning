import 'package:flutter/material.dart';
import 'package:learning_dart/constants/routes.dart';
import 'package:learning_dart/services/auth/auth_service.dart';
import 'package:learning_dart/utilities/show_success_dialog.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Column(
        children: [
          const Text(
            "We have sent you an email to verify your email address.",
          ),
          const Text(
            "If you haven't received the email, please press the button below.",
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
              await showSuccessDialog(
                context,
                "Email verification sent",
              );
            },
            child: const Text("Send email verification"),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
                (route) => false,
              );
            },
            child: const Text("Go to Login"),
          ),
        ],
      ),
    );
  }
}
