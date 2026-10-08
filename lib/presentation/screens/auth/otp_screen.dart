import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app_colors.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_heading.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../router/app_router.dart';

class OtpScreen extends StatefulWidget {
  final String phone;

  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const otpLength = 4;

  final cs = List.generate(otpLength, (_) => TextEditingController());
  final ns = List.generate(otpLength, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in cs) {
      c.dispose();
    }
    for (final n in ns) {
      n.dispose();
    }
    super.dispose();
  }

  void verify() {
    final otp = cs.map((e) => e.text).join();
    if (otp.length != otpLength) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter the 4-digit OTP')));
      return;
    }
    context.read<AuthBloc>().add(OtpRequested(widget.phone, otp));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.heading,
      ),
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
                }
                if (s.status == AuthStatus.authenticated) {
                  Navigator.pushNamedAndRemoveUntil(
                    c,
                    AppRouter.home,
                    (_) => false,
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 28),
                    const AppHeading(text: 'Enter OTP', fontSize: 30),
                    const SizedBox(height: 8),
                    Text(
                      'We sent a 4-digit code to +91 ${widget.phone}',
                      style: const TextStyle(color: AppColors.subheading),
                    ),
                    const SizedBox(height: 30),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final boxSize =
                            ((constraints.maxWidth - 30) / otpLength)
                                .clamp(52.0, 60.0)
                                .toDouble();

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            otpLength,
                            (i) => Padding(
                              padding: EdgeInsets.only(
                                right: i == otpLength - 1 ? 0 : 10,
                              ),
                              child: SizedBox.square(
                                dimension: boxSize,
                                child: TextField(
                                  controller: cs[i],
                                  focusNode: ns[i],
                                  maxLength: 1,
                                  textAlign: TextAlign.center,
                                  textAlignVertical: TextAlignVertical.center,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    contentPadding: EdgeInsets.zero,
                                    fillColor: Colors.white.withValues(
                                      alpha: 0.86,
                                    ),
                                  ),
                                  onChanged: (v) {
                                    if (v.isNotEmpty && i < otpLength - 1) {
                                      ns[i + 1].requestFocus();
                                    }
                                    if (v.isEmpty && i > 0) {
                                      ns[i - 1].requestFocus();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Resend OTP in 00:30',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.grey),
                    ),
                    const SizedBox(height: 28),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (c, s) => AppButton(
                        text: 'Verify & Continue',
                        loading: s.loading,
                        onPressed: verify,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        'Your account is protected with secure OTP authentication.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.grey, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
