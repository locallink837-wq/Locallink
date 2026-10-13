import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/widgets/ui_kit.dart';
import '../data/auth_repository.dart';
import '../state/auth_flow.dart';
import '../state/auth_validators.dart';
import '../widgets/auth_widgets.dart';

/// Verify phone
/// Module 1 - Auth and onboarding  |  Owner: A
/// Phone number + 6 digit OTP (Firebase Phone Auth). Signs the person in.
class VerifyPhoneView extends StatefulWidget {
  const VerifyPhoneView({super.key});

  static const route = '/auth/verify-phone';

  @override
  State<VerifyPhoneView> createState() => _VerifyPhoneViewState();
}

class _VerifyPhoneViewState extends State<VerifyPhoneView> {
  static const _repo = AuthRepository();
  static const _resendSeconds = 30;

  final _phone = TextEditingController();
  final _otp = TextEditingController();

  String? _verificationId;
  int? _resendToken;
  bool _busy = false;
  String? _error;
  int _secondsLeft = 0;
  Timer? _timer;

  bool get _codeSent => _verificationId != null;

  @override
  void dispose() {
    _timer?.cancel();
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _sendOtp() async {
    if (!AuthValidators.isIndianMobile(_phone.text)) {
      setState(() => _error = 'Enter a valid 10-digit mobile number.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    await _repo.sendOtp(
      phoneE164: AuthValidators.toE164(_phone.text),
      resendToken: _resendToken,
      onCodeSent: (id, token) {
        if (!mounted) return;
        setState(() {
          _verificationId = id;
          _resendToken = token;
          _busy = false;
        });
        _startCountdown();
      },
      onFailed: (message) {
        if (!mounted) return;
        setState(() {
          _error = message;
          _busy = false;
        });
      },
      onAutoVerified: () async {
        if (!mounted) return;
        await _finishSignIn();
      },
    );
  }

  Future<void> _verify() async {
    final code = AuthValidators.digitsOnly(_otp.text);
    if (code.length != 6) {
      setState(() => _error = 'Enter the 6 digit OTP.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _repo.confirmOtp(verificationId: _verificationId!, smsCode: code);
      if (!mounted) return;
      await _finishSignIn();
    } catch (e) {
      if (mounted) setState(() => _error = AuthRepository.friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _finishSignIn() async {
    try {
      await AuthFlow.afterSignIn(context, _repo);
    } catch (e) {
      if (mounted) setState(() => _error = AuthRepository.friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: uiFeatureTheme(context, UiColors.teal),
      child: UiScaffold(
        title: 'Verify phone',
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const AuthHero(
                icon: Icons.sms_outlined,
                title: 'Verify your phone',
                subtitle: 'We will send a 6 digit code by SMS.',
              ),
              const SizedBox(height: 24),
              UiTextInput(
                label: 'Phone number',
                controller: _phone,
                keyboardType: TextInputType.phone,
                enabled: !_codeSent && !_busy,
                hintText: '10-digit mobile number',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 14, right: 8),
                  child: Center(
                    widthFactor: 1,
                    child: Text('+91', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              UiTextInput(
                label: '6 digit OTP',
                controller: _otp,
                keyboardType: TextInputType.number,
                enabled: _codeSent && !_busy,
                hintText: '------',
              ),
              AuthErrorBanner(_error),
              const SizedBox(height: 18),
              UiMainButton(
                label: _codeSent ? 'Verify' : 'Send OTP',
                isLoading: _busy,
                onPressed: _busy ? null : (_codeSent ? _verify : _sendOtp),
              ),
              if (_codeSent) ...[
                const SizedBox(height: 8),
                Center(
                  child: _secondsLeft > 0
                      ? uiText('Resend in ${_secondsLeft}s',
                          size: 12.5, weight: FontWeight.w600, color: UiColors.muted)
                      : TextButton(
                          onPressed: _busy ? null : _sendOtp,
                          child: uiText('Resend OTP',
                              size: 13, weight: FontWeight.w700, color: UiColors.teal),
                        ),
                ),
                Center(
                  child: TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                              _verificationId = null;
                              _resendToken = null;
                              _otp.clear();
                              _error = null;
                              _timer?.cancel();
                              _secondsLeft = 0;
                            }),
                    child: uiText('Change number',
                        size: 12.5, weight: FontWeight.w700, color: UiColors.muted),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}