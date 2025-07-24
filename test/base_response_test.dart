import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:koutonou/core/models/base_response.dart';
import 'package:koutonou/core/models/error_model.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');

  // Test successful response
  final successJson = {
    'success': true,
    'data': {'id': 1, 'name': 'Test Product'},
  };
  final successResponse = BaseResponse<Map<String, dynamic>>.fromJson(
    successJson,
    (json) => json as Map<String, dynamic>,
  );
  print('Success: ${successResponse.success}'); // Should print: true
  print('Data: ${successResponse.data}'); // Should print: {id: 1, name: Test Product}
  print('Error: ${successResponse.error}'); // Should print: null
  print('User Message: ${successResponse.userMessage}'); // Should print: null

  // Test error response
  final errorJson = {
    'success': false,
    'error': {
      'code': 400,
      'message': 'Invalid request: api_key=12345',
      'details': {'field': 'email', 'error': 'Invalid format'},
    },
  };
  final errorResponse = BaseResponse<Map<String, dynamic>>.fromJson(
    errorJson,
    (json) => json as Map<String, dynamic>,
  );
  print('Success: ${errorResponse.success}'); // Should print: false
  print('Data: ${errorResponse.data}'); // Should print: null
  print('Error: ${errorResponse.error?.toJson()}'); // Should print error details
  print('User Message: ${errorResponse.userMessage}'); // Should print sanitized message
}