import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fth_admin/core/models/user_model.dart'; 
import 'package:fth_admin/core/services/hive_service.dart';
import 'package:fth_admin/core/theme/theme_service.dart'; 
import 'package:fth_admin/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:fth_admin/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:fth_admin/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fth_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fth_admin/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:fth_admin/features/auth/domain/usecases/login_usecase.dart';
import 'package:fth_admin/features/auth/domain/usecases/logout_usecase.dart';
import 'package:fth_admin/features/auth/domain/usecases/register_usecase.dart';
import 'package:fth_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fth_admin/features/auth/presentation/bloc/auth_event.dart';
import 'package:fth_admin/routes/app_router.dart'; 
import 'package:fth_admin/routes/auth_bloc_listenable_adapter.dart'; 
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:dio/dio.dart'; 

final GetIt sl = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  
  // Hive Type Adapters kaydı
  if (!Hive.isAdapterRegistered(UserModelAdapter().typeId)) { 
    Hive.registerAdapter(UserModelAdapter());
  }
  // Diğer adaptörler varsa burada kaydedilir

  sl.registerSingleton<HiveService>(HiveService());
  await HiveService.init(); 

  sl.registerLazySingleton(() => Dio());

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      authRepository: sl(), 
    )..add(CheckAuthStatusEvent()), 
  );

  // AuthBlocListenableAdapter'ı kaydet
  sl.registerFactory<AuthBlocListenableAdapter>(
    () => AuthBlocListenableAdapter(sl<AuthBloc>()), // AuthBloc'u parametre olarak geçir
  );

  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  const MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>(),
        ),
        // AuthBlocListenableAdapter için BlocProvider'a gerek yok, GetIt ile yönetiliyor.
      ],
      child: Builder( 
        builder: (context) {
          // AuthBlocListenableAdapter'ı GetIt'ten al
          final authBlocAdapter = sl<AuthBlocListenableAdapter>();
          // Router'ı AuthBlocListenableAdapter ile oluştur
          final appRouter = createAppRouter(authBlocAdapter);

          return AdaptiveTheme(
            light: ThemeService.lightTheme,
            dark: ThemeService.darkTheme,
            initial: savedThemeMode ?? AdaptiveThemeMode.light,
            builder: (theme, darkTheme) => MaterialApp.router(
              title: 'FTH Admin Panel',
              theme: theme,
              darkTheme: darkTheme,
              routerConfig: appRouter, 
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}
