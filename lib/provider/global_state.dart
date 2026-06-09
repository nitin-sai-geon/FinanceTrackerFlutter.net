import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:finance_tracker/URLs/urls.dart';
import 'package:finance_tracker/services/dio_client.dart';

class TransactionNotifier extends Notifier<List<Map<String, dynamic>>> {
  static const int _pageSize = 20;
  int _pageNumber = 1;
  String _currentFrom = '';
  String _currentTo = '';

  @override
  List<Map<String, dynamic>> build() => [];

  List<Map<String, dynamic>> _mapTransactions(
    List<dynamic> data,
    List<Map<String, dynamic>> cats,
  ) {
    return data.map((t) {
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
  }

  Future<List<Map<String, dynamic>>> _fetchPage(
    String from,
    String to,
    int page,
  ) async {
    final dio = buildDio(ref);
    final response = await dio.get<dynamic>(
      ApiUrls.transactions,
      queryParameters: {
        'fromDate': from,
        'toDate': to,
        'pageSize': '$_pageSize',
        'pageNumber': '$page',
      },
    );
    final decoded = response.data;
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
    final cats = ref.read(categoriesProvider);
    return _mapTransactions(data, cats);
  }

  Future<void> loadTransactions({
    int? month,
    int? year,
    String? fromDate,
    String? toDate,
  }) async {
    ref.read(transactionsLoadingProvider.notifier).set(true);
    ref.read(transactionsErrorProvider.notifier).set(null);
    ref.read(transactionsHasMoreProvider.notifier).set(false);
    try {
      if (ref.read(categoriesProvider).isEmpty) {
        await ref.read(categoriesProvider.notifier).loadCategories();
      }

      if (fromDate != null && toDate != null) {
        _currentFrom = fromDate;
        _currentTo = toDate;
      } else {
        final now = DateTime.now();
        final m = month ?? now.month;
        final y = year ?? now.year;
        _currentFrom = '$y-${m.toString().padLeft(2, '0')}-01';
        final lastDay = DateTime(y, m + 1, 0).day;
        _currentTo =
            '$y-${m.toString().padLeft(2, '0')}-${lastDay.toString().padLeft(2, '0')}';
      }

      _pageNumber = 1;
      final page = await _fetchPage(_currentFrom, _currentTo, 1);
      state = page;
      ref
          .read(transactionsHasMoreProvider.notifier)
          .set(page.length == _pageSize);
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message'] as String? ?? 'Could not connect to server';
      ref.read(transactionsErrorProvider.notifier).set(msg);
    } catch (_) {
      ref
          .read(transactionsErrorProvider.notifier)
          .set('Could not connect to server');
    } finally {
      ref.read(transactionsLoadingProvider.notifier).set(false);
    }
  }

  Future<void> loadMoreTransactions() async {
    if (!ref.read(transactionsHasMoreProvider)) return;
    if (ref.read(transactionsLoadingMoreProvider)) return;
    ref.read(transactionsLoadingMoreProvider.notifier).set(true);
    try {
      _pageNumber++;
      final page = await _fetchPage(_currentFrom, _currentTo, _pageNumber);
      state = [...state, ...page];
      ref
          .read(transactionsHasMoreProvider.notifier)
          .set(page.length == _pageSize);
    } on DioException {
      _pageNumber--;
    } catch (_) {
      _pageNumber--;
    } finally {
      ref.read(transactionsLoadingMoreProvider.notifier).set(false);
    }
  }

  Future<List<Map<String, dynamic>>> fetchRange({
    int? month,
    int? year,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      if (ref.read(categoriesProvider).isEmpty) {
        await ref.read(categoriesProvider.notifier).loadCategories();
      }
      final cats = ref.read(categoriesProvider);

      final String from;
      final String to;
      if (fromDate != null && toDate != null) {
        from = fromDate;
        to = toDate;
      } else {
        final now = DateTime.now();
        final m = month ?? now.month;
        final y = year ?? now.year;
        from = '$y-${m.toString().padLeft(2, '0')}-01';
        final lastDay = DateTime(y, m + 1, 0).day;
        to =
            '$y-${m.toString().padLeft(2, '0')}-${lastDay.toString().padLeft(2, '0')}';
      }

      final dio = buildDio(ref);
      final response = await dio.get<dynamic>(
        ApiUrls.transactions,
        queryParameters: {'fromDate': from, 'toDate': to, 'pageSize': '100'},
      );

      final decoded = response.data;
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

      return _mapTransactions(data, cats);
    } on DioException {
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> updateTransaction(
    String id,
    Map<String, dynamic> updated,
  ) async {
    final dio = buildDio(ref);
    await dio.put<dynamic>(
      ApiUrls.transactionById(id),
      data: {
        'description': updated['description'],
        'amount': updated['amount'],
        'categoryId': updated['categoryId'],
        'date': updated['date'],
      },
    );
    await loadTransactions();
  }

  Future<void> postTransaction(Map<String, dynamic> transaction) async {
    final dio = buildDio(ref);
    await dio.post<dynamic>(
      ApiUrls.transactions,
      data: {
        'description': transaction['description'],
        'amount': transaction['amount'],
        'categoryId': transaction['categoryId'],
        'date': transaction['date'],
      },
    );
    await loadTransactions();
  }

  Future<void> deleteTransactionApi(Map<String, dynamic> transaction) async {
    final id = transaction['id']?.toString();
    if (id == null) return;
    final dio = buildDio(ref);
    await dio.delete<dynamic>(ApiUrls.transactionById(id));
  }

  Future<String> uploadAttachment(
    String transactionId,
    Uint8List bytes,
    String filename,
  ) async {
    final dio = buildDio(ref);
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: DioMediaType('image', 'png'),
      ),
    });
    final response = await dio.post<dynamic>(
      ApiUrls.transactionAttachment(transactionId),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return (response.data as Map<String, dynamic>)['attachmentPath'] as String;
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

final transactionsLoadingMoreProvider =
    NotifierProvider<_BoolNotifier, bool>(_BoolNotifier.new);

final transactionsHasMoreProvider =
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
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'jwt');
    await storage.delete(key: 'auth_provider');
    state = null;
  }

  Future<void> fetchProfile() async {
    try {
      final dio = buildDio(ref);
      final response = await dio.get<dynamic>(ApiUrls.profile);
      final data = response.data as Map<String, dynamic>;
      state = {
        ...?state,
        'name': data['name'] ?? state?['name'],
        'email': data['email'] ?? state?['email'],
      };
    } on DioException catch (e) {
      debugPrint('fetchProfile error: $e');
    } catch (e) {
      debugPrint('fetchProfile error: $e');
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    String? currentPassword,
    String? newPassword,
  }) async {
    try {
      final dio = buildDio(ref);
      await dio.put<dynamic>(
        ApiUrls.updateProfile,
        data: {
          'name': name,
          'email': email,
          if (currentPassword != null && currentPassword.isNotEmpty)
            'currentPassword': currentPassword,
          if (newPassword != null && newPassword.isNotEmpty)
            'newPassword': newPassword,
        },
      );
      state = {...?state, 'name': name, 'email': email};
      return true;
    } on DioException catch (e) {
      debugPrint('updateProfile error: $e');
      return false;
    } catch (e) {
      debugPrint('updateProfile error: $e');
      return false;
    }
  }

  Future<bool> registerUser(String name, String email, String password) async {
    try {
      final dio = buildDio(ref);
      await dio.post<dynamic>(
        ApiUrls.register,
        data: {
          'name': name,
          'username': email,
          'password': password,
          'roles': ['Reader'],
        },
      );
      return true;
    } on DioException catch (e) {
      debugPrint('Registration error: $e');
      return false;
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
    try {
      final dio = buildDio(ref);
      final response = await dio.get<dynamic>(ApiUrls.categories);
      final decoded = response.data;
      final List<dynamic> data = decoded is List ? decoded : [];
      state = data.map((c) => c as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      debugPrint('loadCategories error: $e');
    }
  }
}

final categoriesProvider =
    NotifierProvider<CategoryNotifier, List<Map<String, dynamic>>>(
      CategoryNotifier.new,
    );
