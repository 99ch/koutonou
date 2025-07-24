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