// Helper class for PrestaShop API specific operations
// Handles URL generation, parameter formatting, and response parsing
// according to PrestaShop REST API documentation

import 'package:dio/dio.dart';
import 'package:koutonou/core/utils/logger.dart';

class PrestaShopApiHelper {
  static final AppLogger _logger = AppLogger();

  /// Generate PrestaShop API URL with proper formatting
  static String buildApiUrl(String resource, {int? id}) {
    if (id != null) {
      return '/api/$resource/$id';
    }
    return '/api/$resource';
  }

  /// Build query parameters for PrestaShop API
  static Map<String, dynamic> buildQueryParams({
    String? display,
    Map<String, String>? filters,
    List<String>? sort,
    int? limit,
    int? offset,
    String? language,
    bool? date,
    String? outputFormat,
    int? idShop,
    int? idGroupShop,
  }) {
    final params = <String, dynamic>{};

    // Display parameter: 'full' or '[field1,field2]'
    if (display != null) {
      params['display'] = display;
    }

    // Filter parameters: filter[field]=[value]
    if (filters != null) {
      for (final entry in filters.entries) {
        params['filter[${entry.key}]'] = '[${entry.value}]';
      }
    }

    // Sort parameter: [field1_ASC,field2_DESC]
    if (sort != null && sort.isNotEmpty) {
      params['sort'] = '[${sort.join(',')}]';
    }

    // Limit parameter: offset,limit or just limit
    if (limit != null) {
      if (offset != null && offset > 0) {
        params['limit'] = '${offset - 1},$limit';
      } else {
        params['limit'] = limit.toString();
      }
    }

    // Language parameter
    if (language != null) {
      params['language'] = language;
    }

    // Date parameter (required for date filtering)
    if (date == true) {
      params['date'] = '1';
    }

    // Output format
    if (outputFormat != null) {
      params['output_format'] = outputFormat;
    }

    // Multistore parameters
    // id_shop = Contexte d'une boutique spécifique (ex: boutique France)
    if (idShop != null) {
      params['id_shop'] = idShop.toString();
    }
    // id_group_shop = Contexte d'un groupe de boutiques (ex: groupe Europe)
    if (idGroupShop != null) {
      params['id_group_shop'] = idGroupShop.toString();
    }

    return params;
  }

  /// Parse PrestaShop API response
  static T parseResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
    String resourceName,
  ) {
    try {
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        // Handle single resource response
        if (data.containsKey(resourceName)) {
          return fromJson(data[resourceName] as Map<String, dynamic>);
        }

        // Handle direct response
        return fromJson(data);
      }

      throw Exception('Invalid response format');
    } catch (e) {
      _logger.error('Error parsing PrestaShop response: $e');
      rethrow;
    }
  }

  /// Parse PrestaShop API list response
  static List<T> parseListResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
    String resourceName,
  ) {
    try {
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        // Handle list resource response
        if (data.containsKey('${resourceName}s')) {
          final items = data['${resourceName}s'];
          if (items is List) {
            return items
                .whereType<Map<String, dynamic>>()
                .map(fromJson)
                .toList();
          } else if (items is Map<String, dynamic> &&
              items.containsKey(resourceName)) {
            final resourceList = items[resourceName];
            if (resourceList is List) {
              return resourceList
                  .whereType<Map<String, dynamic>>()
                  .map(fromJson)
                  .toList();
            }
          }
        }

        // Handle direct list response
        if (data.containsKey(resourceName) && data[resourceName] is List) {
          return (data[resourceName] as List)
              .whereType<Map<String, dynamic>>()
              .map(fromJson)
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error parsing PrestaShop list response: $e');
      return [];
    }
  }

  /// Get schema URL for resource
  static String getSchemaUrl(String resource, {bool synopsis = false}) {
    final schemaType = synopsis ? 'synopsis' : 'blank';
    return '/api/$resource?schema=$schemaType';
  }

  /// Format multilingual field for PrestaShop
  static Map<String, dynamic> formatMultilangField(
    String value,
    int languageId,
  ) {
    return {
      'language': [
        {'id': languageId.toString(), 'value': value},
      ],
    };
  }

  /// Format multilingual fields map
  static Map<String, dynamic> formatMultilangFields(
    Map<String, String> values,
    int languageId,
  ) {
    final result = <String, dynamic>{};
    for (final entry in values.entries) {
      result[entry.key] = formatMultilangField(entry.value, languageId);
    }
    return result;
  }

  /// Extract error message from PrestaShop error response
  static String extractErrorMessage(Response response) {
    try {
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        // Check for errors array
        if (data.containsKey('errors') && data['errors'] is List) {
          final errors = data['errors'] as List;
          if (errors.isNotEmpty && errors.first is Map<String, dynamic>) {
            final error = errors.first as Map<String, dynamic>;
            return error['message']?.toString() ?? 'Unknown error';
          }
        }

        // Check for error field
        if (data.containsKey('error')) {
          return data['error'].toString();
        }

        // Check for message field
        if (data.containsKey('message')) {
          return data['message'].toString();
        }
      }

      return 'API Error: ${response.statusCode}';
    } catch (e) {
      return 'Error parsing response: $e';
    }
  }

  /// Validate PrestaShop response
  static bool isValidResponse(Response response) {
    return response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 400;
  }

  /// Handle PrestaShop specific price parameters
  static Map<String, dynamic> buildPriceParams({
    String? alias,
    bool? useTax,
    bool? useReduction,
    bool? onlyReduction,
    bool? useEcotax,
    int? productAttribute,
    int? country,
    int? state,
    int? postcode,
    int? currency,
    int? group,
    int? quantity,
    int? decimals,
  }) {
    if (alias == null) return {};

    final priceParams = <String, String>{};

    if (useTax != null) {
      priceParams['use_tax'] = useTax ? '1' : '0';
    }
    if (useReduction != null) {
      priceParams['use_reduction'] = useReduction ? '1' : '0';
    }
    if (onlyReduction != null) {
      priceParams['only_reduction'] = onlyReduction ? '1' : '0';
    }
    if (useEcotax != null) priceParams['use_ecotax'] = useEcotax ? '1' : '0';
    if (productAttribute != null) {
      priceParams['product_attribute'] = productAttribute.toString();
    }
    if (country != null) priceParams['country'] = country.toString();
    if (state != null) priceParams['state'] = state.toString();
    if (postcode != null) priceParams['postcode'] = postcode.toString();
    if (currency != null) priceParams['currency'] = currency.toString();
    if (group != null) priceParams['group'] = group.toString();
    if (quantity != null) priceParams['quantity'] = quantity.toString();
    if (decimals != null) priceParams['decimals'] = decimals.toString();

    final result = <String, dynamic>{};
    for (final entry in priceParams.entries) {
      result['price[$alias][${entry.key}]'] = entry.value;
    }

    return result;
  }
}
