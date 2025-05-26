import 'package:bloc/bloc.dart';
// import 'package:fth_admin/core/models/user_model.dart'; // Kaldırıldı
import 'package:fth_admin/features/auth/domain/usecases/login_usecase.dart';
import 'package:fth_admin/features/auth/domain/usecases/register_usecase.dart';
import 'package:fth_admin/features/auth/presentation/bloc/auth_event.dart';
import 'package:fth_admin/features/auth/presentation/bloc/auth_state.dart';
import 'package:fth_admin/features/auth/domain/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final AuthRepository _authRepository;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required AuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _authRepository = authRepository,
        super(AuthInitial()) {
    on<LoginEvent>(_onLoginEvent);
    on<RegisterEvent>(_onRegisterEvent);
    on<LogoutEvent>(_onLogoutEvent);
    on<CheckAuthStatusEvent>(_onCheckAuthStatusEvent);
  }

  Future<void> _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _loginUseCase(LoginParams(
        email: event.email,
        password: event.password,
      ));
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(Authenticated(user)),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated()); // Genel bir hata durumunda da Unauthenticated state'e geçebiliriz.
    }
  }

  Future<void> _onRegisterEvent(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _registerUseCase(RegisterParams(
        username: event.username,
        email: event.email,
        password: event.password,
        confirmPassword: event.confirmPassword,
      ));

      result.fold(
        (failure) {
          emit(AuthError(failure.message));
          // Başarısız kayıt durumunda Unauthenticated state'e geçebiliriz.
          // Ya da spesifik bir RegistrationFailed state eklenebilir.
          emit(Unauthenticated()); 
        },
        (user) {
          // Kayıt başarılı olduğunda otomatik giriş yap
          // Bu kısım projenizin akışına göre değişebilir.
          // İsterseniz doğrudan Authenticated state'e geçebilirsiniz.
          add(LoginEvent(email: user.email, password: event.password)); 
        },
      );
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogoutEvent(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError('Çıkış yapılırken bir hata oluştu'));
    }
  }

  Future<void> _onCheckAuthStatusEvent(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading()); // Yükleme durumunu yayınla
    try {
      print('[AuthBloc] _onCheckAuthStatusEvent: Kullanıcı durumu kontrol ediliyor...');
      final currentUser = await _authRepository.getCurrentUser();
      print('[AuthBloc] _onCheckAuthStatusEvent: AuthRepository.getCurrentUser() sonucu: ${currentUser?.id} - ${currentUser?.email}');
      if (currentUser != null) {
        print('[AuthBloc] _onCheckAuthStatusEvent: Kullanıcı bulundu, Authenticated state yayınlanıyor.');
        emit(Authenticated(currentUser));
      } else {
        print('[AuthBloc] _onCheckAuthStatusEvent: Kullanıcı bulunamadı, Unauthenticated state yayınlanıyor.');
        emit(Unauthenticated());
      }
    } catch (e, s) {
      print('[AuthBloc] _onCheckAuthStatusEvent: HATA oluştu - $e');
      print('[AuthBloc] _onCheckAuthStatusEvent: StackTrace - $s');
      emit(Unauthenticated()); // Hata durumunda da Unauthenticated yayınla
    }
  }
}
