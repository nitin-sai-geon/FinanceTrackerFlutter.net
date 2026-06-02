import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:finance_tracker/URLs/urls.dart';
import 'package:http/http.dart' as http;

class TransactionNotifier extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() => [];

  Future<void> loadTransactions({int? month, int? year}) async {
    ref.read(transactionsLoadingProvider.notifier).set(true);
    ref.read(transactionsErrorProvider.notifier).set(null);
    try {
      if (ref.read(categoriesProvider).isEmpty) {
        await ref.read(categoriesProvider.notifier).loadCategories();
      }
      final cats = ref.read(categoriesProvider);

      final now = DateTime.now();
      final m = month ?? now.month;
      final y = year ?? now.year;
      final fromDate = '$y-${m.toString().padLeft(2, '0')}-01';
      final lastDay = DateTime(y, m + 1, 0).day;
      final toDate =
          '$y-${m.toString().padLeft(2, '0')}-${lastDay.toString().padLeft(2, '0')}';

      final uri = Uri.parse(ApiUrls.transactions).replace(
        queryParameters: {
          'fromDate': fromDate,
          'toDate': toDate,
          'pageSize': '100',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization':
              'Bearer ${ref.read(currentUserProvider)?['token'] ?? ''}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List<dynamic> data;
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map) {
          data = (decoded['data'] ??
                  decoded['items'] ??
                  decoded['transactions'] ??
                  []) as List<dynamic>;
        } else {
          data = [];
        }

        state = data.map((t) {
          final tx = Map<String, dynamic>.from(t as Map);

          if (tx['category'] is! String) {
            final catId = tx['categoryId']?.toString();
            final match = cats.firstWhere(
              (c) => c['id']?.toString() == catId,
              orElse: () => {'name': '', 'type': 1},
            );
            tx['category'] = match['name']?.toString() ?? '';
            tx['categoryType'] = match['type'] ?? 1;
          } else {
            final catId = tx['categoryId']?.toString();
            final match = cats.firstWhere(
              (c) => c['id']?.toString() == catId,
              orElse: () => {'type': 1},
            );
            tx['categoryType'] = match['type'] ?? 1;
          }

          final rawDate = tx['date'];
          if (rawDate is String) {
            tx['date'] = DateTime.tryParse(rawDate) ?? rawDate;
          }

          return tx;
        }).toList();
      } else {
        ref.read(transactionsErrorProvider.notifier).set(
              'Failed to load transactions (${response.statusCode})',
            );
      }
    } catch (e) {
      ref
          .read(transactionsErrorProvider.notifier)
          .set('Could not connect to server');
    } finally {
      ref.read(transactionsLoadingProvider.notifier).set(false);
    }
  }

  Future<void> updateTransaction(String id, Map<String, dynamic> updated) async {
    final response = await http.put(
      Uri.parse(ApiUrls.transactionById(id)),
      headers: {
        'Authorization':
            'Bearer ${ref.read(currentUserProvider)?['token'] ?? ''}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'description': updated['description'],
        'amount': updated['amount'],
        'categoryId': updated['categoryId'],
        'date': updated['date'],
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      await loadTransactions();
    }
  }

  Future<void> postTransaction(Map<String, dynamic> transaction) async {
    final response = await http.post(
      Uri.parse(ApiUrls.transactions),
      headers: {
        'Authorization':
            'Bearer ${ref.read(currentUserProvider)?['token'] ?? ''}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'description': transaction['description'],
        'amount': transaction['amount'],
        'categoryId': transaction['categoryId'],
        'date': transaction['date'],
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      await loadTransactions();
    }
  }

  Future<void> deleteTransactionApi(Map<String, dynamic> transaction) async {
    final id = transaction['id']?.toString();
    if (id == null) return;
    await http.delete(
      Uri.parse('${ApiUrls.transactions}/$id'),
      headers: {
        'Authorization':
            'Bearer ${ref.read(currentUserProvider)?['token'] ?? ''}',
        'Content-Type': 'application/json',
      },
    );
  }

  void addTransaction(Map<String, dynamic> transaction) {
    state = [...state, transaction];
  }

  void removeTransaction(Map<String, dynamic> transaction) {
    state = state.where((t) => t != transaction).toList();
  }
}

final transactionsProvider =
    NotifierProvider<TransactionNotifier, List<Map<String, dynamic>>>(
      TransactionNotifier.new,
    );

// Loading and error state for transactions
class _BoolNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool v) => state = v;
}

class _NullableStringNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? v) => state = v;
}

final transactionsLoadingProvider =
    NotifierProvider<_BoolNotifier, bool>(_BoolNotifier.new);

final transactionsErrorProvider =
    NotifierProvider<_NullableStringNotifier, String?>(
      _NullableStringNotifier.new,
    );

class CurrentUserNotifier extends Notifier<Map<String, dynamic>?> {
  @override
  Map<String, dynamic>? build() => null;

  void setUser(Map<String, dynamic> user) => state = user;

  Future<void> clearUser() async {
    await const FlutterSecureStorage().delete(key: 'jwt');
    state = null;
  }

  Future<void> fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse(ApiUrls.profile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${state?['token'] ?? ''}',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        state = {
          ...?state,
          'name': data['name'] ?? state?['name'],
          'email': data['email'] ?? state?['email'],
        };
      }
    } catch (e) {
      debugPrint('fetchProfile error: $e');
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String currentPassword,
    String? newPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(ApiUrls.updateProfile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${state?['token'] ?? ''}',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'currentPassword': currentPassword,
          if (newPassword != null && newPassword.isNotEmpty)
            'newPassword': newPassword,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        state = {...?state, 'name': name, 'email': email};
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('updateProfile error: $e');
      return false;
    }
  }

  Future<bool> registerUser(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiUrls.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'username': email,
          'password': password,
          'roles': ['Reader'],
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    }
  }
}

final currentUserProvider =
    NotifierProvider<CurrentUserNotifier, Map<String, dynamic>?>(
      CurrentUserNotifier.new,
    );

class CategoryNotifier extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() => [];

  Future<void> loadCategories() async {
    final response = await http.get(
      Uri.parse(ApiUrls.categories),
      headers: {
        'Authorization':
            'Bearer ${ref.read(currentUserProvider)?['token'] ?? ''}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded is List ? decoded : [];
      state = data.map((c) => c as Map<String, dynamic>).toList();
    }
  }
}

final categoriesProvider =
    NotifierProvider<CategoryNotifier, List<Map<String, dynamic>>>(
      CategoryNotifier.new,
    );
