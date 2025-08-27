import 'package:flutter/material.dart';

class MyLedgerScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const MyLedgerScreen({super.key, this.scrollController});

  @override
  State<MyLedgerScreen> createState() => _MyLedgerScreenState();
}

class _MyLedgerScreenState extends State<MyLedgerScreen>
    with TickerProviderStateMixin {
  bool _isTableView = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _selectedPeriod = 'This Month';

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
    _searchController.dispose();
    super.dispose();
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
              _buildQuickStats(),
              const SizedBox(height: 24),
              _buildSearchAndFilter(),
              const SizedBox(height: 20),
              _isTableView ? _buildTableView() : _buildLedgerEntries(),
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
                        'Net Balance: ₹13,080',
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
                  child: _buildBalanceInfo('Total Income', '₹45,230', Icons.trending_up, const Color(0xFF4CAF50)),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: _buildBalanceInfo('Total Expenses', '₹32,150', Icons.trending_down, const Color(0xFFFF5722)),
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
          child: _buildStatCard('Entries', '156', Icons.receipt_long, const Color(0xFF4CAF50)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Avg. Transaction', '₹2,890', Icons.analytics, const Color(0xFF2196F3)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('This Week', '₹8,450', Icons.analytics, const Color(0xFFFF9800)),
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
    final entries = [
      {
        'title': 'Salary Credit',
        'amount': '+₹25,000',
        'date': 'Today, 9:30 AM',
        'type': 'income',
        'icon': Icons.account_balance_wallet,
        'description': 'Monthly salary deposit',
        'category': 'Salary'
      },
      {
        'title': 'Grocery Shopping',
        'amount': '-₹2,450',
        'date': 'Yesterday, 6:15 PM',
        'type': 'expense',
        'icon': Icons.shopping_cart,
        'description': 'Weekly grocery purchase',
        'category': 'Food & Dining'
      },
      {
        'title': 'Freelance Payment',
        'amount': '+₹8,500',
        'date': '2 days ago, 2:30 PM',
        'type': 'income',
        'icon': Icons.work,
        'description': 'Web development project',
        'category': 'Freelance'
      },
      {
        'title': 'Electricity Bill',
        'amount': '-₹1,200',
        'date': '3 days ago, 11:45 AM',
        'type': 'expense',
        'icon': Icons.flash_on,
        'description': 'Monthly electricity bill',
        'category': 'Utilities'
      },
      {
        'title': 'Investment Return',
        'amount': '+₹3,200',
        'date': '1 week ago, 10:00 AM',
        'type': 'income',
        'icon': Icons.trending_up,
        'description': 'Mutual fund dividend',
        'category': 'Investment'
      },
    ];

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
    final entries = [
      {'sn': '1', 'account': 'Salary Credit', 'debit': '', 'credit': '25,000'},
      {'sn': '2', 'account': 'Grocery Shopping', 'debit': '2,450', 'credit': ''},
      {'sn': '3', 'account': 'Freelance Payment', 'debit': '', 'credit': '8,500'},
      {'sn': '4', 'account': 'Electricity Bill', 'debit': '1,200', 'credit': ''},
      {'sn': '5', 'account': 'Investment Return', 'debit': '', 'credit': '3,200'},
    ];

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
          ...entries.map((entry) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                SizedBox(width: 40, child: Text(entry['sn']!, style: const TextStyle(fontWeight: FontWeight.w500))),
                Expanded(flex: 3, child: Text(entry['account']!, style: const TextStyle(fontWeight: FontWeight.w500))),
                Expanded(
                  child: Text(
                    entry['debit']!.isEmpty ? '-' : '₹${entry['debit']}',
                    style: TextStyle(color: entry['debit']!.isEmpty ? Colors.grey : Colors.red, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    entry['credit']!.isEmpty ? '-' : '₹${entry['credit']}',
                    style: TextStyle(color: entry['credit']!.isEmpty ? Colors.grey : Colors.green, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}