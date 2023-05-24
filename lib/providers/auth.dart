import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expireDate;
  String? _userId;
  Timer? _authTimer;
  bool get isAuth {
    return _token != null;
  }

  String? get userId {
    return _userId;
  }

  String? get token {
    if (_expireDate != null &&
        _expireDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> signup(String email, String password) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyBLPS4YBN_H-Pb8mkGP7EwZxJUoQ1XwxVQ');
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw Exception(
            'There was an error :' + responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expireDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      notifyListeners();
    } catch (err) {
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyBLPS4YBN_H-Pb8mkGP7EwZxJUoQ1XwxVQ');
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw Exception(
            'There was an error :' + responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expireDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autLogout();
      notifyListeners();

      final storedData = await SharedPreferences.getInstance();
      storedData.setString('token', _token!);
      storedData.setString('userId', _userId!);
      storedData.setString('expireDate', _expireDate!.toIso8601String());
      final jsonData = json.encode({
        'token': _token,
        'userId': _userId,
        'expireDate': _expireDate!.toIso8601String(),
      });
      storedData.setString('auth', jsonData);
    } catch (err) {
      rethrow;
    }
  }

  Future<bool> autologin() async {
    print('auth is working');
    final sharedPreference = await SharedPreferences.getInstance();
    if (!sharedPreference.containsKey('auth')) {
      return false;
    }

    final expiryDate =
        DateTime.parse(sharedPreference.getString('expireDate') as String);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = sharedPreference.getString('token') as String;
    _userId = sharedPreference.getString('userId') as String;
    _expireDate = expiryDate;
    print(_token! + _userId! + _expireDate!.toIso8601String());
    notifyListeners();
    _autLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expireDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    final data = await SharedPreferences.getInstance();
    data.clear();

    notifyListeners();
  }

  void _autLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expireDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
