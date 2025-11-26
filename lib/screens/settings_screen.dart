import 'package:flutter/material.dart';
import 'package:another_telephony/telephony.dart';
import '../utils/permissions.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Telephony telephony = Telephony.instance;
  Map<String, String> _permissionStatuses = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _isLoading = true);

    final permissions = await PermissionHelper.getPermissionStatuses();

    setState(() {
      _permissionStatuses = permissions;
      _isLoading = false;
    });
  }

  Future<void> _requestAllPermissions() async {
    // Request SMS permission using another_telephony
    await telephony.requestPhoneAndSmsPermissions;
    
    // Request other permissions
    await PermissionHelper.requestAllPermissions();
    await _loadStatus();
  }
  
  Future<void> _openSettings() async {
    await PermissionHelper.openAppSettings();
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
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _openSettings,
                            icon: const Icon(Icons.settings),
                            label: const Text('সেটিংসে যান (Manual)'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ADB Testing Help
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.developer_mode, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              const Text(
                                'Development/Testing Setup',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'For testing with ADB (USB debugging):\n\n'
                            '1. Enable Developer Options on phone\n'
                            '2. Enable USB Debugging\n'
                            '3. Connect phone via USB\n'
                            '4. Run these commands:\n\n'
                            'adb uninstall com.elbito.autopay\n'
                            'adb install -r app-debug.apk\n'
                            'adb shell pm grant com.elbito.autopay android.permission.READ_SMS\n'
                            'adb shell pm grant com.elbito.autopay android.permission.RECEIVE_SMS\n'
                            'adb shell pm grant com.elbito.autopay android.permission.READ_PHONE_STATE\n'
                            'adb shell pm grant com.elbito.autopay android.permission.POST_NOTIFICATIONS\n\n'
                            'Then launch the app.',
                            style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
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
