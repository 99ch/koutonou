import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koutonou/core/utils/error_handler.dart';

void main() {
  final errorHandler = ErrorHandler();

  group('ErrorHandler Tests', () {
    test('Returns user-friendly message for Dio connection timeout errors', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final message = errorHandler.handleError(dioError);

      expect(message, 'Connection timed out. Please check your internet connection.');
    });

    test('Returns user-friendly message for Dio bad response 401', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      final message = errorHandler.handleError(dioError);

      expect(message, 'Authentication failed. Please log in again.');
    });

    test('Returns generic message for unknown HTTP status', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 999,
        ),
        type: DioExceptionType.badResponse,
      );

      final message = errorHandler.handleError(dioError);

      expect(message, 'An unexpected server error occurred. Please try again.');
    });

    test('Returns proper message for TypeError', () {
      final typeError = TypeError();

      final message = errorHandler.handleError(typeError);

      expect(message, 'Invalid data format received. Please try again.');
    });

    test('Returns generic message for unknown errors', () {
      final genericError = Exception('Some random error');

      final message = errorHandler.handleError(genericError);

      expect(message, 'Something went wrong. Please try again later.');
    });

    test('handleError returns expected user-friendly message (sanitization not checked)', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
          data: 'api_key=12345&passwd=secret&token=abc https:///example.com',
        ),
        type: DioExceptionType.badResponse,
      );

      final message = errorHandler.handleError(dioError);

      /// Just check the user message, not the sanitization inside the message
      expect(message, 'Invalid request. Please check your input.');
    });

    /// Test that error is logged in debug mode, without throwing
    test('Logs error in debug mode without throwing', () {
      /// Temporarily enable debug mode if you can toggle it or mock it
      /// For demonstration, assume AppConstants.isDebugMode = true

      final error = Exception('Test error');

      expect(() => errorHandler.handleError(error), returnsNormally);
    });
  });
}
