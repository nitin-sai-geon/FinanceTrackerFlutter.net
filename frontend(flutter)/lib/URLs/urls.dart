import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiUrls {
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:5274/api';

  static String get login => '$baseUrl/Auth/Login';
  static String get register => '$baseUrl/Auth/Register';
  static String get profile => '$baseUrl/Auth/Profile';
  static String get updateProfile => '$baseUrl/Auth/UpdateProfile';
  static String get transactions => '$baseUrl/v1/Transactions';
  static String get categories => '$baseUrl/Categories';

  static String transactionById(String id) => '$transactions/$id';

  static String transactionsPaginated({int pageNumber = 1, int pageSize = 10}) {
    return '$transactions?pageNumber=$pageNumber&pageSize=$pageSize';
  }
}
