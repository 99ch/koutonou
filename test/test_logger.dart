import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:koutonou/core/utils/logger.dart';
import 'package:koutonou/core/utils/constants.dart';

void main() {
  group('AppLogger Tests', () {
    final logger = AppLogger();

    /// Buffer pour capturer les sorties print
    final StringBuffer _capturedBuffer = StringBuffer();

    /// Fonction pour intercepter les prints
    Future<String> captureOutput(FutureOr<void> Function() testFn) async {
      final spec = ZoneSpecification(
        print: (self, parent, zone, line) {
          _capturedBuffer.writeln(line);
        },
      );

      _capturedBuffer.clear();

      /// run() est synchrone, donc pas d'await ici
      Zone.current.fork(specification: spec).run<void>(testFn);

      return _capturedBuffer.toString();
    }

    Future<void> _testSanitizedLogging(FutureOr<void> Function(String) logMethod, String secretKey, String secretValue) async {
      if (!AppConstants.isDebugMode) {
        expect(() => logMethod('$secretKey=$secretValue'), returnsNormally);
        return;
      }

      final output = await captureOutput(() => logMethod('$secretKey=$secretValue'));
      expect(output.contains('$secretKey=****'), isTrue);
      expect(output.contains(secretValue), isFalse);
    }

    test('debug() logs sanitized message', () async {
      await _testSanitizedLogging(logger.debug, 'api_key', '123456789');
    });

    test('info() logs sanitized message', () async {
      await _testSanitizedLogging(logger.info, 'passwd', 'mypassword');
    });

    test('warning() logs sanitized message', () async {
      await _testSanitizedLogging(logger.warning, 'token', 'secretToken123');
    });

    test('error() logs sanitized message with error and stacktrace', () async {
      if (!AppConstants.isDebugMode) {
        expect(() => logger.error('token=secretToken', Exception('TestError'), StackTrace.current), returnsNormally);
        return;
      }

      final output = await captureOutput(() {
        logger.error('token=secretToken', Exception('TestError'), StackTrace.current);
      });

      expect(output.contains('token=****'), isTrue);
      expect(output.contains('secretToken'), isFalse);
    });
  });
}
