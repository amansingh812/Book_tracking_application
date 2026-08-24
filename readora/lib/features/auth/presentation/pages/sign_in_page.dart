import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/widgets/paper_card.dart';
import 'package:readora/features/auth/presentation/bloc/auth_bloc.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final bloc = context.read<AuthBloc>();
    if (_isCreating) {
      bloc.add(
        AuthSignUpRequested(
          email: _email.text,
          password: _password.text,
          displayName: _name.text.isEmpty ? null : _name.text,
        ),
      );
    } else {
      bloc.add(AuthSignInRequested(email: _email.text, password: _password.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isCreating ? 'Create your account' : 'Welcome back')),
      body: AmbientBackground(
        child: BlocConsumer<AuthBloc, AuthState>(
          listenWhen: (a, b) => a.failure != b.failure || a.infoMessage != b.infoMessage,
          listener: (context, state) {
            final message = state.failure?.message ?? state.infoMessage;
            if (message == null) return;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          },
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: Spacing.xl),
                      if (_isCreating) ...[
                        TextFormField(
                          controller: _name,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(labelText: 'Your name (optional)'),
                        ),
                        const SizedBox(height: Spacing.md),
                      ],
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (v) => (v ?? '').contains('@')
                            ? null
                            : 'Enter a valid email address',
                      ),
                      const SizedBox(height: Spacing.md),
                      TextFormField(
                        controller: _password,
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: const InputDecoration(labelText: 'Password'),
                        validator: (v) => (v ?? '').length >= 8
                            ? null
                            : 'Use at least 8 characters',
                      ),
                      const SizedBox(height: Spacing.xl),
                      FilledButton(
                        onPressed: state.isSubmitting ? null : _submit,
                        child: state.isSubmitting
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_isCreating ? 'Create account' : 'Sign in'),
                      ),
                      const SizedBox(height: Spacing.md),
                      TextButton(
                        onPressed: () => setState(() => _isCreating = !_isCreating),
                        child: Text(
                          _isCreating
                              ? 'I already have an account'
                              : 'New here? Create an account',
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
