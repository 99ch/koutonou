import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:koutonou/core/models/error_model.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');

  // Test parsing a valid error response
  final errorJson = {
    'error': {
      'code': 400,
      'message': 'Invalid request: api_key=12345',
      'details': {'field': 'email', 'error': 'Invalid format'},
    }
  };
  final errorModel = ErrorModel.fromJson(errorJson);
  print('Code: ${errorModel.code}'); // Should print: 400
  print('Message: ${errorModel.message}'); // Should print: Invalid request...
  print('Details: ${errorModel.details}'); // Should print: {field: email, error: Invalid format}
  print('User Message: ${errorModel.userMessage}'); // Should print sanitized message via ErrorHandler

  // Test parsing an incomplete error response
  final incompleteJson = {'error': {}};
  final incompleteError = ErrorModel.fromJson(incompleteJson);
  print('Code: ${incompleteError.code}'); // Should print: 0
  print('Message: ${incompleteError.message}'); // Should print: Unknown error
  print('Details: ${incompleteError.details}'); // Should print: null
}