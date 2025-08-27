import 'package:flutter/material.dart';

class TransactionStatusScreen extends StatefulWidget {
  final String status;
  
  const TransactionStatusScreen({super.key, required this.status});

  @override
  State<TransactionStatusScreen> createState() => _TransactionStatusScreenState();
}

class _TransactionStatusScreenState extends State<TransactionStatusScreen>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildRequestsList(),
            ],
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
        statusCount = '5';
        totalAmount = '₹9,200';
        break;
      case 'rejected':
        statusColor = const Color(0xFFFF5722);
        statusIcon = Icons.cancel;
        statusCount = '2';
        totalAmount = '₹85,000';
        break;
      case 'accepted':
        statusColor = const Color(0xFF4CAF50);
        statusIcon = Icons.check_circle;
        statusCount = '12';
        totalAmount = '₹23,300';
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
    final requests = _getRequestsForStatus();
    
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
              'Request Details',
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
    switch (widget.status.toLowerCase()) {
      case 'pending':
        return [
          {
            'title': 'Leave Application',
            'description': 'Annual leave for vacation',
            'status': 'Pending',
            'date': 'Dec 15, 2023',
            'icon': Icons.event_busy,
            'amount': null,
          },
          {
            'title': 'Expense Reimbursement',
            'description': 'Travel expenses for client meeting',
            'status': 'Pending',
            'date': 'Dec 14, 2023',
            'icon': Icons.receipt,
            'amount': '₹2,500',
          },
          {
            'title': 'Overtime Request',
            'description': 'Weekend work compensation',
            'status': 'Pending',
            'date': 'Dec 13, 2023',
            'icon': Icons.schedule,
            'amount': '₹1,200',
          },
          {
            'title': 'Work From Home',
            'description': 'Remote work request',
            'status': 'Pending',
            'date': 'Dec 12, 2023',
            'icon': Icons.home,
            'amount': null,
          },
          {
            'title': 'Training Request',
            'description': 'Flutter development course',
            'status': 'Pending',
            'date': 'Dec 11, 2023',
            'icon': Icons.school,
            'amount': '₹5,000',
          },
        ];
      case 'rejected':
        return [
          {
            'title': 'Salary Advance',
            'description': 'Emergency fund request',
            'status': 'Rejected',
            'date': 'Dec 10, 2023',
            'icon': Icons.money,
            'amount': '₹10,000',
          },
          {
            'title': 'Equipment Request',
            'description': 'New laptop for development',
            'status': 'Rejected',
            'date': 'Dec 8, 2023',
            'icon': Icons.laptop,
            'amount': '₹75,000',
          },
        ];
      case 'accepted':
        return [
          {
            'title': 'Medical Reimbursement',
            'description': 'Health checkup expenses',
            'status': 'Accepted',
            'date': 'Dec 7, 2023',
            'icon': Icons.medical_services,
            'amount': '₹3,500',
          },
          {
            'title': 'Leave Application',
            'description': 'Sick leave',
            'status': 'Accepted',
            'date': 'Dec 6, 2023',
            'icon': Icons.event_busy,
            'amount': null,
          },
          {
            'title': 'Bonus Request',
            'description': 'Performance bonus',
            'status': 'Accepted',
            'date': 'Dec 5, 2023',
            'icon': Icons.star,
            'amount': '₹15,000',
          },
          {
            'title': 'Expense Claim',
            'description': 'Client dinner expenses',
            'status': 'Accepted',
            'date': 'Dec 4, 2023',
            'icon': Icons.restaurant,
            'amount': '₹1,800',
          },
          {
            'title': 'Training Approval',
            'description': 'React Native workshop',
            'status': 'Accepted',
            'date': 'Dec 3, 2023',
            'icon': Icons.school,
            'amount': '₹3,000',
          },
        ];
      default:
        return [];
    }
  }
}