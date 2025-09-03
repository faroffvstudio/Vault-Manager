// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:vaultmanager/session_manager.dart';
import 'package:vaultmanager/supabase_service.dart';

class TransactionStatusScreen extends StatefulWidget {
  final String status;
  
  const TransactionStatusScreen({super.key, required this.status});

  @override
  State<TransactionStatusScreen> createState() => _TransactionStatusScreenState();
}

class _TransactionStatusScreenState extends State<TransactionStatusScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shimmerAnimation;
  
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _realTransactions = [];
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
    _loadTransactionData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _refreshTransactionData,
          color: const Color(0xFF667eea),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isLoading ? _buildShimmerWelcome() : _buildWelcomeSection(),
                const SizedBox(height: 24),
                _buildRequestsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    Color statusColor;
    IconData statusIcon;
    String statusCount;
    String totalAmount;
    
    switch (widget.status.toLowerCase()) {
      case 'pending':
        statusColor = const Color(0xFFFF9800);
        statusIcon = Icons.pending;
        statusCount = _isLoading ? '0' : _realTransactions.where((t) => t['status'].toLowerCase() == 'pending').length.toString();
        totalAmount = _isLoading ? '₹0' : _calculateTotalAmount('pending');
        break;
      case 'rejected':
        statusColor = const Color(0xFFFF5722);
        statusIcon = Icons.cancel;
        statusCount = _isLoading ? '0' : _realTransactions.where((t) => t['status'].toLowerCase() == 'rejected').length.toString();
        totalAmount = _isLoading ? '₹0' : _calculateTotalAmount('rejected');
        break;
      case 'accepted':
        statusColor = const Color(0xFF4CAF50);
        statusIcon = Icons.check_circle;
        statusCount = _isLoading ? '0' : _realTransactions.where((t) => t['status'].toLowerCase() == 'accepted').length.toString();
        totalAmount = _isLoading ? '₹0' : _calculateTotalAmount('accepted');
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusCount = '0';
        totalAmount = '₹0';
    }

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
                          '${widget.status} Requests',
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
                        '$statusCount requests • Total: $totalAmount',
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
                child: Icon(
                  statusIcon,
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
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatusInfo('Count', statusCount, Icons.format_list_numbered, statusColor),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: statusColor.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildStatusInfo('Amount', totalAmount, Icons.currency_rupee, statusColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
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
          value,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRequestsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF667eea),
        ),
      );
    }
    
    final requests = _getRequestsForStatus();
    
    if (requests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No ${widget.status.toLowerCase()} transactions found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
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
              'Transaction Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return _buildRequestItem(request);
          },
        ),
      ],
    );
  }

  Widget _buildRequestItem(Map<String, dynamic> request) {
    Color statusColor;
    switch (request['status'].toLowerCase()) {
      case 'pending':
        statusColor = const Color(0xFFFF9800);
        break;
      case 'rejected':
        statusColor = const Color(0xFFFF5722);
        break;
      case 'accepted':
        statusColor = const Color(0xFF4CAF50);
        break;
      default:
        statusColor = Colors.grey;
    }

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(request['icon'], color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request['description'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request['status'],
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  request['date'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const Spacer(),
                if (request['amount'] != null) ...[
                  Icon(Icons.currency_rupee, size: 14, color: Colors.grey[500]),
                  Text(
                    request['amount'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getRequestsForStatus() {
    return _realTransactions.where((transaction) => 
      transaction['status'].toLowerCase() == widget.status.toLowerCase()
    ).toList();
  }
  
  
  Future<void> _loadTransactionData() async {
    try {
      final session = await SessionManager.getSession();
      if (session != null) {
        final response = await SupabaseService.client
            .rpc('authenticate_with_access_key', params: {
          'access_key_input': session['accessKey'],
        });
        
        if (response != null && response.isNotEmpty) {
          _userData = response[0];
          final userId = SupabaseService.getCurrentUser()?.id;
          final selectedEmployee = _userData!['selected_employee'];
          
          if (userId != null && selectedEmployee != null) {
            String employeeName = selectedEmployee;
            if (employeeName.contains('(')) {
              employeeName = employeeName.split('(')[0].trim();
            }
            
            // Load journal entries for selected employee only
            final journalResponse = await SupabaseService.client
                .from('journal_entries')
                .select('*, journals!inner(journal_date, voucher_no, voucher_type)')
                .eq('user_id', userId)
                .eq('account', employeeName)
                .order('id', ascending: false)
                .limit(20);
            
            final expenseAccount = _userData!['expense_account'] ?? 'Expense Account';
            
            _realTransactions = journalResponse.map<Map<String, dynamic>>((entry) {
              final debit = entry['debit_amount'] ?? 0.0;
              final credit = entry['credit_amount'] ?? 0.0;
              final isIncome = debit > 0;
              
              // Simulate status based on amount (for demo)
              String status;
              if (credit > 5000) {
                status = 'Pending';
              } else if (credit > 2000) {
                status = 'Accepted';
              } else {
                status = 'Rejected';
              }
              
              return {
                'title': isIncome ? 'From $expenseAccount' : 'To $expenseAccount',
                'description': entry['short_narration'] ?? 'Transaction',
                'status': status,
                'date': _formatDate(entry['journals']['journal_date']),
                'icon': isIncome ? Icons.trending_up : Icons.trending_down,
                'amount': isIncome ? '+₹${debit.toStringAsFixed(0)}' : '-₹${credit.toStringAsFixed(0)}',
              };
            }).toList();
          }
        }
      }
    } catch (e) {
      print('Error loading transaction data: $e');
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
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else {
        return '$difference days ago';
      }
    } catch (e) {
      return dateStr;
    }
  }
  
  String _calculateTotalAmount(String status) {
    final filteredTransactions = _realTransactions.where((t) => 
      t['status'].toLowerCase() == status.toLowerCase()
    ).toList();
    
    double total = 0.0;
    for (var transaction in filteredTransactions) {
      final amountStr = transaction['amount'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
      final amount = double.tryParse(amountStr) ?? 0.0;
      total += amount;
    }
    
    return '₹${total.toStringAsFixed(0)}';
  }

  Future<void> _refreshTransactionData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadTransactionData();
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
}