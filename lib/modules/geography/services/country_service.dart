import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/base_response.dart';
import '../models/country_model.dart';

/// Service for managing countries in PrestaShop
class CountryService extends ApiService {
  CountryService({required super.dio});

  /// Get all countries
  Future<BaseResponse<List<Country>>> getCountries({
    int? limit,
    String? sort,
    String? filter,
    String? display,
  }) async {
    try {
      final Map<String, dynamic> params = {'output_format': 'JSON'};

      if (limit != null) params['limit'] = limit.toString();
      if (sort != null) params['sort'] = sort;
      if (filter != null) params['filter'] = filter;
      if (display != null) params['display'] = display;

      final response = await dio.get('/countries', queryParameters: params);

      if (response.statusCode == 200) {
        final List<Country> countries = [];

        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('countries')) {
          final countriesData = data['countries'];
          if (countriesData is List) {
            for (final countryData in countriesData) {
              if (countryData is Map<String, dynamic>) {
                countries.add(Country.fromJson(countryData));
              }
            }
          } else if (countriesData is Map<String, dynamic>) {
            // Single country
            countries.add(Country.fromJson(countriesData));
          }
        }

        return BaseResponse.success(
          data: countries,
          message: 'Pays récupérés avec succès',
        );
      }

      return BaseResponse.error(
        message:
            'Erreur lors de la récupération des pays: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return BaseResponse.error(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      return BaseResponse.error(message: 'Erreur inattendue: $e');
    }
  }

  /// Get country by ID
  Future<BaseResponse<Country>> getCountry(int countryId) async {
    try {
      final response = await dio.get(
        '/countries/$countryId',
        queryParameters: {'output_format': 'JSON'},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('country')) {
          final country = Country.fromJson(data['country']);
          return BaseResponse.success(
            data: country,
            message: 'Pays récupéré avec succès',
          );
        }
      }

      return BaseResponse.error(message: 'Pays non trouvé');
    } on DioException catch (e) {
      return BaseResponse.error(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      return BaseResponse.error(message: 'Erreur inattendue: $e');
    }
  }

  /// Get countries by zone
  Future<BaseResponse<List<Country>>> getCountriesByZone(int zoneId) async {
    try {
      final response = await dio.get(
        '/countries',
        queryParameters: {
          'output_format': 'JSON',
          'filter[id_zone]': zoneId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final List<Country> countries = [];

        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('countries')) {
          final countriesData = data['countries'];
          if (countriesData is List) {
            for (final countryData in countriesData) {
              if (countryData is Map<String, dynamic>) {
                countries.add(Country.fromJson(countryData));
              }
            }
          } else if (countriesData is Map<String, dynamic>) {
            countries.add(Country.fromJson(countriesData));
          }
        }

        return BaseResponse.success(
          data: countries,
          message: 'Pays de la zone récupérés avec succès',
        );
      }

      return BaseResponse.error(
        message:
            'Erreur lors de la récupération des pays de la zone: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return BaseResponse.error(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      return BaseResponse.error(message: 'Erreur inattendue: $e');
    }
  }

  /// Create a new country
  Future<BaseResponse<Country>> createCountry(Country country) async {
    try {
      final xmlData = country.toXml();

      final response = await dio.post(
        '/countries',
        data: xmlData,
        options: Options(
          contentType: 'application/xml',
          headers: {'Content-Type': 'application/xml'},
        ),
      );

      if (response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('country')) {
          final createdCountry = Country.fromJson(data['country']);
          return BaseResponse.success(
            data: createdCountry,
            message: 'Pays créé avec succès',
          );
        }
      }

      return BaseResponse.error(
        message: 'Erreur lors de la création du pays: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return BaseResponse.error(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      return BaseResponse.error(message: 'Erreur inattendue: $e');
    }
  }

  /// Update a country
  Future<BaseResponse<Country>> updateCountry(Country country) async {
    try {
      if (country.id == null) {
        return BaseResponse.error(
          message: 'ID du pays requis pour la mise à jour',
        );
      }

      final xmlData = country.toXml();

      final response = await dio.put(
        '/countries/${country.id}',
        data: xmlData,
        options: Options(
          contentType: 'application/xml',
          headers: {'Content-Type': 'application/xml'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('country')) {
          final updatedCountry = Country.fromJson(data['country']);
          return BaseResponse.success(
            data: updatedCountry,
            message: 'Pays mis à jour avec succès',
          );
        }
      }

      return BaseResponse.error(
        message:
            'Erreur lors de la mise à jour du pays: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return BaseResponse.error(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      return BaseResponse.error(message: 'Erreur inattendue: $e');
    }
  }

  /// Delete a country
  Future<BaseResponse<bool>> deleteCountry(int countryId) async {
    try {
      final response = await dio.delete('/countries/$countryId');

      if (response.statusCode == 200) {
        return BaseResponse.success(
          data: true,
          message: 'Pays supprimé avec succès',
        );
      }

      return BaseResponse.error(
        message:
            'Erreur lors de la suppression du pays: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return BaseResponse.error(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      return BaseResponse.error(message: 'Erreur inattendue: $e');
    }
  }

  /// Search countries by name or ISO code
  Future<BaseResponse<List<Country>>> searchCountries(String query) async {
    try {
      final response = await dio.get(
        '/countries',
        queryParameters: {'output_format': 'JSON', 'filter[name]': '%$query%'},
      );

      if (response.statusCode == 200) {
        final List<Country> countries = [];

        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('countries')) {
          final countriesData = data['countries'];
          if (countriesData is List) {
            for (final countryData in countriesData) {
              if (countryData is Map<String, dynamic>) {
                countries.add(Country.fromJson(countryData));
              }
            }
          } else if (countriesData is Map<String, dynamic>) {
            countries.add(Country.fromJson(countriesData));
          }
        }

        return BaseResponse.success(
          data: countries,
          message: 'Recherche effectuée avec succès',
        );
      }

      return BaseResponse.error(
        message: 'Erreur lors de la recherche: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return BaseResponse.error(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      return BaseResponse.error(message: 'Erreur inattendue: $e');
    }
  }
}
