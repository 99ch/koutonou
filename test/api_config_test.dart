import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:koutonou/core/api/api_config.dart';
import 'package:koutonou/core/utils/constants.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  final apiConfig = ApiConfig();

  // Test base URL
  print('Base URL: ${apiConfig.baseUrl}'); // Should print local or prod URL based on isProduction
  print('Dio Base URL: ${apiConfig.dio.options.baseUrl}');
  print('Headers: ${apiConfig.dio.options.headers}');

  // Test environment switching
  print('Is Production: ${ApiConfig.isProduction}');
}