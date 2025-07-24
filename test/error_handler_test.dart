import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:koutonou/core/utils/constants.dart';
import 'package:koutonou/core/utils/error_handler.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  final errorHandler = ErrorHandler();

  // Test Dio error (HTTP 401)
  final dioError = DioException(
    requestOptions: RequestOptions(path: '/test'),
    response: Response(
      statusCode: 401,
      requestOptions: RequestOptions(path: '/test'),
    ),
    type: DioExceptionType.badResponse,
  );
  print(errorHandler.handleError(dioError)); // Should print: "Authentication failed..."

  // Test TypeError
  print(errorHandler.handleError(TypeError())); // Should print: "Invalid data format..."

  // Test generic error
  print(errorHandler.handleError(Exception('Test error'))); // Should print: "Something went wrong..."

  // Test sensitive data sanitization
  print(errorHandler.handleError(Exception('Error with api_key=12345&passwd=secret')));
}