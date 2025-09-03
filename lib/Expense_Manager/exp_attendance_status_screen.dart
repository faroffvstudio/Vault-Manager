// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AttendanceStatusScreen extends StatefulWidget {
  final String type;
  
  const AttendanceStatusScreen({super.key, required this.type});

  @override
  State<AttendanceStatusScreen> createState() => _AttendanceStatusScreenState();
}

class _AttendanceStatusScreenState extends State<AttendanceStatusScreen>
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
              _buildStatusHeader(),
              const SizedBox(height: 24),
              _buildAttendanceList(),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (widget.type.toLowerCase()) {
      case 'this month':
        return 'Monthly Attendance';
      case 'overtime':
        return 'Overtime Records';
      case 'leave left':
        return 'Leave Balance';
      default:
        return 'Attendance Status';
    }
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
                      _getTitle(),
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
                    'View your detailed records',
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
              Icons.analytics,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    Color statusColor;
    IconData statusIcon;
    String statusValue;
    String statusDescription;
    
    switch (widget.type.toLowerCase()) {
      case 'this month':
        statusColor = const Color(0xFF4CAF50);
        statusIcon = Icons.calendar_month;
        statusValue = '22 Days';
        statusDescription = 'Present this month';
        break;
      case 'overtime':
        statusColor = const Color(0xFFFF9800);
        statusIcon = Icons.schedule;
        statusValue = '15 Hours';
        statusDescription = 'Extra hours worked';
        break;
      case 'leave left':
        statusColor = const Color(0xFF2196F3);
        statusIcon = Icons.beach_access;
        statusValue = '8 Days';
        statusDescription = 'Remaining leave balance';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusValue = '0';
        statusDescription = 'No data';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [statusColor, statusColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(statusIcon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusValue,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusDescription,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    final records = _getRecordsForType();
    
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
              'Detailed Records',
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
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return _buildRecordItem(record);
          },
        ),
      ],
    );
  }

  Widget _buildRecordItem(Map<String, dynamic> record) {
    Color statusColor = _getStatusColor(record['status']);

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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(record['icon'], color: statusColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record['date'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record['details'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    record['status'],
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (record['hours'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    record['hours'],
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
      case 'approved':
        return const Color(0xFF4CAF50);
      case 'absent':
      case 'rejected':
        return const Color(0xFFFF5722);
      case 'late':
      case 'pending':
        return const Color(0xFFFF9800);
      case 'overtime':
        return const Color(0xFF2196F3);
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> _getRecordsForType() {
    switch (widget.type.toLowerCase()) {
      case 'this month':
        return [
          {
            'date': 'Dec 15, 2023',
            'details': 'Check-in: 9:00 AM, Check-out: 6:00 PM',
            'status': 'Present',
            'icon': Icons.check_circle,
            'hours': '9h 0m',
          },
          {
            'date': 'Dec 14, 2023',
            'details': 'Check-in: 9:15 AM, Check-out: 6:00 PM',
            'status': 'Late',
            'icon': Icons.schedule,
            'hours': '8h 45m',
          },
          {
            'date': 'Dec 13, 2023',
            'details': 'Check-in: 8:45 AM, Check-out: 6:30 PM',
            'status': 'Present',
            'icon': Icons.check_circle,
            'hours': '9h 45m',
          },
          {
            'date': 'Dec 12, 2023',
            'details': 'Sick leave approved',
            'status': 'Absent',
            'icon': Icons.cancel,
            'hours': null,
          },
          {
            'date': 'Dec 11, 2023',
            'details': 'Check-in: 9:00 AM, Check-out: 7:00 PM',
            'status': 'Overtime',
            'icon': Icons.access_time,
            'hours': '10h 0m',
          },
        ];
      case 'overtime':
        return [
          {
            'date': 'Dec 11, 2023',
            'details': 'Project deadline work',
            'status': 'Overtime',
            'icon': Icons.work,
            'hours': '2h 0m',
          },
          {
            'date': 'Dec 8, 2023',
            'details': 'Client presentation preparation',
            'status': 'Overtime',
            'icon': Icons.slideshow,
            'hours': '3h 30m',
          },
          {
            'date': 'Dec 5, 2023',
            'details': 'Bug fixing and testing',
            'status': 'Overtime',
            'icon': Icons.bug_report,
            'hours': '1h 45m',
          },
          {
            'date': 'Dec 2, 2023',
            'details': 'Weekend deployment',
            'status': 'Overtime',
            'icon': Icons.weekend,
            'hours': '4h 0m',
          },
          {
            'date': 'Nov 28, 2023',
            'details': 'Emergency server maintenance',
            'status': 'Overtime',
            'icon': Icons.settings,
            'hours': '3h 45m',
          },
        ];
      case 'leave left':
        return [
          {
            'date': 'Annual Leave',
            'details': '15 days allocated, 7 days used',
            'status': 'Available',
            'icon': Icons.beach_access,
            'hours': '8 days',
          },
          {
            'date': 'Sick Leave',
            'details': '10 days allocated, 2 days used',
            'status': 'Available',
            'icon': Icons.medical_services,
            'hours': '8 days',
          },
          {
            'date': 'Personal Leave',
            'details': '5 days allocated, 1 day used',
            'status': 'Available',
            'icon': Icons.person,
            'hours': '4 days',
          },
          {
            'date': 'Maternity Leave',
            'details': '90 days allocated, 0 days used',
            'status': 'Available',
            'icon': Icons.child_care,
            'hours': '90 days',
          },
          {
            'date': 'Compensatory Off',
            'details': '3 days earned, 1 day used',
            'status': 'Available',
            'icon': Icons.schedule,
            'hours': '2 days',
          },
        ];
      default:
        return [];
    }
  }
}