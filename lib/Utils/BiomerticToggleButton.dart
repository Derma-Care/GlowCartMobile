import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _biometricEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBiometricSetting();
  }

  Future<void> _loadBiometricSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _biometricEnabled = prefs.getBool('isAuthenticated') ?? false;
      _loading = false;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      // User wants to enable biometrics → ask for authentication
      try {
        bool canCheck = await auth.canCheckBiometrics;
        if (!canCheck) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Biometrics not available")),
          );
          return;
        }

        bool didAuthenticate = await auth.authenticate(
          localizedReason: "Enable biometric login",
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (didAuthenticate) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isAuthenticated', true);

          setState(() => _biometricEnabled = true);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Biometrics enabled")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error enabling biometrics: $e")),
        );
      }
    } else {
      // User wants to disable biometrics
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', false);

      setState(() => _biometricEnabled = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🚫 Biometrics disabled")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Enable Biometric Login"),
            subtitle: const Text("Use fingerprint or face ID to login faster"),
            value: _biometricEnabled,
            onChanged: (value) {
              _toggleBiometric(value);
            },
          ),
          const Divider(),
          // Add other settings here...
        ],
      ),
    );
  }
}
