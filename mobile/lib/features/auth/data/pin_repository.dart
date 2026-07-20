import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final pinRepositoryProvider = Provider<PinRepository>((ref) => PinRepository());

class PinRepository {
  static const _pinHashKey = 'app_pin_hash';
  static const _salt = 'jattau_pin_v1';

  String _hash(String pin) {
    final bytes = utf8.encode('$_salt:$pin');
    return sha256.convert(bytes).toString();
  }

  Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinHashKey);
  }

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinHashKey, _hash(pin));
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_pinHashKey);
    if (stored == null) return false;
    return stored == _hash(pin);
  }

  Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinHashKey);
  }
}
