import 'package:dio/dio.dart';

/// Base service class for API calls
abstract class ApiService {
  final Dio dio;

  ApiService({required this.dio});
}
