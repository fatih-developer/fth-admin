import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fth_admin/features/auth/presentation/bloc/auth_event.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fth_admin/core/models/user_model.dart';
import 'package:fth_admin/core/services/hive_service.dart';
import 'package:fth_admin/core/theme/theme_service.dart';
import 'package:fth_admin/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:fth_admin/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fth_admin/features/auth/domain/usecases/login_usecase.dart';
import 'package:fth_admin/features/auth/domain/usecases/register_usecase.dart';
import 'package:fth_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fth_admin/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Temel servisleri başlat
  await ThemeService.initTheme();
  
  // Hive'ı başlat
  await Hive.initFlutter();
  
  // Hive adapter'larını kaydet
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserModelAdapter());
  }
  
  // Hive servisini başlat
  await HiveService.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth Bloc
        BlocProvider<AuthBloc>(
          create: (context) {
            final authRepository = AuthRepositoryImpl(
              localDataSource: AuthLocalDataSource(),
            );
            
            return AuthBloc(
              loginUseCase: LoginUseCase(authRepository),
              registerUseCase: RegisterUseCase(authRepository),
              authRepository: authRepository,
            )..add(CheckAuthStatusEvent());
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          return AdaptiveTheme(
            light: ThemeService.lightTheme,
            dark: ThemeService.darkTheme,
            initial: ThemeService.isDarkMode ? AdaptiveThemeMode.dark : AdaptiveThemeMode.light,
            builder: (theme, darkTheme) {
              return MaterialApp.router(
                title: 'FTH Admin',
                debugShowCheckedModeBanner: false,
                theme: theme,
                darkTheme: darkTheme,
                routerConfig: router,
              );
            },
          );
        },
      ),
    );
  }
}
