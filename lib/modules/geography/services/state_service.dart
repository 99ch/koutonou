import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/base_response.dart';
import '../models/state_model.dart';

/// Service for managing states/provinces in PrestaShop
class StateService extends ApiService {
  StateService({required super.dio});

  /// Get all states
  Future<BaseResponse<List<State>>> getStates({
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

      final response = await dio.get('/states', queryParameters: params);

      if (response.statusCode == 200) {
        final List<State> states = [];

        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('states')) {
          final statesData = data['states'];
          if (statesData is List) {
            for (final stateData in statesData) {
              if (stateData is Map<String, dynamic>) {
                states.add(State.fromJson(stateData));
              }
            }
          } else if (statesData is Map<String, dynamic>) {
            // Single state
            states.add(State.fromJson(statesData));
          }
        }

        return BaseResponse.success(
          data: states,
          message: 'États/Provinces récupérés avec succès',
        );
      }

      return BaseResponse.error(
        message:
            'Erreur lors de la récupération des états: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return BaseResponse.error(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      return BaseResponse.error(message: 'Erreur inattendue: $e');
    }
  }

  /// Get state by ID
  Future<BaseResponse<State>> getState(int stateId) async {
    try {
      final response = await dio.get(
        '/states/$stateId',
        queryParameters: {'output_format': 'JSON'},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('state')) {
          final state = State.fromJson(data['state']);
          return BaseResponse.success(
            data: state,
            message: 'État/Province récupéré avec succès',
          );
        }
      }

      return BaseResponse.error(message: 'État/Province non trouvé');
    } on DioException catch (e) {
      return BaseResponse.error(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      return BaseResponse.error(message: 'Erreur inattendue: $e');
    }
  }

  /// Get states by country
  Future<BaseResponse<List<State>>> getStatesByCountry(int countryId) async {
    try {
      final response = await dio.get(
        '/states',
        queryParameters: {
          'output_format': 'JSON',
          'filter[id_country]': countryId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final List<State> states = [];

        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('states')) {
          final statesData = data['states'];
          if (statesData is List) {
            for (final stateData in statesData) {
              if (stateData is Map<String, dynamic>) {
                states.add(State.fromJson(stateData));
              }
            }
          } else if (statesData is Map<String, dynamic>) {
            states.add(State.fromJson(statesData));
          }
        }

        return BaseResponse.success(
          data: states,
          message: 'États du pays récupérés avec succès',
        );
      }

      return BaseResponse.error(
        message:
            'Erreur lors de la récupération des états du pays: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return BaseResponse.error(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      return BaseResponse.error(message: 'Erreur inattendue: $e');
    }
  }

  /// Get states by zone
  Future<BaseResponse<List<State>>> getStatesByZone(int zoneId) async {
    try {
      final response = await dio.get(
        '/states',
        queryParameters: {
          'output_format': 'JSON',
          'filter[id_zone]': zoneId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final List<State> states = [];

        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('states')) {
          final statesData = data['states'];
          if (statesData is List) {
            for (final stateData in statesData) {
              if (stateData is Map<String, dynamic>) {
                states.add(State.fromJson(stateData));
              }
            }
          } else if (statesData is Map<String, dynamic>) {
            states.add(State.fromJson(statesData));
          }
        }

        return BaseResponse.success(
          data: states,
          message: 'États de la zone récupérés avec succès',
        );
      }

      return BaseResponse.error(
        message:
            'Erreur lors de la récupération des états de la zone: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return BaseResponse.error(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      return BaseResponse.error(message: 'Erreur inattendue: $e');
    }
  }

  /// Create a new state
  Future<BaseResponse<State>> createState(State state) async {
    try {
      final xmlData = state.toXml();

      final response = await dio.post(
        '/states',
        data: xmlData,
        options: Options(
          contentType: 'application/xml',
          headers: {'Content-Type': 'application/xml'},
        ),
      );

      if (response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('state')) {
          final createdState = State.fromJson(data['state']);
          return BaseResponse.success(
            data: createdState,
            message: 'État/Province créé avec succès',
          );
        }
      }

      return BaseResponse.error(
        message:
            'Erreur lors de la création de l\'état: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return BaseResponse.error(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      return BaseResponse.error(message: 'Erreur inattendue: $e');
    }
  }

  /// Update a state
  Future<BaseResponse<State>> updateState(State state) async {
    try {
      if (state.id == null) {
        return BaseResponse.error(
          message: 'ID de l\'état requis pour la mise à jour',
        );
      }

      final xmlData = state.toXml();

      final response = await dio.put(
        '/states/${state.id}',
        data: xmlData,
        options: Options(
          contentType: 'application/xml',
          headers: {'Content-Type': 'application/xml'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('state')) {
          final updatedState = State.fromJson(data['state']);
          return BaseResponse.success(
            data: updatedState,
            message: 'État/Province mis à jour avec succès',
          );
        }
      }

      return BaseResponse.error(
        message:
            'Erreur lors de la mise à jour de l\'état: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return BaseResponse.error(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      return BaseResponse.error(message: 'Erreur inattendue: $e');
    }
  }

  /// Delete a state
  Future<BaseResponse<bool>> deleteState(int stateId) async {
    try {
      final response = await dio.delete('/states/$stateId');

      if (response.statusCode == 200) {
        return BaseResponse.success(
          data: true,
          message: 'État/Province supprimé avec succès',
        );
      }

      return BaseResponse.error(
        message:
            'Erreur lors de la suppression de l\'état: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return BaseResponse.error(message: 'Erreur réseau: ${e.message}');
    } catch (e) {
      return BaseResponse.error(message: 'Erreur inattendue: $e');
    }
  }

  /// Search states by name or ISO code
  Future<BaseResponse<List<State>>> searchStates(String query) async {
    try {
      final response = await dio.get(
        '/states',
        queryParameters: {'output_format': 'JSON', 'filter[name]': '%$query%'},
      );

      if (response.statusCode == 200) {
        final List<State> states = [];

        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('states')) {
          final statesData = data['states'];
          if (statesData is List) {
            for (final stateData in statesData) {
              if (stateData is Map<String, dynamic>) {
                states.add(State.fromJson(stateData));
              }
            }
          } else if (statesData is Map<String, dynamic>) {
            states.add(State.fromJson(statesData));
          }
        }

        return BaseResponse.success(
          data: states,
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
