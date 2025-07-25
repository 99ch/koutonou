import 'package:flutter_test/flutter_test.dart';
import 'package:koutonou/core/models/error_model.dart';

void main() {
  group('ErrorModel', () {
    test('fromJson parses full error JSON correctly', () {
      final errorJson = {
        'error': {
          'code': 400,
          'message': 'Invalid request: api_key=12345',
          'details': {'field': 'email', 'error': 'Invalid format'},
        }
      };

      final errorModel = ErrorModel.fromJson(errorJson);

      expect(errorModel.code, 400);
      expect(errorModel.message, 'Invalid request: api_key=12345');
      expect(errorModel.details, isNotNull);
      expect(errorModel.details!['field'], 'email');
      expect(errorModel.details!['error'], 'Invalid format');
    });

    test('fromJson handles empty error gracefully', () {
      final incompleteJson = {'error': {}};

      final errorModel = ErrorModel.fromJson(incompleteJson);

      expect(errorModel.code, 0);
      expect(errorModel.message, 'Unknown error');
      expect(errorModel.details, isNull);
    });

    test('fromJson handles missing error key gracefully', () {
      final missingErrorJson = {};

      final errorModel = ErrorModel.fromJson(missingErrorJson);

      expect(errorModel.code, 0);
      expect(errorModel.message, 'Unknown error');
      expect(errorModel.details, isNull);
    });
  });
}
