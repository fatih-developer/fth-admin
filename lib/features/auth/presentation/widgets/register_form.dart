import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fth_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fth_admin/features/auth/presentation/bloc/auth_event.dart';
import 'package:fth_admin/features/auth/presentation/bloc/auth_state.dart';

class RegisterForm extends StatefulWidget {
  final VoidCallback onLoginClicked;
  final VoidCallback onSuccess;

  const RegisterForm({
    Key? key,
    required this.onLoginClicked,
    required this.onSuccess,
  }) : super(key: key);

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, dynamic>(
      listener: (context, state) {
        if (state is Authenticated) {
          widget.onSuccess();
        } else if (state is AuthError) {
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
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Kullanıcı Adı',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen bir kullanıcı adı girin';
                }
                if (value.length < 3) {
                  return 'Kullanıcı adı en az 3 karakter olmalıdır';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
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
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
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
                  return 'Lütfen bir şifre girin';
                }
                if (value.length < 6) {
                  return 'Şifre en az 6 karakter olmalıdır';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Şifre Tekrar',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              obscureText: _obscureConfirmPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen şifrenizi tekrar girin';
                }
                if (value != _passwordController.text) {
                  return 'Şifreler eşleşmiyor';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            BlocBuilder<AuthBloc, dynamic>(
              builder: (context, state) {
                if (state is AuthLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Kayıt Ol'),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Zaten hesabınız var mı?'),
                TextButton(
                  onPressed: widget.onLoginClicked,
                  child: const Text('Giriş Yap'),
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
            RegisterEvent(
              username: _usernameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              confirmPassword: _confirmPasswordController.text,
            ),
          );
    }
  }
}
