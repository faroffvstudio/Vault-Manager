import 'package:flutter/material.dart';
import 'sales_manager_navigation.dart';

class ProfileScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const ProfileScreen({super.key, this.scrollController});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToSalesManager() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SalesManagerNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          controller: widget.scrollController,
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildStatsRow(),
              const SizedBox(height: 24),
              _buildMenuSection('Account', [
                {'icon': Icons.person, 'title': 'Personal Info', 'color': const Color(0xFF4CAF50)},
                {'icon': Icons.security, 'title': 'Security', 'color': const Color(0xFF2196F3)},
                {'icon': Icons.credit_card, 'title': 'Payment Methods', 'color': const Color(0xFFFF9800)},
              ]),
              const SizedBox(height: 20),
              _buildMenuSection('Preferences', [
                {'icon': Icons.notifications, 'title': 'Notifications', 'color': const Color(0xFF9C27B0)},
                {'icon': Icons.language, 'title': 'Language', 'color': const Color(0xFF00BCD4)},
                {'icon': Icons.dark_mode, 'title': 'Theme', 'color': const Color(0xFF607D8B)},
              ]),
              const SizedBox(height: 20),
              _buildMenuSection('Switch', [
                {'icon': Icons.swap_horiz, 'title': 'Switch Profile', 'color': const Color(0xFF3F51B5), 'onTap': () {}},
                {'icon': Icons.account_circle, 'title': 'Switch Account', 'color': const Color(0xFFE91E63), 'onTap': () {}},
                {'icon': Icons.business_center, 'title': 'Switch Sales Manager', 'color': const Color(0xFF009688), 'onTap': () => _navigateToSalesManager()},
              ]),
              const SizedBox(height: 20),
              _buildMenuSection('Support', [
                {'icon': Icons.help, 'title': 'Help & Support', 'color': const Color(0xFFFF5722)},
                {'icon': Icons.info, 'title': 'About', 'color': const Color(0xFF795548)},
                {'icon': Icons.logout, 'title': 'Logout', 'color': const Color(0xFFF44336), 'isLogout': true},
              ]),
            ],
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
                  'John Doe',
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
                  child: const Text(
                    'Employee ID: VE001',
                    style: TextStyle(
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
                    Text(
                      'john.doe@vault.com',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
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
}