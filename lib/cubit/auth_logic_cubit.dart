import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthLogicCubit extends Cubit<AuthLogicState> {
  AuthLogicCubit() : super(AuthLogicInitial());
  final String signUpUrl = "http://127.0.0.1:8000/api/users/register/";
  final String loginUrl = "http://127.0.0.1:8000/api/users/login/";

  Future<void> onLoginButtonPressed(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      emit(AuthLogicError("Fields cannot be empty"));
    } else {
      try {
        emit(AuthLogicLoading()); // حالة تحميل أثناء الاتصال بالسيرفر

        final requestBody = {
          "email": email,
          "password": password,
        };

        final response = await http.post(
          Uri.parse(loginUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          emit(AuthLogicSuccess("Login Successful!"));
        } else {
          final responseBody = jsonDecode(response.body);
          emit(AuthLogicError(responseBody['error'] ?? "Unknown error occurred"));
        }
      } catch (e) {
        emit(AuthLogicError("Failed to connect to the server"));
      }
    }
  }

  Future<void> onSignUpButtonPressed(String firstName, String lastName, String username,String email, String nationalId, String password, String confirmPassword) async {
    if ([firstName, lastName, username ,email, nationalId, password, confirmPassword].any((field) => field.isEmpty)) {
      emit(AuthLogicError("All fields are required"));
      return;
    } else if (password != confirmPassword) {
      emit(AuthLogicError("Passwords do not match"));
      return;
    }

    try {
      emit(AuthLogicLoading());

      final requestBody = {
        "first_name": firstName,
        "last_name": lastName,
        "user_name":username,
        "email": email,
        "national_id": nationalId,
        "password": password,
        "confirm_password":confirmPassword
      };

      final response = await http.post(
        Uri.parse(signUpUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        emit(AuthLogicSuccess("Sign-Up Successful!"));
      } else {
        final responseBody = jsonDecode(response.body);
        emit(AuthLogicError(responseBody['error'] ?? "Unknown error occurred"));
      }
    } catch (e) {
      emit(AuthLogicError("Failed to connect to the server"));
    }
  }
}

// States for Auth Logic
abstract class AuthLogicState {}

class AuthLogicInitial extends AuthLogicState {}

class AuthLogicLoading extends AuthLogicState {}

class AuthLogicSuccess extends AuthLogicState {
  final String message;
  AuthLogicSuccess(this.message);
}

class AuthLogicError extends AuthLogicState {
  final String error;
  AuthLogicError(this.error);
}
