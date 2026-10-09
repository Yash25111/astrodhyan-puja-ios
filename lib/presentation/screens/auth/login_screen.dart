import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app_colors.dart';
import '../../../utils/validators.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_heading.dart';
import '../../../widgets/app_text_field.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../router/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final c = TextEditingController();
  final key = GlobalKey<FormState>();

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  void submit() {
    if (key.currentState!.validate()) {
      context.read<AuthBloc>().add(LoginRequested(c.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/auth_background.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(color: Color(0xCCFFFCF7)),
          ),
          SafeArea(
            child: BlocListener<AuthBloc, AuthState>(
              listener: (c, s) {
                if (s.error != null) {
                  ScaffoldMessenger.of(
                    c,
                  ).showSnackBar(SnackBar(content: Text(s.error!)));
                } else if (!s.loading && s.phone != null) {
                  Navigator.pushNamed(
                    context,
                    AppRouter.otp,
                    arguments: s.phone,
                  );
                }
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 50),
                      const Center(
                        child: Icon(
                          Icons.local_florist_rounded,
                          size: 62,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const AppHeading(
                        text: 'Welcome',
                        fontSize: 30,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to continue your spiritual journey with divine pujas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.subheading,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 34),
                      AppTextField(
                        controller: c,
                        labelText: 'Mobile Number',
                        hintText: 'Enter your 10-digit mobile number',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 16, right: 8),
                          child: Center(
                            widthFactor: 1,
                            child: Text(
                              '+91',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        validator: Validators.phone,
                      ),
                      const SizedBox(height: 18),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (c, s) => AppButton(
                          text: 'Send OTP',
                          loading: s.loading,
                          width: double.infinity,
                          onPressed: submit,
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Your phone number is used securely for authentication.',
                                style: TextStyle(
                                  color: AppColors.subheading,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
