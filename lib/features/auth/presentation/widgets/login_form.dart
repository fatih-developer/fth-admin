import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fth_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fth_admin/features/auth/presentation/bloc/auth_event.dart';
import 'package:fth_admin/features/auth/presentation/bloc/auth_state.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onRegisterClicked;
  final Function(String) onForgotPassword;

  const LoginForm({
    Key? key,
    required this.onRegisterClicked,
    required this.onForgotPassword,
  }) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen e-posta adresinizi girin';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Lütfen geçerli bir e-posta adresi girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Şifre',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen şifrenizi girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => widget.onForgotPassword(_emailController.text),
                child: const Text('Şifremi Unuttum'),
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Giriş Yap'),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Hesabınız yok mu?'),
                TextButton(
                  onPressed: widget.onRegisterClicked,
                  child: const Text('Kayıt Ol'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }
}
