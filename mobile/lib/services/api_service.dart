import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Android Emulator
  // static const String baseUrl = 'http://10.0.2.2:8000';

  // Linux/Desktop
  static const String baseUrl = 'http://127.0.0.1:8000';

  // Physical Android phone:
  // static const String baseUrl = 'http://192.168.1.100:8000';

  static const FlutterSecureStorage storage =
      FlutterSecureStorage();

  // --------------------------------------------------
  // CHECK EMAIL / PHONE
  // --------------------------------------------------

  static Future<Map<String, dynamic>> checkIdentifier(
      String identifier) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/check-identifier/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'identifier': identifier,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(
      data['detail'] ??
          data['identifier'] ??
          'Request failed',
    );
  }

  // --------------------------------------------------
  // SEND OTP
  // --------------------------------------------------

  static Future<Map<String, dynamic>> sendOtp({
    required String identifier,
    required String purpose,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/send-otp/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'identifier': identifier,
        'purpose': purpose,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(
      data['detail'] ??
          data['identifier'] ??
          'Failed to send OTP',
    );
  }

  // --------------------------------------------------
  // VERIFY OTP
  // --------------------------------------------------

  static Future<Map<String, dynamic>> verifyOtp({
    required String identifier,
    required String otp,
    required String purpose,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/verify-otp/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'identifier': identifier,
        'otp': otp,
        'purpose': purpose,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(
      data['detail'] ??
          data['identifier'] ??
          'OTP verification failed',
    );
  }

  // --------------------------------------------------
  // LOGIN WITH OTP
  // --------------------------------------------------

  static Future<Map<String, dynamic>> loginWithOtp({
    required String identifier,
    required String otp,
  }) async {
    final data = await verifyOtp(
      identifier: identifier,
      otp: otp,
      purpose: 'login',
    );

    await _saveTokens(data);

    return data;
  }

  // --------------------------------------------------
  // PASSWORD LOGIN
  // --------------------------------------------------

  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'identifier': identifier,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await _saveTokens(data);
      return data;
    }

    throw Exception(
      data['detail'] ?? 'Login failed',
    );
  }

  // --------------------------------------------------
  // REGISTER
  // --------------------------------------------------

  static Future<Map<String, dynamic>> register({
    required String registrationToken,
    required String fullName,
    String? dateOfBirth,
    required String password,
    required String confirmPassword,
    required bool acceptedTerms,
    required bool acceptedOffers,
    String? email,
    String? phoneNumber,
    String? avatarPath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/auth/register/'),
    );

    request.fields['registration_token'] =
        registrationToken;

    request.fields['fullName'] =
        fullName;

    if (dateOfBirth != null) {
      request.fields['dateOfBirth'] =
          dateOfBirth;
    }

    request.fields['password'] =
        password;

    request.fields['confirmPassword'] =
        confirmPassword;

    request.fields['acceptedTerms'] =
        acceptedTerms.toString();

    request.fields['acceptedOffers'] =
        acceptedOffers.toString();

    if (email != null && email.isNotEmpty) {
      request.fields['email'] = email;
    }

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      request.fields['phoneNumber'] = phoneNumber;
    }

    if (avatarPath != null && avatarPath.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          avatarPath,
        ),
      );
    }

    final streamedResponse = await request.send();

    final response =
        await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      await _saveTokens(data);
      return data;
    }

    throw Exception(
      data['detail'] ??
          data.toString(),
    );
  }

  // --------------------------------------------------
  // SAVE TOKENS
  // --------------------------------------------------

  static Future<void> _saveTokens(
      Map<String, dynamic> data) async {
    if (data['access'] != null) {
      await storage.write(
        key: 'access_token',
        value: data['access'].toString(),
      );
    }

    if (data['refresh'] != null) {
      await storage.write(
        key: 'refresh_token',
        value: data['refresh'].toString(),
      );
    }
  }

  // --------------------------------------------------
  // GET ACCESS TOKEN
  // --------------------------------------------------

  static Future<String?> getAccessToken() async {
    return await storage.read(
      key: 'access_token',
    );
  }

  // --------------------------------------------------
  // GET REFRESH TOKEN
  // --------------------------------------------------

  static Future<String?> getRefreshToken() async {
    return await storage.read(
      key: 'refresh_token',
    );
  }

  // --------------------------------------------------
  // REFRESH ACCESS TOKEN
  // --------------------------------------------------

  static Future<bool> refreshAccessToken() async {
    final refreshToken =
        await getRefreshToken();

    if (refreshToken == null ||
        refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/api/auth/token/refresh/',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh': refreshToken,
        }),
      );

      if (response.statusCode != 200) {
        // Refresh token is no longer valid.
        await logout();
        return false;
      }

      final data = jsonDecode(response.body);

      if (data['access'] == null) {
        await logout();
        return false;
      }

      await storage.write(
        key: 'access_token',
        value: data['access'].toString(),
      );

      // This supports token rotation if you enable it
      // later in Django.
      if (data['refresh'] != null) {
        await storage.write(
          key: 'refresh_token',
          value: data['refresh'].toString(),
        );
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // --------------------------------------------------
  // RESTORE SESSION
  // --------------------------------------------------

  static Future<bool> restoreSession() async {
    final accessToken =
        await getAccessToken();

    final refreshToken =
        await getRefreshToken();

    // No tokens -> user is logged out.
    if ((accessToken == null ||
            accessToken.isEmpty) &&
        (refreshToken == null ||
            refreshToken.isEmpty)) {
      return false;
    }

    // First try the existing access token.
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me/'),
        headers: {
          'Authorization':
              'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return true;
      }

      // Access token expired.
      if (response.statusCode == 401) {
        return await refreshAccessToken();
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // --------------------------------------------------
  // GET CURRENT USER
  // --------------------------------------------------

  static Future<Map<String, dynamic>> getMe() async {
    String? token =
        await getAccessToken();

    if (token == null ||
        token.isEmpty) {
      throw Exception(
        'User is not authenticated',
      );
    }

    var response = await http.get(
      Uri.parse('$baseUrl/api/auth/me/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    // Access token expired.
    if (response.statusCode == 401) {
      final refreshed =
          await refreshAccessToken();

      if (!refreshed) {
        throw Exception(
          'Session expired. Please login again.',
        );
      }

      token = await getAccessToken();

      // Retry request with new access token.
      response = await http.get(
        Uri.parse('$baseUrl/api/auth/me/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
    }

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(
      data['detail'] ??
          'Failed to get user',
    );
  }

  // --------------------------------------------------
  // IS LOGGED IN
  // --------------------------------------------------

  static Future<bool> isLoggedIn() async {
    final accessToken =
        await getAccessToken();

    final refreshToken =
        await getRefreshToken();

    return (accessToken != null &&
            accessToken.isNotEmpty) ||
        (refreshToken != null &&
            refreshToken.isNotEmpty);
  }

  // --------------------------------------------------
  // LOGOUT
  // --------------------------------------------------

  static Future<void> logout() async {
    await storage.delete(
      key: 'access_token',
    );

    await storage.delete(
      key: 'refresh_token',
    );
  }
}


