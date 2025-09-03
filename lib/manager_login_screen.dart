// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaultmanager/supabase_service.dart';
import 'Expense_Manager/exp_bottom_navigation_bar.dart';

class ManagerLoginScreen extends StatefulWidget {
  const ManagerLoginScreen({super.key});

  @override
  State<ManagerLoginScreen> createState() => _ManagerLoginScreenState();
}

class _ManagerLoginScreenState extends State<ManagerLoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  String? _selectedRole;
  List<Map<String, dynamic>> _roles = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _animationController.forward();
    _loadRoles();
    _checkExistingSession();
  }

  Future<void> _loadRoles() async {
    try {
      print('Loading roles...');
      final response = await SupabaseService.client
          .from('roles')
          .select('name')
          .eq('is_enabled', 1)
          .order('name');
      
      print('Roles response: $response');
      
      final uniqueRoles = <Map<String, dynamic>>[];
      final seenRoleNames = <String>{};
      
      for (var role in response) {
        final roleName = role['name'].toString();
        if (!seenRoleNames.contains(roleName)) {
          seenRoleNames.add(roleName);
          uniqueRoles.add({'name': roleName});
        }
      }
      
      print('Unique roles: $uniqueRoles');
      
      setState(() {
        _roles = uniqueRoles;
      });
    } catch (e) {
      print('Error loading roles: $e');
      // Add fallback roles if database fails
      setState(() {
        _roles = [
          {'name': 'Manager'},
          {'name': 'Admin'},
          {'name': 'Employee'},
        ];
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        // Validate access key using Supabase function
        final response = await SupabaseService.client
            .rpc('authenticate_with_access_key', params: {
          'access_key_input': _keyController.text.trim(),
        });
        
        if (response != null && response.isNotEmpty) {
          final userData = response[0];
          final userRole = userData['role_type'];
          
          // Check if selected role matches user's actual role
          if (_selectedRole == userRole) {
            // Save session
            await _saveSession(_keyController.text.trim(), _selectedRole!);
            
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CustomBottomNavigationBar()),
              );
            }
          } else {
            _showError('Selected role does not match your assigned role');
          }
        } else {
          _showError('Invalid access key or key has expired');
        }
      } catch (e) {
        _showError('Login failed. Please check your credentials.');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _checkExistingSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAccessKey = prefs.getString('manager_access_key');
    final savedRole = prefs.getString('manager_role');
    
    if (savedAccessKey != null && savedRole != null) {
      // Auto-login with saved credentials
      try {
        final response = await SupabaseService.client
            .rpc('authenticate_with_access_key', params: {
          'access_key_input': savedAccessKey,
        });
        
        if (response != null && response.isNotEmpty) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CustomBottomNavigationBar()),
            );
          }
        } else {
          // Clear invalid session
          await _clearSession();
        }
      } catch (e) {
        await _clearSession();
      }
    }
  }
  
  Future<void> _saveSession(String accessKey, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('manager_access_key', accessKey);
    await prefs.setString('manager_role', role);
  }
  
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('manager_access_key');
    await prefs.remove('manager_role');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildLoginCard(),
                    const SizedBox(height: 20),
                    _buildBypassButton(),
                  ],
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667eea).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.security,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your key to continue',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: InputDecoration(
              labelText: 'Select Role',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
            ),
            items: _roles.map((role) {
              final roleName = role['name'].toString();
              return DropdownMenuItem<String>(
                value: roleName,
                child: Text(roleName),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedRole = value),
            validator: (value) => value == null ? 'Please select a role' : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _keyController,
            decoration: InputDecoration(
              labelText: 'Key Input',
              prefixIcon: const Icon(Icons.vpn_key),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your key';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667eea).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBypassButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CustomBottomNavigationBar()),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.skip_next,
              color: Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Bypass Login',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}