// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:vaultmanager/Expense_Manager/exp_bottom_navigation_bar.dart';
import 'package:vaultmanager/session_manager.dart';
import 'package:vaultmanager/supabase_service.dart';
import 'Sales_Manager/sales_manager_navigation.dart';

class ProfileScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const ProfileScreen({super.key, this.scrollController});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shimmerAnimation;
  
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final session = await SessionManager.getSession();
      if (session != null) {
        final response = await SupabaseService.client
            .rpc('authenticate_with_access_key', params: {
          'access_key_input': session['accessKey'],
        });
        
        if (response != null && response.isNotEmpty) {
          setState(() {
            _userData = response[0];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _navigateToSalesManager() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SalesManagerNavigation()),
    );
  }

  void _navigateToExpenseManager() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const CustomBottomNavigationBar()),
    );
  }
  
  Future<void> _logout() async {
    await SessionManager.clearSession();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _refreshProfile,
          color: const Color(0xFF667eea),
          child: SingleChildScrollView(
            controller: widget.scrollController,
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isLoading ? _buildShimmerWelcome() : _buildWelcomeSection(),
                const SizedBox(height: 24),
                _isLoading ? _buildShimmerStats() : _buildStatsRow(),
                const SizedBox(height: 24),
                _isLoading ? _buildShimmerMenu() : _buildMenuSection('Account', [
                  {'icon': Icons.person, 'title': 'Personal Info', 'color': const Color(0xFF4CAF50)},
                  {'icon': Icons.security, 'title': 'Security', 'color': const Color(0xFF2196F3)},
                  {'icon': Icons.credit_card, 'title': 'Payment Methods', 'color': const Color(0xFFFF9800)},
                ]),
                const SizedBox(height: 20),
                _isLoading ? _buildShimmerMenu() : _buildMenuSection('Preferences', [
                  {'icon': Icons.notifications, 'title': 'Notifications', 'color': const Color(0xFF9C27B0)},
                  {'icon': Icons.language, 'title': 'Language', 'color': const Color(0xFF00BCD4)},
                  {'icon': Icons.dark_mode, 'title': 'Theme', 'color': const Color(0xFF607D8B)},
                ]),
                const SizedBox(height: 20),
                _isLoading ? _buildShimmerMenu() : _buildMenuSection('Switch', [
                  {'icon': Icons.swap_horiz, 'title': 'Switch Profile', 'color': const Color(0xFF3F51B5), 'onTap': () {}},
                  {'icon': Icons.account_circle, 'title': 'Switch Account', 'color': const Color(0xFFE91E63), 'onTap': () {}},
                  {'icon': Icons.business_center, 'title': 'Switch Sales Manager', 'color': const Color(0xFF009688), 'onTap': () => _navigateToSalesManager()},
                  {'icon': Icons.receipt_long, 'title': 'Switch Expense Manager', 'color': const Color(0xFFFF5722), 'onTap': () => _navigateToExpenseManager()},
                ]),
                const SizedBox(height: 20),
                _isLoading ? _buildShimmerMenu() : _buildMenuSection('Support', [
                  {'icon': Icons.help, 'title': 'Help & Support', 'color': const Color(0xFFFF5722)},
                  {'icon': Icons.info, 'title': 'About', 'color': const Color(0xFF795548)},
                  {'icon': Icons.logout, 'title': 'Logout', 'color': const Color(0xFFF44336), 'isLogout': true, 'onTap': () => _logout()},
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.blue.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.person,
                size: 35,
                color: Color(0xFF667eea),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userData?['name'] ?? 'Loading...',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _userData?['role_type'] ?? 'Role',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.email,
                      color: Colors.grey[600],
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _userData?['email'] ?? 'Loading...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (_userData?['expense_group'] != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Colors.grey[600],
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Access: ${_userData!['expense_group']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Years', '3.5', Icons.work, const Color(0xFF4CAF50)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Projects', '24', Icons.folder, const Color(0xFF2196F3)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Rating', '4.8', Icons.star, const Color(0xFFFF9800)),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> item = entry.value;
              bool isLast = index == items.length - 1;
              bool isLogout = item['isLogout'] ?? false;
              
              return Column(
                children: [
                  _buildMenuItem(
                    item['icon'],
                    item['title'],
                    item['color'],
                    item['onTap'] ?? () {},
                    isLogout: isLogout,
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: Colors.grey.withOpacity(0.1),
                      indent: 60,
                      endIndent: 20,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isLogout ? color : Colors.grey[800],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _isLoading = true;
    });
    await _loadUserData();
  }

  Widget _buildShimmerBox(double height, double width, {double borderRadius = 4}) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                _shimmerAnimation.value - 0.3,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 0.3,
              ],
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerWelcome() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildShimmerBox(70, 70, borderRadius: 35),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(24, 150),
                const SizedBox(height: 8),
                _buildShimmerBox(16, 80),
                const SizedBox(height: 8),
                _buildShimmerBox(14, 200),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerStats() {
    return Row(
      children: List.generate(3, (index) => 
        Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
            padding: const EdgeInsets.all(18),
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
            child: Column(
              children: [
                _buildShimmerBox(40, 40, borderRadius: 10),
                const SizedBox(height: 8),
                _buildShimmerBox(16, 30),
                const SizedBox(height: 2),
                _buildShimmerBox(12, 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerBox(20, 100),
        const SizedBox(height: 12),
        Container(
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
          child: Column(
            children: List.generate(3, (index) => 
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildShimmerBox(40, 40, borderRadius: 10),
                    const SizedBox(width: 16),
                    Expanded(child: _buildShimmerBox(15, double.infinity)),
                    _buildShimmerBox(14, 14, borderRadius: 6),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}