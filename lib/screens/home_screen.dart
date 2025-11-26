import 'package:flutter/material.dart';
import '../services/sms_service.dart';
import '../services/fcm_service.dart';
import '../utils/permissions.dart';
import 'settings_screen.dart';
import 'tabs/payments_tab.dart';
import 'tabs/withdraw_tab.dart';
import 'tabs/message_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeService();
    _ensureFCMTokenSaved();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeService() async {
    // Request all permissions first
    await PermissionHelper.requestAllPermissions();
    
    // SMS service automatically starts and always runs
    await SmsService.initialize();
  }

  Future<void> _ensureFCMTokenSaved() async {
    // Check after 2 seconds (let Firebase initialize)
    await Future.delayed(const Duration(seconds: 2));
    
    final saved = await FCMService.isTokenSaved();
    if (!saved) {
      await FCMService.forceSaveToken();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoPay'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.payment), text: 'Payments'),
            Tab(icon: Icon(Icons.money_off), text: 'Withdraw'),
            Tab(icon: Icon(Icons.message), text: 'Messages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PaymentsTab(),
          WithdrawTab(),
          MessageTab(),
        ],
      ),
    );
  }
}
