import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:koutonou/core/api/api_client.dart';
import 'package:koutonou/core/api/api_config.dart';
import 'package:koutonou/core/utils/error_handler.dart';
import 'package:koutonou/core/utils/logger.dart';

import 'package:mockito/annotations.dart';
import 'api_client_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late MockDio mockDio;
  late ApiClient apiClient;

  setUp(() {
    mockDio = MockDio();
    /// Injecte ton mock dans ApiConfig si nécessaire
    ApiConfig().dio.httpClientAdapter = mockDio.httpClientAdapter;
    apiClient = ApiClient();
  });

  group('ApiClient', () {
    test('get() should return data on successful response', () async {
      final mockResponse = Response(
        requestOptions: RequestOptions(path: '?resource=products'),
        statusCode: 200,
        data: {'products': []},
      );

      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => mockResponse);

      final result = await apiClient.get('products');

      expect(result, isA<Map<String, dynamic>>());
      expect(result['products'], isA<List>());
    });

    test('get() should throw error on invalid response', () async {
      final mockResponse = Response(
        requestOptions: RequestOptions(path: '?resource=products'),
        statusCode: 200,
        data: 'invalid response',
      );

      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => mockResponse);

      expect(() => apiClient.get('products'), throwsA(isA<Exception>()));
    });
  });
}
