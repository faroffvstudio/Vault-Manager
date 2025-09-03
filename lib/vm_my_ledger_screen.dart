// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:vaultmanager/session_manager.dart';
import 'package:vaultmanager/supabase_service.dart';

class VaultManagerMyLedgerScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const VaultManagerMyLedgerScreen({super.key, this.scrollController});

  @override
  State<VaultManagerMyLedgerScreen> createState() => _VaultManagerMyLedgerScreenState();
}

class _VaultManagerMyLedgerScreenState extends State<VaultManagerMyLedgerScreen>
    with TickerProviderStateMixin {
  bool _isTableView = false;
  late AnimationController _animationController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shimmerAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _selectedPeriod = 'This Month';
  
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _ledgerEntries = [];
  bool _isLoading = true;
  bool _hasViewPermission = false;
  bool _hasDeletePermission = false;
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double _avgTransaction = 0.0;
  double _thisWeekAmount = 0.0;

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
      print('Loading user session...');
      final session = await SessionManager.getSession();
      
      if (session != null) {
        final response = await SupabaseService.client
            .rpc('authenticate_with_access_key', params: {
          'access_key_input': session['accessKey'],
        });
        
        if (response != null && response.isNotEmpty) {
          _userData = response[0];
          print('User: ${_userData!['name']} | Role: ${_userData!['role_type']}');
          
          // Check if user has view ledger permission
          final permissions = _userData!['permissions']?.toString() ?? '';
          _hasViewPermission = permissions.contains('View Ledger');
          _hasDeletePermission = permissions.contains('Delete Records') || 
                               (_userData!['can_delete_records'] ?? 0) == 1;
          print('View Permission: $_hasViewPermission | Delete Permission: $_hasDeletePermission');
          
          if (_hasViewPermission) {
            await _loadLedgerData();
          } else {
            print('Access denied - No view permission');
          }
        } else {
          print('Error: No user data found');
        }
      } else {
        print('Error: No session found');
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadLedgerData() async {
    try {
      print('Loading ledger data...');
      final userId = SupabaseService.getCurrentUser()?.id;
      
      if (userId == null) {
        print('Error: No user ID found');
        return;
      }
      
      // Load all transaction entries for the user
      List<Map<String, dynamic>> allEntries = [];
      
      // Get selected employee from role screen - STRICT SECURITY
      final selectedEmployee = _userData!['selected_employee'];
      
      if (selectedEmployee == null || selectedEmployee.isEmpty) {
        print('Security: No employee selected - Access denied');
        setState(() {
          _ledgerEntries = [];
          _totalIncome = 0.0;
          _totalExpenses = 0.0;
        });
        return;
      }
      
      // Extract employee name from "Name (email)" format
      String employeeName = selectedEmployee;
      if (employeeName.contains('(')) {
        employeeName = employeeName.split('(')[0].trim();
      }
      print('Employee: $employeeName');
      
      // Load journal entries for selected employee only
      final journalResponse = await SupabaseService.client
          .from('journal_entries')
          .select('*, journals!inner(journal_date, voucher_no, voucher_type)')
          .eq('user_id', userId)
          .eq('account', employeeName)
          .order('id', ascending: true);
      
      // Load payment entries for selected employee only
      final paymentResponse = await SupabaseService.client
          .from('payment_entries')
          .select('*, payments!inner(payment_date, voucher_no)')
          .eq('user_id', userId)
          .eq('account', employeeName)
          .order('id', ascending: true);
      
      // Load receipt entries for selected employee only
      final receiptResponse = await SupabaseService.client
          .from('receipt_entries')
          .select('*, receipts!inner(receipt_date, voucher_no)')
          .eq('user_id', userId)
          .eq('account', employeeName)
          .order('id', ascending: true);
      
      // Process all entries and calculate running balance
      double runningBalance = 0.0;
      _totalIncome = 0.0;
      _totalExpenses = 0.0;
      
      // Get expense account name for display
      final expenseAccount = _userData!['expense_account'] ?? 'Expense Account';
      
      // Process journal entries
      for (var entry in journalResponse) {
        final debit = entry['debit_amount'] ?? 0.0;
        final credit = entry['credit_amount'] ?? 0.0;
        runningBalance += debit - credit;
        
        if (debit > 0) _totalIncome += debit;
        if (credit > 0) _totalExpenses += credit;
        
        // Show expense account name instead of employee name
        String displayTitle = expenseAccount;
        if (debit > 0) {
          displayTitle = 'From $expenseAccount';
        } else {
          displayTitle = 'To $expenseAccount';
        }
        
        allEntries.add({
          'title': displayTitle,
          'amount': debit > 0 ? '+₹${debit.toStringAsFixed(0)}' : '-₹${credit.toStringAsFixed(0)}',
          'date': entry['journals']['journal_date'] ?? 'Unknown',
          'type': debit > 0 ? 'income' : 'expense',
          'icon': Icons.account_balance_wallet,
          'description': entry['short_narration'] ?? 'Journal transaction',
          'category': 'Journal',
          'voucher_no': entry['journals']['voucher_no'],
          'balance': runningBalance,
        });
      }
      
      // Process payment entries
      for (var entry in paymentResponse) {
        final credit = entry['credit_amount'] ?? 0.0;
        runningBalance -= credit;
        _totalExpenses += credit;
        
        allEntries.add({
          'title': entry['account'] ?? 'Payment',
          'amount': '-₹${credit.toStringAsFixed(0)}',
          'date': entry['payments']['payment_date'] ?? 'Unknown',
          'type': 'expense',
          'icon': Icons.payment,
          'description': entry['short_narration'] ?? 'Payment made',
          'category': 'Payment',
          'voucher_no': entry['payments']['voucher_no'],
          'balance': runningBalance,
        });
      }
      
      // Process receipt entries
      for (var entry in receiptResponse) {
        final debit = entry['debit_amount'] ?? 0.0;
        runningBalance += debit;
        _totalIncome += debit;
        
        allEntries.add({
          'title': entry['account'] ?? 'Receipt',
          'amount': '+₹${debit.toStringAsFixed(0)}',
          'date': entry['receipts']['receipt_date'] ?? 'Unknown',
          'type': 'income',
          'icon': Icons.receipt,
          'description': entry['short_narration'] ?? 'Receipt received',
          'category': 'Receipt',
          'voucher_no': entry['receipts']['voucher_no'],
          'balance': runningBalance,
        });
      }
      
      // Sort by date (newest first)
      allEntries.sort((a, b) => b['date'].compareTo(a['date']));
      
      // Calculate average transaction
      if (allEntries.isNotEmpty) {
        final totalAmount = _totalIncome + _totalExpenses;
        _avgTransaction = totalAmount / allEntries.length;
      }
      
      // Calculate this week's transactions
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      _thisWeekAmount = 0.0;
      
      for (var entry in allEntries) {
        try {
          final entryDate = DateTime.parse(entry['date']);
          if (entryDate.isAfter(weekStart)) {
            final amountStr = entry['amount'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
            final amount = double.tryParse(amountStr) ?? 0.0;
            _thisWeekAmount += amount;
          }
        } catch (e) {
          // Skip invalid dates
        }
      }
      
      print('Ledger Summary: ${allEntries.length} entries | Income: ₹$_totalIncome | Expenses: ₹$_totalExpenses');
      
      setState(() {
        _ledgerEntries = allEntries;
      });
    } catch (e) {
      print('Error loading ledger data: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadUserData();
  }

  Future<void> _deleteEntry(BuildContext context, Map<String, dynamic> entry) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Are you sure you want to delete this ${entry['category'].toLowerCase()} entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final userId = SupabaseService.getCurrentUser()?.id;
      if (userId == null) return;

      // Delete based on category type
      if (entry['category'] == 'Journal') {
        // Delete journal entries first, then journal header
        await SupabaseService.client
            .from('journal_entries')
            .delete()
            .eq('user_id', userId)
            .eq('short_narration', entry['description']);
        
        await SupabaseService.client
            .from('journals')
            .delete()
            .eq('user_id', userId)
            .eq('voucher_no', entry['voucher_no']);
      } else if (entry['category'] == 'Payment') {
        await SupabaseService.client
            .from('payment_entries')
            .delete()
            .eq('user_id', userId)
            .eq('short_narration', entry['description']);
        
        await SupabaseService.client
            .from('payments')
            .delete()
            .eq('user_id', userId)
            .eq('voucher_no', entry['voucher_no']);
      } else if (entry['category'] == 'Receipt') {
        await SupabaseService.client
            .from('receipt_entries')
            .delete()
            .eq('user_id', userId)
            .eq('short_narration', entry['description']);
        
        await SupabaseService.client
            .from('receipts')
            .delete()
            .eq('user_id', userId)
            .eq('voucher_no', entry['voucher_no']);
      }

      // Close detail sheet and refresh data
      Navigator.pop(context);
      await _refreshData();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting entry: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting entry: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shimmerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show access denied only after loading is complete and permission is false
    if (!_isLoading && !_hasViewPermission) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You do not have permission to view ledger data',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _refreshData,
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
                _isLoading ? _buildShimmerSearch() : _buildSearchAndFilter(),
                const SizedBox(height: 20),
                _isLoading ? _buildShimmerEntries() : (_isTableView ? _buildTableView() : _buildLedgerEntries()),
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
                          'My Ledger',
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
                        'Net Balance: ₹${(_totalIncome - _totalExpenses).toStringAsFixed(0)}',
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
                  Icons.account_balance,
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
                  child: _buildBalanceInfo('Total Income', '₹${_totalIncome.toStringAsFixed(0)}', Icons.trending_up, const Color(0xFF4CAF50)),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: _buildBalanceInfo('Total Expenses', '₹${_totalExpenses.toStringAsFixed(0)}', Icons.trending_down, const Color(0xFFFF5722)),
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
          child: _buildStatCard('Entries', '${_ledgerEntries.length}', Icons.receipt_long, const Color(0xFF4CAF50)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Avg. Transaction', '₹${_avgTransaction.toStringAsFixed(0)}', Icons.analytics, const Color(0xFF2196F3)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('This Week', '₹${_thisWeekAmount.toStringAsFixed(0)}', Icons.calendar_today, const Color(0xFFFF9800)),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
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
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search ledger entries...',
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
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPeriodSelector(),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(_isTableView ? Icons.view_list : Icons.table_rows, color: const Color(0xFF667eea)),
                onPressed: () => setState(() => _isTableView = !_isTableView),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['This Month', 'Last Month', 'This Year', 'All Time'];
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          onChanged: (value) => setState(() => _selectedPeriod = value!),
          items: periods.map((period) => DropdownMenuItem(
            value: period,
            child: Text(period),
          )).toList(),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF667eea)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildLedgerEntries() {
    final entries = _ledgerEntries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ledger Entries (${entries.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
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
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return _buildLedgerItem(entry);
          },
        ),
      ],
    );
  }

  Widget _buildLedgerItem(Map<String, dynamic> entry) {
    final isIncome = entry['type'] == 'income';
    final color = isIncome ? const Color(0xFF4CAF50) : const Color(0xFFFF5722);
    
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
          onTap: () => _showEntryDetails(entry),
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
                  child: Icon(entry['icon'], color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry['description'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry['date'],
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
                      entry['amount'],
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
                        entry['category'],
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

  void _showEntryDetails(Map<String, dynamic> entry) {
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
              'Entry Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Entry', entry['title']),
            _buildDetailRow('Amount', entry['amount']),
            _buildDetailRow('Category', entry['category']),
            _buildDetailRow('Description', entry['description']),
            _buildDetailRow('Date & Time', entry['date']),
            const SizedBox(height: 20),
            Row(
              children: [
                if (_hasDeletePermission) ...[
                  Expanded(
                    child: _AnimatedDeleteButton(
                      onDelete: () => _deleteEntry(context, entry),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
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

  Widget _buildTableView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(width: 40, child: Text('S.No', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('Account Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(child: Text('Debit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(child: Text('Credit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              ],
            ),
          ),
          ..._ledgerEntries.asMap().entries.map((mapEntry) {
            final index = mapEntry.key;
            final entry = mapEntry.value;
            final isIncome = entry['type'] == 'income';
            
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40, 
                    child: Text(
                      '${index + 1}', 
                      style: const TextStyle(fontWeight: FontWeight.w500)
                    )
                  ),
                  Expanded(
                    flex: 3, 
                    child: Text(
                      entry['title'], 
                      style: const TextStyle(fontWeight: FontWeight.w500)
                    )
                  ),
                  Expanded(
                    child: Text(
                      isIncome ? entry['amount'] : '-',
                      style: TextStyle(
                        color: isIncome ? const Color(0xFF4CAF50) : Colors.grey, 
                        fontWeight: FontWeight.w500
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      !isIncome ? entry['amount'] : '-',
                      style: TextStyle(
                        color: !isIncome ? const Color(0xFFFF5722) : Colors.grey, 
                        fontWeight: FontWeight.w500
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
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
                    _buildShimmerBox(16, 120),
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
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 10,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerSearch() {
    return Column(
      children: [
        Container(
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
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmerEntries() {
    return Column(
      children: List.generate(5, (index) => 
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 13,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 16,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 20,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
}

class _AnimatedDeleteButton extends StatefulWidget {
  final VoidCallback onDelete;

  const _AnimatedDeleteButton({required this.onDelete});

  @override
  State<_AnimatedDeleteButton> createState() => _AnimatedDeleteButtonState();
}

class _AnimatedDeleteButtonState extends State<_AnimatedDeleteButton>
    with TickerProviderStateMixin {
  bool _isConfirmMode = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!_isConfirmMode) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      setState(() {
        _isConfirmMode = true;
      });
      // Auto reset after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isConfirmMode = false;
          });
        }
      });
    } else {
      widget.onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: ElevatedButton(
            onPressed: _handleTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isConfirmMode ? Colors.red[700] : Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isConfirmMode
                  ? const Row(
                      key: ValueKey('confirm'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, size: 18),
                        SizedBox(width: 8),
                        Text('Confirm'),
                      ],
                    )
                  : const Row(
                      key: ValueKey('delete'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, size: 18),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}