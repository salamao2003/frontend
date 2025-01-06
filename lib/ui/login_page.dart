import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:egy_metro/ui/animated_page_transition.dart';
import 'package:egy_metro/ui/signup_page.dart';
import '../cubit/navigation_cubit.dart';
import '../cubit/auth_logic_cubit.dart';
import 'package:egy_metro/ui/forget_password_page.dart';
import 'package:egy_metro/ui/home_page.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthLogicCubit, AuthLogicState>(
      listener: (context, state) {
        if (state is AuthLogicLoading) {
          _showLoadingDialog(context);
        } else if (state is AuthLogicSuccess) {
          Navigator.of(context).pop(); // Close the loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          navigateWithAnimation(context, HomePage());
        } else if (state is AuthLogicError) {
          Navigator.of(context).pop(); // Close the loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 150),
                Image.asset(
                  'assets/Cairo_metro_logo.png',
                  height: 100,
                ),
                const SizedBox(height: 50),
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      navigateWithAnimation(context, ForgotPasswordPage());
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_validateInputs(context)) {
                      context.read<AuthLogicCubit>().onLoginButtonPressed(
                          emailController.text.trim(),
                          passwordController.text.trim());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14.0, horizontal: 80.0),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    navigateWithAnimation(context, SignUpPage());
                  },
                  child: const Text(
                    "Don't have an account? Create Account",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing the dialog by tapping outside
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                const SizedBox(width: 20),
                const Text("Loading..."),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _validateInputs(BuildContext context) {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and Password are required.")),
      );
      return false;
    }
    return true;
  }
}
