import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:egy_metro/services/ticket_service.dart';
// API Endpoints
class AuthLogicCubit extends Cubit<AuthLogicState> {
  AuthLogicCubit() : super(AuthLogicInitial());
  final String signUpUrl = "https://backend-54v5.onrender.com/api/users/register/";
  final String loginUrl = "https://backend-54v5.onrender.com/api/users/login/";

  // Login Function
  Future<void> onLoginButtonPressed(String username, String password) async {

    if (username.isEmpty || password.isEmpty) {

      emit(AuthLogicError("Fields cannot be empty"));

      return;

    }


    try {

      emit(AuthLogicLoading());


      final requestBody = {

        "username": username,

        "password": password,

      };


      print('Sending login request with data: ${json.encode(requestBody)}');


      final response = await http.post(

        Uri.parse(loginUrl),

        headers: {"Content-Type": "application/json"},

        body: json.encode(requestBody),

      );


      print('Server response: ${response.body}');

      print('Response status code: ${response.statusCode}');


      if (response.statusCode == 200) {

        final responseBody = json.decode(response.body);


        if (responseBody['success'] == true) {

          // Save token and user data

          final prefs = await SharedPreferences.getInstance();

          await prefs.setString('access_token', responseBody['data']['access']);

          await prefs.setString('refresh_token', responseBody['data']['refresh']);

          await prefs.setString('user_data', json.encode(responseBody['data']['user']));


          // Sync tickets after successful login

          try {

            final ticketsResponse = await TicketService.getTickets();

            print('Tickets sync response: $ticketsResponse');

            

            if (ticketsResponse['success'] == true) {

              // You can handle the tickets data here if needed

              print('Tickets synced successfully');

            } else {

              print('Failed to sync tickets: ${ticketsResponse['message']}');

            }

          } catch (e) {

            print('Error syncing tickets: $e');

          }


          emit(AuthLogicSuccess(responseBody['message'] ?? "Login Successful!"));

        } else {

          emit(AuthLogicError(responseBody['message'] ?? "Login failed"));

        }

      } else {

        final responseBody = json.decode(response.body);

        emit(AuthLogicError(responseBody['message'] ?? "Login failed"));

      }

    } catch (e) {

      print('Login error: $e');

      emit(AuthLogicError("Failed to connect to the server"));

    }

  }

  // Sign-Up Function
  Future<void> onSignUpButtonPressed(
    String firstName,
    String lastName,
    String username,
    String email,
    String nationalId,
    String password,
    String confirmPassword,
  ) async {
    if ([firstName, lastName, username, email, nationalId, password, confirmPassword]
        .any((field) => field.isEmpty)) {
      emit(AuthLogicError("All fields are required"));
      return;
    }

    if (password != confirmPassword) {
      emit(AuthLogicError("Passwords do not match"));
      return;
    }

    try {
      emit(AuthLogicLoading());

      final requestBody = {
        "first_name": firstName,
        "last_name": lastName,
        "username": username,
        "email": email,
        "national_id": nationalId,
        "password": password,
        "confirm_password": confirmPassword,
      };

      final response = await http.post(
        Uri.parse(signUpUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        emit(AuthLogicSuccess("Sign-Up Successful!"));
      } else if (responseBody is Map && responseBody.isNotEmpty) {
        final errorMessages = responseBody.values.join(", ");
        emit(AuthLogicError(errorMessages));
      } else {
        emit(AuthLogicError("Unknown error occurred"));
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