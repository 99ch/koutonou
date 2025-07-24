import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../lib/core/utils/constants.dart';
Future<void> main() async {
  await dotenv.load(fileName: '.env');
  print('Local URL: ${AppConstants.apiBaseUrlLocal}');
  print('Prod URL: ${AppConstants.apiBaseUrlProd}');
  print('API Key: ${AppConstants.apiKey}');
  print('Debug Mode: ${AppConstants.isDebugMode}');
}