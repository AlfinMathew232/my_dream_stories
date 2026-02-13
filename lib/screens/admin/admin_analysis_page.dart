import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';
import 'package:intl/intl.dart';

class AdminAnalysisPage extends StatefulWidget {
  const AdminAnalysisPage({super.key});

  @override
  State<AdminAnalysisPage> createState() => _AdminAnalysisPageState();
}

class _AdminAnalysisPageState extends State<AdminAnalysisPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  String _activeFilter = 'Week';

  void _setFilter(String filter) {
    setState(() {
      _activeFilter = filter;
      _endDate = DateTime.now();
      if (filter == 'Week') {
        _startDate = DateTime.now().subtract(const Duration(days: 7));
      } else if (filter == 'Month') {
        _startDate = DateTime.now().subtract(const Duration(days: 30));
      } else if (filter == 'Year') {
        _startDate = DateTime.now().subtract(const Duration(days: 365));
      }
    });
  }

  Future<void> _selectCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _activeFilter = 'Custom';
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Revenue Analysis')),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildRevenueContent()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _filterChip('Week'),
            const SizedBox(width: 8),
            _filterChip('Month'),
            const SizedBox(width: 8),
            _filterChip('Year'),
            const SizedBox(width: 8),
            ActionChip(
              avatar: const Icon(Icons.calendar_month, size: 16),
              label: Text(
                _activeFilter == 'Custom' ? 'Custom Range' : 'Custom',
              ),
              onPressed: _selectCustomRange,
              backgroundColor: _activeFilter == 'Custom'
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _activeFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) _setFilter(label);
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildRevenueContent() {
    // We adjust endDate to include the full day
    final endOfDay = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      23,
      59,
      59,
    );
    final startOfDay = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
    );

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThanOrEqualTo: endOfDay)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        double totalRevenue = 0;
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          totalRevenue += (data['amount'] ?? 0).toDouble();
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTotalCard(totalRevenue),
            const SizedBox(height: 24),
            _buildDateRangeInfo(),
            const SizedBox(height: 16),
            if (docs.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('No transactions found for this period.'),
                ),
              )
            else
              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final ts = data['timestamp'] as Timestamp?;
                final dateStr = ts != null
                    ? DateFormat('MMM dd, yyyy HH:mm').format(ts.toDate())
                    : 'N/A';
                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.green,
                    ),
                    title: Text(data['userEmail'] ?? 'Unknown User'),
                    subtitle: Text(dateStr),
                    trailing: Text(
                      '+ ₹${data['amount']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildTotalCard(double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'TOTAL REVENUE',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${total.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeInfo() {
    final df = DateFormat('MMM dd, yyyy');
    return Row(
      children: [
        const Icon(Icons.info_outline, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          'Showing results from ${df.format(_startDate)} to ${df.format(_endDate)}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
