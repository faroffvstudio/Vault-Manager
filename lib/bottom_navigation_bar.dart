import 'dart:ui';
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'transaction_screen.dart';
import 'add_transaction_screen.dart';
import 'my_ledger_screen.dart';
import 'profile_screen.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionScreen(),
    const AddTransactionScreen(),
    const MyLedgerScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
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
                        icon: _buildNavIcon(Icons.swap_horiz, 1),
                        label: 'Transactions',
                      ),
                      BottomNavigationBarItem(
                        icon: _buildNavIcon(Icons.add_circle, 2),
                        label: 'Add Transaction',
                      ),
                      BottomNavigationBarItem(
                        icon: _buildNavIcon(Icons.book, 3),
                        label: 'My Ledger',
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
}