import 'package:flutter/material.dart';
import 'package:another_telephony/telephony.dart';
import '../utils/permissions.dart';
import '../services/fcm_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Telephony telephony = Telephony.instance;
  Map<String, String> _permissionStatuses = {};
  bool _isLoading = true;
  bool _fcmTokenSaved = false;
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _loadStatus();
    _checkFCMTokenStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);

    final permissions = await PermissionHelper.getPermissionStatuses();

    setState(() {
      _permissionStatuses = permissions;
      _isLoading = false;
    });
  }

  Future<void> _checkFCMTokenStatus() async {
    final saved = await FCMService.isTokenSaved();
    final token = await FCMService.getToken();
    setState(() {
      _fcmTokenSaved = saved;
      _fcmToken = token;
    });
  }

  Future<void> _forceSaveToken() async {
    final result = await FCMService.forceSaveToken();
    if (mounted) {
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ FCM Token saved successfully!')),
        );
        _checkFCMTokenStatus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Failed to save FCM token')),
        );
      }
    }
  }

  void _showTokenDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('FCM Token'),
        content: SelectableText(_fcmToken ?? 'No token available'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _requestAllPermissions() async {
    // Request SMS permission using another_telephony
    await telephony.requestPhoneAndSmsPermissions;
    
    // Request other permissions
    await PermissionHelper.requestAllPermissions();
    await _loadStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('সেটিংস'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Permissions Section
                  const Text(
                    'পারমিশন স্ট্যাটাস',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ..._permissionStatuses.entries.map((entry) =>
                            _buildStatusRow(
                              entry.key,
                              entry.value == 'অনুমোদিত',
                              entry.value,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _requestAllPermissions,
                            icon: const Icon(Icons.security),
                            label: const Text('পারমিশন রিকোয়েস্ট করুন'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // FCM Token Status
                  const Text(
                    'FCM Notification',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Card(
                    child: ListTile(
                      leading: Icon(
                        _fcmTokenSaved ? Icons.check_circle : Icons.error,
                        color: _fcmTokenSaved ? Colors.green : Colors.orange,
                        size: 32,
                      ),
                      title: const Text('FCM Token Status'),
                      subtitle: Text(_fcmTokenSaved 
                        ? 'Token saved ✓ - Notifications will work' 
                        : 'Token not saved - Click to save'),
                      trailing: _fcmTokenSaved 
                        ? IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: _showTokenDialog,
                            tooltip: 'View Token',
                          )
                        : ElevatedButton.icon(
                            onPressed: _forceSaveToken,
                            icon: const Icon(Icons.save),
                            label: const Text('Save'),
                          ),
                      onTap: _fcmTokenSaved ? _showTokenDialog : _forceSaveToken,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App Info
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'AutoPay v1.0.0',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'স্বয়ংক্রিয় SMS পেমেন্ট ট্র্যাকার',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusRow(String label, bool isSuccess, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.cancel,
            color: isSuccess ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: isSuccess ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
