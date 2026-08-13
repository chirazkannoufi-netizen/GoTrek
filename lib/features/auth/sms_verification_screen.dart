import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/feedback.dart';
import '../../data/models/user_account.dart';
import '../../data/repositories/auth_repository.dart';
import '../../state/auth_controller.dart';
import '../../state/repository_providers.dart';
import 'sign_up_success_screen.dart';

/// Four-digit confirmation with the on-screen keypad from the original design.
class SmsVerificationScreen extends ConsumerStatefulWidget {
  const SmsVerificationScreen({
    super.key,
    required this.pending,
    this.returnOnSuccess = false,
  });

  final PendingSignUp pending;

  /// See [LoginScreen.returnOnSuccess].
  final bool returnOnSuccess;

  @override
  ConsumerState<SmsVerificationScreen> createState() =>
      _SmsVerificationScreenState();
}

class _SmsVerificationScreenState extends ConsumerState<SmsVerificationScreen> {
  static const int _codeLength = 4;

  late PendingSignUp _pending = widget.pending;
  String _entered = '';
  bool _isVerifying = false;

  bool get _isComplete => _entered.length == _codeLength;

  void _append(String digit) {
    if (_entered.length >= _codeLength || _isVerifying) return;
    setState(() => _entered += digit);
    if (_isComplete) _verify();
  }

  void _backspace() {
    if (_entered.isEmpty || _isVerifying) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _verify() async {
    if (!_isComplete || _isVerifying) return;
    setState(() => _isVerifying = true);

    await ref
        .read(authControllerProvider.notifier)
        .confirmSignUp(pending: _pending, code: _entered);
    if (!mounted) return;

    final UserAccount? user = ref.read(currentUserProvider);
    if (user == null) {
      setState(() {
        _entered = '';
        _isVerifying = false;
      });
      showMessage(context, 'That code is not correct. Try again.');
      return;
    }

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder:
            (_) => SignUpSuccessScreen(returnOnSuccess: widget.returnOnSuccess),
      ),
    );
  }

  Future<void> _resend() async {
    final PendingSignUp refreshed = await ref
        .read(authRepositoryProvider)
        .startSignUp(fullName: _pending.fullName, contact: _pending.contact);
    if (!mounted) return;
    setState(() {
      _pending = refreshed;
      _entered = '';
    });
    showMessage(context, 'A new code has been issued.');
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm your number')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl,
                      vertical: AppSpacing.xxl,
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Enter the code',
                          style: theme.textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Confirming your account for',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          _pending.contact,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _DemoCodeBanner(code: _pending.code),
                        const SizedBox(height: AppSpacing.xxl),
                        _CodeBoxes(length: _codeLength, entered: _entered),
                        const SizedBox(height: AppSpacing.xxl),
                        FilledButton(
                          onPressed:
                              _isComplete && !_isVerifying ? _verify : null,
                          child:
                              _isVerifying
                                  ? const SizedBox.square(
                                    dimension: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text('Confirm'),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          onPressed: _isVerifying ? null : _resend,
                          child: const Text('Send a new code'),
                        ),
                      ],
                    ),
                  ),
                ),
                _Keypad(onDigit: _append, onBackspace: _backspace),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The code is generated on-device because there is no SMS gateway. Showing
/// it keeps the flow usable without pretending a message was sent.
class _DemoCodeBanner extends StatelessWidget {
  const _DemoCodeBanner({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: AppRadius.allMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.info_outline,
            size: 18,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              'No SMS gateway in this build — your code is $code',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeBoxes extends StatelessWidget {
  const _CodeBoxes({required this.length, required this.entered});

  final int length;
  final String entered;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int index = 0; index < length; index++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: AnimatedContainer(
              duration: AppDurations.fast,
              width: 60,
              height: 68,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLowest,
                borderRadius: AppRadius.allMd,
                border: Border.all(
                  color:
                      index == entered.length
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                  width: index == entered.length ? 2 : 1,
                ),
              ),
              child: Text(
                index < entered.length ? entered[index] : '',
                style: theme.textTheme.headlineSmall,
              ),
            ),
          ),
      ],
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onDigit, required this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final List<String> row in const <List<String>>[
            <String>['1', '2', '3'],
            <String>['4', '5', '6'],
            <String>['7', '8', '9'],
            <String>['', '0', 'back'],
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  for (final String key in row)
                    _KeypadKey(
                      value: key,
                      onDigit: onDigit,
                      onBackspace: onBackspace,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _KeypadKey extends StatelessWidget {
  const _KeypadKey({
    required this.value,
    required this.onDigit,
    required this.onBackspace,
  });

  final String value;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (value.isEmpty) return const SizedBox(width: 76, height: 56);

    final bool isBackspace = value == 'back';

    return SizedBox(
      width: 76,
      height: 56,
      child: Material(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.allMd,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isBackspace ? onBackspace : () => onDigit(value),
          child: Center(
            child:
                isBackspace
                    ? const Icon(Icons.backspace_outlined, size: 22)
                    : Text(value, style: theme.textTheme.headlineSmall),
          ),
        ),
      ),
    );
  }
}
