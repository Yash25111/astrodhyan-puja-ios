import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../app_colors.dart';
import '../../../widgets/app_appbar.dart';
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
  static const resendDuration = 30;

  final otpController = TextEditingController();
  final otpFocusNode = FocusNode();
  Timer? resendTimer;
  int resendSeconds = resendDuration;
  bool resendLoading = false;

  @override
  void initState() {
    super.initState();
    otpController.addListener(_refreshOtpBoxes);
    otpFocusNode.addListener(_refreshOtpBoxes);
    _startResendCountdown(notify: false);
  }

  @override
  void dispose() {
    otpController
      ..removeListener(_refreshOtpBoxes)
      ..dispose();
    otpFocusNode
      ..removeListener(_refreshOtpBoxes)
      ..dispose();
    resendTimer?.cancel();
    super.dispose();
  }

  void _refreshOtpBoxes() {
    if (mounted) setState(() {});
  }

  void verify() {
    final otp = otpController.text;
    if (otp.length != otpLength) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter the 4-digit OTP')));
      return;
    }
    context.read<AuthBloc>().add(OtpRequested(widget.phone, otp));
  }

  void _startResendCountdown({bool notify = true}) {
    resendTimer?.cancel();
    void reset() {
      resendSeconds = resendDuration;
      resendLoading = false;
    }

    if (notify && mounted) {
      setState(reset);
    } else {
      reset();
    }
    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (resendSeconds <= 1) {
        timer.cancel();
        setState(() => resendSeconds = 0);
        return;
      }
      setState(() => resendSeconds--);
    });
  }

  void _resendOtp() {
    if (resendSeconds > 0 || resendLoading) return;
    setState(() => resendLoading = true);
    context.read<AuthBloc>().add(ResendOtpRequested(widget.phone));
  }

  String get _countdownText {
    final minutes = resendSeconds ~/ 60;
    final seconds = resendSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _focusOtpAt(int index) {
    final textLength = otpController.text.length;
    otpFocusNode.requestFocus();
    otpController.selection = index < textLength
        ? TextSelection(baseOffset: index, extentOffset: index + 1)
        : TextSelection.collapsed(offset: textLength);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const AppAppBar(
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
                  if (resendLoading) {
                    setState(() => resendLoading = false);
                  }
                  ScaffoldMessenger.of(
                    c,
                  ).showSnackBar(SnackBar(content: Text(s.error!)));
                } else if (resendLoading && !s.loading) {
                  otpController.clear();
                  _startResendCountdown();
                  ScaffoldMessenger.of(c).showSnackBar(
                    const SnackBar(content: Text('OTP sent again')),
                  );
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

                        final otp = otpController.text;
                        final selection = otpController.selection;
                        final selectedIndex = otpFocusNode.hasFocus
                            ? selection.start.clamp(0, otpLength - 1).toInt()
                            : -1;

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                otpLength,
                                (i) => Padding(
                                  padding: EdgeInsets.only(
                                    right: i == otpLength - 1 ? 0 : 10,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () => _focusOtpAt(i),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 160,
                                      ),
                                      width: boxSize,
                                      height: boxSize,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.86,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: selectedIndex == i
                                              ? AppColors.primary
                                              : AppColors.border,
                                          width: selectedIndex == i ? 1.8 : 1,
                                        ),
                                      ),
                                      child: Text(
                                        i < otp.length ? otp[i] : '',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          height: 1,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: SizedBox(
                                width: 1,
                                height: 1,
                                child: Opacity(
                                  opacity: 0,
                                  child: TextField(
                                    controller: otpController,
                                    focusNode: otpFocusNode,
                                    maxLength: otpLength,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.done,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(
                                        otpLength,
                                      ),
                                    ],
                                    onSubmitted: (_) => verify(),
                                    onTapOutside: (_) => FocusManager
                                        .instance
                                        .primaryFocus
                                        ?.unfocus(),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      counterText: '',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (c, s) {
                        if (resendSeconds > 0) {
                          return Text(
                            'Resend OTP in $_countdownText',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.grey),
                          );
                        }
                        return TextButton(
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: s.loading ? null : _resendOtp,
                          child: Text(
                            resendLoading ? 'Sending OTP...' : 'Resend OTP',
                          ),
                        );
                      },
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
