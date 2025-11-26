import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/payment_model.dart';
import '../../services/firebase_service.dart';

class MessageTab extends StatefulWidget {
  const MessageTab({super.key});

  @override
  State<MessageTab> createState() => _MessageTabState();
}

class _MessageTabState extends State<MessageTab> {
  int _limit = 10;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  List<PaymentModel> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData(isInitial: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool isInitial = false}) async {
    if (isInitial) {
      setState(() {
        _isLoading = true;
      });
    }
    
    final data = await FirebaseService.getRecentPayments(limit: _limit);
    
    if (mounted) {
      setState(() {
        _payments = data;
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9 && !_isLoadingMore && _payments.length >= _limit - 10) {
      setState(() {
        _isLoadingMore = true;
        _limit += 10;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_payments.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          _limit = 10;
          await _loadData(isInitial: true);
        },
        child: ListView(
          children: const [
            SizedBox(
              height: 400,
              child: Center(
                child: Text(
                  'কোন SMS payment পাওয়া যায়নি',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _limit = 10;
        await _loadData(isInitial: true);
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _isLoadingMore ? _payments.length + 1 : _payments.length,
        itemBuilder: (context, index) {
          if (index == _payments.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          final payment = _payments[index];
          return _buildPaymentCard(payment);
        },
      ),
    );
  }

  Widget _buildPaymentCard(PaymentModel payment) {
    final timeFormat = DateFormat('dd/MM/yyyy hh:mm a');
    final isBkash = payment.method == 'bkash';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isBkash ? Colors.pink : Colors.orange,
          child: Text(
            isBkash ? 'বি' : 'ন',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          '৳ ${NumberFormat('#,##0.00').format(payment.amount)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Method: ${payment.method.toUpperCase()}'),
            Text('From: ${payment.senderNumber}'),
            Text('TrxID: ${payment.transactionId}'),
            Text(timeFormat.format(payment.timestamp)),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
