import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0); // Initial state is 0 (Login page)

  void showSignUpPage() => emit(1); // State 1 = Sign-Up page
  void showLoginPage() => emit(0);  // State 0 = Login page
}
