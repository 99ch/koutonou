import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:koutonou/core/utils/constants.dart';
import 'package:koutonou/core/utils/logger.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  final logger = AppLogger();

  // Test different log levels
  logger.debug('Debug message: Sending API request');
  logger.info('Info message: User logged in');
  logger.warning('Warning message: Empty response received');
  logger.error('Error message: API failed', Exception('Test error'));

  // Test sensitive data sanitization
  logger.info('Sensitive data: api_key=12345&passwd=secret');
}