import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:egy_metro/cubit/my_account_user_service.dart';
import 'package:egy_metro/ui/login_page.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({Key? key}) : super(key: key);

  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  final MyAccountUserService _userService = MyAccountUserService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  bool _isEditing = false;
  String? _error;
  String _firstName = '';
  bool _isAuthenticated = false;

  late TextEditingController _emailController;
late TextEditingController _firstNameController;  // إضافة
  late TextEditingController _lastNameController;   // إضافة
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _firstNameController = TextEditingController();  // إضافة
    _lastNameController = TextEditingController();   // إضافة
    _checkAuthAndLoadProfile();
  }

  Future<void> _checkAuthAndLoadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      if (token == null) {
        setState(() {
          _error = 'Please login to view your profile';
          _isLoading = false;
          _isAuthenticated = false;
        });
        
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          }
        });
        return;
      }

      setState(() => _isAuthenticated = true);
      await _loadUserProfile();
    } catch (e) {
      setState(() {
        _error = 'Authentication error occurred';
        _isLoading = false;
        _isAuthenticated = false;
      });
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() => _isLoading = true);
      final userData = await _userService.getUserProfile();
      
      setState(() {
        _firstNameController.text = userData['first_name'] ?? '';
        _firstName = userData['first_name'] ?? '';
        _lastNameController.text = userData['last_name'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _error = null;
      });
    } catch (e) {
      if (e.toString().contains('No access token found') || 
          e.toString().contains('Authentication failed')) {
        setState(() {
          _isAuthenticated = false;
          _error = 'Session expired. Please login again.';
        });
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      } else {
        setState(() => _error = e.toString());
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
  if (!_formKey.currentState!.validate()) return;

  try {
    setState(() => _isLoading = true);
    
    final updatedData = await _userService.updateProfile(
      email: _emailController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
    );

    setState(() {
      _firstName = updatedData['first_name'] ?? _firstNameController.text;
      _isEditing = false;
      _error = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (e) {
    print('Update profile error: $e');
    if (e.toString().contains('No access token found') || 
        e.toString().contains('Authentication failed')) {
      setState(() {
        _isAuthenticated = false;
        _error = 'Session expired. Please login again.';
      });
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  } finally {
    setState(() => _isLoading = false);
  }
}
  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error logging out'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[600],
        shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
        'My Account',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
        actions: [
          if (!_isLoading && _isAuthenticated)
            IconButton(
              icon: Icon(
                _isEditing ? Icons.save_rounded : Icons.edit_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                if (_isEditing) {
                  _updateProfile();
                } else {
                  setState(() => _isEditing = true);
                }
              },
            ),
          
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red[700],
                size: 60,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_isAuthenticated)
              ElevatedButton.icon(
                onPressed: _loadUserProfile,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _buildProfileForm(),
                
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
  return Center( // إضافة Center widget
    child: Container(
      width: MediaQuery.of(context).size.width * 0.9, // تحديد عرض المستطيل
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[600]!,
            Colors.blue[400]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // إضافة محاذاة للمنتصف عمودياً
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.person_rounded,
              size: 60,
              color: Colors.blue[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _firstName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _emailController.text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildProfileForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  color: Colors.blue[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Profile Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildProfileField(
              label: 'First Name',
              controller: _firstNameController,
              enabled: _isEditing,
              icon: Icons.person_rounded,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 16),
            _buildProfileField(
              label: 'Last Name',
              controller: _lastNameController,
              enabled: _isEditing,
              icon: Icons.person_rounded,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 16),
            _buildProfileField(
              label: 'Email',
              controller: _emailController,
              enabled: _isEditing,
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[800],
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: Colors.blue[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.blue[600]!,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        if (keyboardType == TextInputType.emailAddress &&
            !value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose(); 
     _firstNameController.dispose();  // إضافة
    _lastNameController.dispose();   // إضافة
    super.dispose();
  }
}