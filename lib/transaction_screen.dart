// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:vaultmanager/session_manager.dart';
import 'package:vaultmanager/supabase_service.dart';

class TransactionScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const TransactionScreen({super.key, this.scrollController});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shimmerAnimation;
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _realTransactions = [];

  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'Salary Credit',
      'amount': '+₹50,000',
      'time': 'Today, 9:30 AM',
      'icon': Icons.account_balance_wallet,
      'color': const Color(0xFF4CAF50),
      'category': 'Income',
      'description': 'Monthly salary deposit',
    },
    {
      'title': 'ATM Withdrawal',
      'amount': '-₹5,000',
      'time': 'Yesterday, 2:15 PM',
      'icon': Icons.atm,
      'color': const Color(0xFFFF5722),
      'category': 'Expense',
      'description': 'Cash withdrawal from ATM',
    },
    {
      'title': 'Online Transfer',
      'amount': '-₹12,500',
      'time': '2 days ago, 11:45 AM',
      'icon': Icons.send,
      'color': const Color(0xFFFF5722),
      'category': 'Transfer',
      'description': 'Transfer to John Doe',
    },
    {
      'title': 'Cashback Reward',
      'amount': '+₹250',
      'time': '3 days ago, 6:20 PM',
      'icon': Icons.card_giftcard,
      'color': const Color(0xFF4CAF50),
      'category': 'Income',
      'description': 'Shopping cashback',
    },
    {
      'title': 'Grocery Shopping',
      'amount': '-₹3,200',
      'time': '4 days ago, 7:30 PM',
      'icon': Icons.shopping_cart,
      'color': const Color(0xFFFF5722),
      'category': 'Expense',
      'description': 'BigBasket purchase',
    },
    {
      'title': 'Investment SIP',
      'amount': '-₹10,000',
      'time': '5 days ago, 10:00 AM',
      'icon': Icons.trending_up,
      'color': const Color(0xFF2196F3),
      'category': 'Investment',
      'description': 'Mutual fund SIP',
    },
  ];

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
    _loadTransactions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shimmerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    List<Map<String, dynamic>> filtered = _isLoading ? _transactions : _realTransactions;
    
    if (_selectedFilter != 'All') {
      filtered = filtered.where((t) => t['category'] == _selectedFilter).toList();
    }
    
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((t) => 
        t['title'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
        t['description'].toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _refreshTransactions,
          color: const Color(0xFF667eea),
          child: SingleChildScrollView(
            controller: widget.scrollController,
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isLoading ? _buildShimmerWelcome() : _buildWelcomeSection(),
                const SizedBox(height: 24),
                _isLoading ? _buildShimmerStats() : _buildQuickStats(),
                const SizedBox(height: 24),
                _isLoading ? _buildShimmerSearch() : _buildSearchBar(),
                const SizedBox(height: 16),
                _isLoading ? _buildShimmerFilters() : _buildFilterChips(),
                const SizedBox(height: 20),
                _isLoading ? _buildShimmerTransactions() : _buildTransactionsList(),
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Transactions',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        'Total Transactions: ${_realTransactions.length} entries',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildBalanceInfo('Income', _calculateTotalIncome(), Icons.trending_up, const Color(0xFF4CAF50)),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: _buildBalanceInfo('Expenses', _calculateTotalExpenses(), Icons.trending_down, const Color(0xFFFF5722)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBalanceInfo(String label, String amount, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          amount,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('This Month', _calculateThisMonth(), Icons.calendar_month, const Color(0xFF4CAF50)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Last Transaction', _getLastTransactionAmount(), Icons.history, const Color(0xFF2196F3)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Avg. Daily', _calculateAvgDaily(), Icons.analytics, const Color(0xFFFF9800)),
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
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Income', 'Expense', 'Transfer', 'Investment'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF667eea).withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF667eea) : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? const Color(0xFF667eea) : Colors.grey[300]!,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionsList() {
    final transactions = _filteredTransactions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  'Transactions (${transactions.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Export',
                style: TextStyle(color: Color(0xFF667eea)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return _buildTransactionItem(
              transaction['title'],
              transaction['amount'],
              transaction['time'],
              transaction['icon'],
              transaction['color'],
              transaction['description'],
              transaction['category'],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
    String title,
    String amount,
    String time,
    IconData icon,
    Color color,
    String description,
    String category,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTransactionDetails(title, amount, time, description, category, color),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amount,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(String title, String amount, String time, String description, String category, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Transaction Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Transaction', title),
            _buildDetailRow('Amount', amount),
            _buildDetailRow('Category', category),
            _buildDetailRow('Description', description),
            _buildDetailRow('Date & Time', time),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadTransactions() async {
    try {
      final session = await SessionManager.getSession();
      if (session != null) {
        final response = await SupabaseService.client
            .rpc('authenticate_with_access_key', params: {
          'access_key_input': session['accessKey'],
        });
        
        if (response != null && response.isNotEmpty) {
          final userData = response[0];
          final userId = SupabaseService.getCurrentUser()?.id;
          final selectedEmployee = userData['selected_employee'];
          
          if (userId != null && selectedEmployee != null) {
            // Extract employee name from "Name (email)" format
            String employeeName = selectedEmployee;
            if (employeeName.contains('(')) {
              employeeName = employeeName.split('(')[0].trim();
            }
            
            // Load journal entries for selected employee only (like ledger screen)
            final journalResponse = await SupabaseService.client
                .from('journal_entries')
                .select('*, journals!inner(journal_date, voucher_no, voucher_type)')
                .eq('user_id', userId)
                .eq('account', employeeName)
                .order('id', ascending: false)
                .limit(20);
            
            final expenseAccount = userData['expense_account'] ?? 'Expense Account';
            
            _realTransactions = journalResponse.map<Map<String, dynamic>>((entry) {
              final debit = entry['debit_amount'] ?? 0.0;
              final credit = entry['credit_amount'] ?? 0.0;
              final isIncome = debit > 0;
              
              return {
                'title': isIncome ? 'From $expenseAccount' : 'To $expenseAccount',
                'amount': isIncome ? '+₹${debit.toStringAsFixed(0)}' : '-₹${credit.toStringAsFixed(0)}',
                'time': _formatDate(entry['journals']['journal_date']),
                'icon': isIncome ? Icons.trending_up : Icons.trending_down,
                'color': isIncome ? const Color(0xFF4CAF50) : const Color(0xFFFF5722),
                'category': isIncome ? 'Income' : 'Expense',
                'description': entry['short_narration'] ?? 'Transaction',
              };
            }).toList();
          }
        }
      }
    } catch (e) {
      print('Error loading transactions: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;
      
      if (difference == 0) {
        return 'Today, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference == 1) {
        return 'Yesterday, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      } else {
        return '$difference days ago';
      }
    } catch (e) {
      return dateStr;
    }
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBox(24, 150),
                    const SizedBox(height: 8),
                    _buildShimmerBox(16, 200),
                  ],
                ),
              ),
              _buildShimmerBox(60, 60, borderRadius: 16),
            ],
          ),
          const SizedBox(height: 16),
          _buildShimmerBox(80, double.infinity, borderRadius: 12),
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
                const SizedBox(height: 10),
                _buildShimmerBox(14, 40),
                const SizedBox(height: 4),
                _buildShimmerBox(10, 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerSearch() {
    return Container(
      height: 50,
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
      child: Container(
        margin: const EdgeInsets.all(16),
        child: _buildShimmerBox(18, double.infinity),
      ),
    );
  }

  Widget _buildShimmerFilters() {
    return SizedBox(
      height: 40,
      child: Row(
        children: List.generate(5, (index) => 
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: _buildShimmerBox(40, 60, borderRadius: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerBox(20, 150),
        const SizedBox(height: 12),
        ...List.generate(6, (index) => 
          Container(
            margin: const EdgeInsets.only(bottom: 12),
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
            child: Row(
              children: [
                _buildShimmerBox(48, 48, borderRadius: 12),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerBox(16, double.infinity),
                      const SizedBox(height: 4),
                      _buildShimmerBox(13, 200),
                      const SizedBox(height: 2),
                      _buildShimmerBox(12, 100),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildShimmerBox(16, 60),
                    const SizedBox(height: 4),
                    _buildShimmerBox(20, 40, borderRadius: 8),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _refreshTransactions() async {
    setState(() {
      _isLoading = true;
    });
    await _loadTransactions();
  }

  String _calculateTotalIncome() {
    double total = 0.0;
    for (var transaction in _realTransactions) {
      if (transaction['category'] == 'Income') {
        final amountStr = transaction['amount'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
        total += double.tryParse(amountStr) ?? 0.0;
      }
    }
    return '₹${total.toStringAsFixed(0)}';
  }

  String _calculateTotalExpenses() {
    double total = 0.0;
    for (var transaction in _realTransactions) {
      if (transaction['category'] == 'Expense') {
        final amountStr = transaction['amount'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
        total += double.tryParse(amountStr) ?? 0.0;
      }
    }
    return '₹${total.toStringAsFixed(0)}';
  }

  String _calculateThisMonth() {
    final now = DateTime.now();
    double total = 0.0;
    for (var transaction in _realTransactions) {
      try {
        final transactionDate = DateTime.parse(transaction['time'].split(',')[0]);
        if (transactionDate.month == now.month && transactionDate.year == now.year) {
          final amountStr = transaction['amount'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
          total += double.tryParse(amountStr) ?? 0.0;
        }
      } catch (e) {
        // Skip invalid dates
      }
    }
    return '₹${total.toStringAsFixed(0)}';
  }

  String _getLastTransactionAmount() {
    if (_realTransactions.isEmpty) return '₹0';
    return _realTransactions.first['amount'] ?? '₹0';
  }

  String _calculateAvgDaily() {
    if (_realTransactions.isEmpty) return '₹0';
    double total = 0.0;
    for (var transaction in _realTransactions) {
      final amountStr = transaction['amount'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
      total += double.tryParse(amountStr) ?? 0.0;
    }
    final avg = total / 30; // Average over 30 days
    return '₹${avg.toStringAsFixed(0)}';
  }
}