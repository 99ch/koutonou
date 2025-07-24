import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:koutonou/core/api/api_client.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  final apiClient = ApiClient();

  // Test GET request (e.g., fetch products)
  try {
    final response = await apiClient.get('products', queryParameters: {
      'limit': 10,
      'offset': 0,
    });
    print('GET response: $response');
  } catch (e) {
    print('Error: $e');
  }

  // Test POST request (e.g., create a product)
  try {
    final response = await apiClient.post('products', data: {
      'name': 'Test Product',
      'price': '29.99',
    });
    print('POST response: $response');
  } catch (e) {
    print('Error: $e');
  }
}


/* this is a test file for the ApiClient for the file error_model.dart.
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:koutonou/core/api/api_client.dart';
import 'package:koutonou/core/models/error_model.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  final apiClient = ApiClient();

  try {
    await apiClient.get('invalid_resource'); // Simulate an invalid request
  } catch (e) {
    if (e is String) {
      final errorModel = ErrorModel(
        code: 400,
        message: e,
      );
      print('User Message: ${errorModel.userMessage}');
    }
  }
}*/



/* this is a test file for the ApiClient for the file base_response.dart.
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:koutonou/core/api/api_client.dart';
import 'package:koutonou/core/models/base_response.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  final apiClient = ApiClient();

  try {
    final response = await apiClient.get('products', queryParameters: {
      'limit': 10,
      'offset': 0,
    });
    final baseResponse = BaseResponse<List<Map<String, dynamic>>>.fromJson(
      response,
      (json) => (json as List<dynamic>).cast<Map<String, dynamic>>(),
    );
    print('Success: ${baseResponse.success}');
    print('Data: ${baseResponse.data}');
    print('Error: ${baseResponse.error?.toJson()}');
    print('User Message: ${baseResponse.userMessage}');
  } catch (e) {
    print('Error: $e');
  }
}
*/