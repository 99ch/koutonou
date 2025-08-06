import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/base_response.dart';
import '../models/price_range_model.dart';
import '../models/weight_range_model.dart';

class RangeService {
  final ApiClient _apiClient;

  RangeService(this._apiClient);

  // ========== PRICE RANGES ==========

  /// Get all price ranges
  Future<BaseResponse<List<PriceRange>>> getPriceRanges({
    String? display,
    int? limit,
    Map<String, String>? filters,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (display != null) queryParams['display'] = display;
      if (limit != null) queryParams['limit'] = limit.toString();
      if (filters != null) {
        filters.forEach((key, value) {
          queryParams['filter[$key]'] = value;
        });
      }

      final response = await _apiClient.get(
        '/price_ranges',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<PriceRange> ranges = [];

        if (response.data['price_ranges'] != null) {
          final rangesData = response.data['price_ranges'];
          if (rangesData is List) {
            for (final rangeData in rangesData) {
              if (rangeData is Map<String, dynamic>) {
                ranges.add(PriceRange.fromJson(rangeData));
              }
            }
          } else if (rangesData is Map<String, dynamic>) {
            if (rangesData['price_range'] != null) {
              final rangeList = rangesData['price_range'];
              if (rangeList is List) {
                for (final rangeData in rangeList) {
                  ranges.add(PriceRange.fromJson(rangeData));
                }
              } else {
                ranges.add(PriceRange.fromJson(rangeList));
              }
            }
          }
        }

        return BaseResponse.success(data: ranges);
      } else {
        return BaseResponse.error(
          message: 'Failed to load price ranges: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error loading price ranges: $e');
    }
  }

  /// Get price range by ID
  Future<BaseResponse<PriceRange>> getPriceRange(int id) async {
    try {
      final response = await _apiClient.get('/price_ranges/$id');

      if (response.statusCode == 200 && response.data != null) {
        final rangeData = response.data['price_range'] ?? response.data;
        final range = PriceRange.fromJson(rangeData);
        return BaseResponse.success(data: range);
      } else {
        return BaseResponse.error(message: 'Price range not found');
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error loading price range: $e');
    }
  }

  /// Create a new price range
  Future<BaseResponse<PriceRange>> createPriceRange(PriceRange range) async {
    try {
      final response = await _apiClient.post(
        '/price_ranges',
        data: range.toXml(),
        options: Options(headers: {'Content-Type': 'application/xml'}),
      );

      if (response.statusCode == 201 && response.data != null) {
        final rangeData = response.data['price_range'] ?? response.data;
        final createdRange = PriceRange.fromJson(rangeData);
        return BaseResponse.success(data: createdRange);
      } else {
        return BaseResponse.error(
          message: 'Failed to create price range: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error creating price range: $e');
    }
  }

  /// Update an existing price range
  Future<BaseResponse<PriceRange>> updatePriceRange(PriceRange range) async {
    try {
      if (range.id == null) {
        return BaseResponse.error(
          message: 'Price range ID is required for update',
        );
      }

      final response = await _apiClient.put(
        '/price_ranges/${range.id}',
        data: range.toXml(),
        options: Options(headers: {'Content-Type': 'application/xml'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final rangeData = response.data['price_range'] ?? response.data;
        final updatedRange = PriceRange.fromJson(rangeData);
        return BaseResponse.success(data: updatedRange);
      } else {
        return BaseResponse.error(
          message: 'Failed to update price range: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error updating price range: $e');
    }
  }

  /// Delete a price range
  Future<BaseResponse<void>> deletePriceRange(int id) async {
    try {
      final response = await _apiClient.delete('/price_ranges/$id');

      if (response.statusCode == 200) {
        return BaseResponse.success(data: null);
      } else {
        return BaseResponse.error(
          message: 'Failed to delete price range: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error deleting price range: $e');
    }
  }

  /// Get price ranges by carrier
  Future<BaseResponse<List<PriceRange>>> getPriceRangesByCarrier(
    int carrierId,
  ) async {
    return getPriceRanges(filters: {'id_carrier': carrierId.toString()});
  }

  // ========== WEIGHT RANGES ==========

  /// Get all weight ranges
  Future<BaseResponse<List<WeightRange>>> getWeightRanges({
    String? display,
    int? limit,
    Map<String, String>? filters,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (display != null) queryParams['display'] = display;
      if (limit != null) queryParams['limit'] = limit.toString();
      if (filters != null) {
        filters.forEach((key, value) {
          queryParams['filter[$key]'] = value;
        });
      }

      final response = await _apiClient.get(
        '/weight_ranges',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<WeightRange> ranges = [];

        if (response.data['weight_ranges'] != null) {
          final rangesData = response.data['weight_ranges'];
          if (rangesData is List) {
            for (final rangeData in rangesData) {
              if (rangeData is Map<String, dynamic>) {
                ranges.add(WeightRange.fromJson(rangeData));
              }
            }
          } else if (rangesData is Map<String, dynamic>) {
            if (rangesData['weight_range'] != null) {
              final rangeList = rangesData['weight_range'];
              if (rangeList is List) {
                for (final rangeData in rangeList) {
                  ranges.add(WeightRange.fromJson(rangeData));
                }
              } else {
                ranges.add(WeightRange.fromJson(rangeList));
              }
            }
          }
        }

        return BaseResponse.success(data: ranges);
      } else {
        return BaseResponse.error(
          message: 'Failed to load weight ranges: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error loading weight ranges: $e');
    }
  }

  /// Get weight range by ID
  Future<BaseResponse<WeightRange>> getWeightRange(int id) async {
    try {
      final response = await _apiClient.get('/weight_ranges/$id');

      if (response.statusCode == 200 && response.data != null) {
        final rangeData = response.data['weight_range'] ?? response.data;
        final range = WeightRange.fromJson(rangeData);
        return BaseResponse.success(data: range);
      } else {
        return BaseResponse.error(message: 'Weight range not found');
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error loading weight range: $e');
    }
  }

  /// Create a new weight range
  Future<BaseResponse<WeightRange>> createWeightRange(WeightRange range) async {
    try {
      final response = await _apiClient.post(
        '/weight_ranges',
        data: range.toXml(),
        options: Options(headers: {'Content-Type': 'application/xml'}),
      );

      if (response.statusCode == 201 && response.data != null) {
        final rangeData = response.data['weight_range'] ?? response.data;
        final createdRange = WeightRange.fromJson(rangeData);
        return BaseResponse.success(data: createdRange);
      } else {
        return BaseResponse.error(
          message: 'Failed to create weight range: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error creating weight range: $e');
    }
  }

  /// Update an existing weight range
  Future<BaseResponse<WeightRange>> updateWeightRange(WeightRange range) async {
    try {
      if (range.id == null) {
        return BaseResponse.error(
          message: 'Weight range ID is required for update',
        );
      }

      final response = await _apiClient.put(
        '/weight_ranges/${range.id}',
        data: range.toXml(),
        options: Options(headers: {'Content-Type': 'application/xml'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final rangeData = response.data['weight_range'] ?? response.data;
        final updatedRange = WeightRange.fromJson(rangeData);
        return BaseResponse.success(data: updatedRange);
      } else {
        return BaseResponse.error(
          message: 'Failed to update weight range: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error updating weight range: $e');
    }
  }

  /// Delete a weight range
  Future<BaseResponse<void>> deleteWeightRange(int id) async {
    try {
      final response = await _apiClient.delete('/weight_ranges/$id');

      if (response.statusCode == 200) {
        return BaseResponse.success(data: null);
      } else {
        return BaseResponse.error(
          message: 'Failed to delete weight range: ${response.statusMessage}',
        );
      }
    } catch (e) {
      return BaseResponse.error(message: 'Error deleting weight range: $e');
    }
  }

  /// Get weight ranges by carrier
  Future<BaseResponse<List<WeightRange>>> getWeightRangesByCarrier(
    int carrierId,
  ) async {
    return getWeightRanges(filters: {'id_carrier': carrierId.toString()});
  }
}
