import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fth_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fth_admin/features/auth/presentation/bloc/auth_state.dart';
import 'package:fth_admin/features/auth/presentation/widgets/login_form.dart';
import 'package:fth_admin/features/auth/presentation/widgets/register_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showRegisterForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Kullanıcı giriş yaptıktan sonra ana sayfaya yönlendir
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'FTH Admin',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _showRegisterForm
                            ? 'Hesap oluşturun'
                            : 'Hesabınıza giriş yapın',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 32),
                      _showRegisterForm
                          ? RegisterForm(
                              onLoginClicked: () {
                                setState(() {
                                  _showRegisterForm = false;
                                });
                              },
                              onSuccess: () {
                                setState(() {
                                  _showRegisterForm = false;
                                });
                              },
                            )
                          : LoginForm(
                              onRegisterClicked: () {
                                setState(() {
                                  _showRegisterForm = true;
                                });
                              },
                              onForgotPassword: (email) {
                                // Şifre sıfırlama işlemi
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi'),
                                  ),
                                );
                              },
                            ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
