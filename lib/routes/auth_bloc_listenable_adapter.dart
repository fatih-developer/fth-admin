import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:fth_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fth_admin/features/auth/presentation/bloc/auth_state.dart';

class AuthBlocListenableAdapter extends ChangeNotifier {
  final AuthBloc _authBloc;
  late StreamSubscription _subscription;

  AuthBlocListenableAdapter(this._authBloc) {
    _subscription = _authBloc.stream.listen((_) {
      notifyListeners();
    });
  }

  AuthState get state => _authBloc.state;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
