// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'sales_manager_dashboard.dart';
import '../manager_profile_screen.dart';

class SalesManagerNavigation extends StatefulWidget {
  const SalesManagerNavigation({super.key});

  @override
  State<SalesManagerNavigation> createState() => _SalesManagerNavigationState();
}

class _SalesManagerNavigationState extends State<SalesManagerNavigation> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final ScrollController _scrollController = ScrollController();
  bool _isVisible = true;

  List<Widget> get _screens => [
    SalesManagerDashboard(scrollController: _scrollController),
    _buildLeadsScreen(),
    _buildReportsScreen(),
    _buildTeamScreen(),
    ProfileScreen(scrollController: _scrollController),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isVisible) {
        _isVisible = false;
        _animationController.reverse();
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isVisible) {
        _isVisible = true;
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                if (scrollNotification.scrollDelta! > 0) {
                  if (_isVisible) {
                    _isVisible = false;
                    _animationController.reverse();
                  }
                } else if (scrollNotification.scrollDelta! < 0) {
                  if (!_isVisible) {
                    _isVisible = true;
                    _animationController.forward();
                  }
                }
              }
              return false;
            },
            child: _screens[_currentIndex],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - _animation.value) * 100),
                  child: Opacity(
                    opacity: _animation.value,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: BottomNavigationBar(
                            type: BottomNavigationBarType.fixed,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            currentIndex: _currentIndex,
                            onTap: (index) => setState(() => _currentIndex = index),
                            selectedItemColor: const Color(0xFF667eea),
                            unselectedItemColor: Colors.grey[600],
                            selectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontSize: 11,
                            ),
                            items: [
                              BottomNavigationBarItem(
                                icon: _buildNavIcon(Icons.dashboard, 0),
                                label: 'Dashboard',
                              ),
                              BottomNavigationBarItem(
                                icon: _buildNavIcon(Icons.people, 1),
                                label: 'Add Sales',
                              ),
                              BottomNavigationBarItem(
                                icon: _buildNavIcon(Icons.analytics, 2),
                                label: 'Reports',
                              ),
                              BottomNavigationBarItem(
                                icon: _buildNavIcon(Icons.group, 3),
                                label: 'Team',
                              ),
                              BottomNavigationBarItem(
                                icon: _buildNavIcon(Icons.person, 4),
                                label: 'Profile',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF667eea).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: isSelected ? 28 : 24,
        color: isSelected ? const Color(0xFF667eea) : Colors.grey[600],
      ),
    );
  }

  Widget _buildLeadsScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: const Center(
        child: Text('Leads Screen', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildReportsScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: const Center(
        child: Text('Reports Screen', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTeamScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: const Center(
        child: Text('Team Screen', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }
}