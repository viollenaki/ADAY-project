import 'package:flutter/material.dart';
import 'package:personal_finance/database/globals.dart' as globals;
import 'package:personal_finance/generated/l10n.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _selectedCurrency = globals.currentCurrency;
  bool _isFingerprintEnabled = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _selectCurrency(String? value) {
    setState(() {
      _selectedCurrency = value!;
      globals.currentCurrency = value.substring(0, 3);
    });
  }

  void _toggleFingerprint(bool value) {
    setState(() {
      _isFingerprintEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'Settings',
    style: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blueAccent, Colors.purpleAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Toggle
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile.adaptive(
                title: Text(S.of(context).darkMode, style: TextStyle(fontSize: 16)),
                subtitle: Text(_isDarkMode ? S.of(context).enabled : S.of(context).disabled),
                value: _isDarkMode,
                onChanged: (value) => _toggleTheme(),
                secondary:
                    const Icon(Icons.dark_mode, color: Colors.deepPurple),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),

            // Currency Selection
            ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.deepPurple),
              title:
                  Text(S.of(context).selectCurrency, style: TextStyle(fontSize: 16)),
              subtitle: DropdownButtonFormField<String>(
                value: _selectedCurrency,
                onChanged: _selectCurrency,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'USD', child: Text('USD - US Dollar')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
                  DropdownMenuItem(
                      value: 'INR', child: Text('INR - Indian Rupee')),
                  DropdownMenuItem(value: 'KGS', child: Text('KGS - Kyrgyzstan')),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),

            // Fingerprint Authentication
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile.adaptive(
                title: Text(S.of(context).enableFingerprint,
                    style: TextStyle(fontSize: 16)),
                subtitle: Text(_isFingerprintEnabled ? S.of(context).enabled : S.of(context).disabled),
                value: _isFingerprintEnabled,
                onChanged: _toggleFingerprint,
                secondary:
                    const Icon(Icons.fingerprint, color: Colors.deepPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }
}