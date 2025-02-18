import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:egy_metro/ui/animated_page_transition.dart';
import 'package:egy_metro/ui/login_page.dart';
import '../cubit/navigation_cubit.dart';
import '../cubit/auth_logic_cubit.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthLogicCubit, AuthLogicState>(
      listener: (context, state) {
        if (state is AuthLogicSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          navigateWithAnimation(context, LoginPage());
        } else if (state is AuthLogicError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade50,
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 30),
                      _buildPersonalInfoSection(),
                      const SizedBox(height: 20),
                      _buildAccountInfoSection(),
                      const SizedBox(height: 20),
                      _buildSecuritySection(),
                      const SizedBox(height: 30),
                      _buildSignUpButton(),
                      const SizedBox(height: 20),
                      _buildLoginLink(),
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

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/Cairo_metro_logo.png',
              height: 60,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Create Account",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Join us and start your journey",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
    Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Personal Information", Icons.person_outline),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: firstNameController,
                label: "First Name",
                icon: Icons.person_outline,
                validator: (value) {
                  if (value?.isEmpty ?? true) return "Required";
                  return null;
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildTextField(
                controller: lastNameController,
                label: "Last Name",
                icon: Icons.person_outline,
                validator: (value) {
                  if (value?.isEmpty ?? true) return "Required";
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: nationalIdController,
          label: "National ID",
          icon: Icons.credit_card,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.isEmpty ?? true) return "Required";
            if (value!.length != 14) return "National ID must be 14 digits";
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAccountInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Account Information", Icons.account_circle_outlined),
        const SizedBox(height: 15),
        _buildTextField(
          controller: usernameController,
          label: "Username",
          icon: Icons.alternate_email,
          validator: (value) {
            if (value?.isEmpty ?? true) return "Required";
            if (value!.length < 3) return "Username too short";
            return null;
          },
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: emailController,
          label: "Email",
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty ?? true) return "Required";
            if (!value!.contains('@')) return "Invalid email";
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Security", Icons.security_outlined),
        const SizedBox(height: 15),
        _buildTextField(
          controller: passwordController,
          label: "Password",
          icon: Icons.lock_outline,
          isPassword: true,
          isPasswordVisible: isPasswordVisible,
          onTogglePassword: () {
            setState(() => isPasswordVisible = !isPasswordVisible);
          },
          validator: (value) {
            if (value?.isEmpty ?? true) return "Required";
            if (value!.length < 6) return "Password too short";
            return null;
          },
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: confirmPasswordController,
          label: "Confirm Password",
          icon: Icons.lock_outline,
          isPassword: true,
          isPasswordVisible: isConfirmPasswordVisible,
          onTogglePassword: () {
            setState(() => isConfirmPasswordVisible = !isConfirmPasswordVisible);
          },
          validator: (value) {
            if (value?.isEmpty ?? true) return "Required";
            if (value != passwordController.text) return "Passwords don't match";
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool? isPasswordVisible,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !(isPasswordVisible ?? false),
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ?? false
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: _handleSignUp,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_add, color: Colors.white),
          SizedBox(width: 8),
          Text(
            "Create Account",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,color: Colors.white
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () => navigateWithAnimation(context, LoginPage()),
          child: Text(
            "Login",
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _handleSignUp() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthLogicCubit>().onSignUpButtonPressed(
            firstNameController.text.trim(),
            lastNameController.text.trim(),
            usernameController.text.trim(),
            emailController.text.trim(),
            nationalIdController.text.trim(),
            passwordController.text.trim(),
            confirmPasswordController.text.trim(),
          );
    }
  }
}