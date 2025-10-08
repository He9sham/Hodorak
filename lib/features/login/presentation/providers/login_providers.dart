import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/login_viewmodel.dart';

// ViewModel provider
final loginViewModelProvider = NotifierProvider<LoginNotifier, LoginState>(() {
  return LoginNotifier();
});
