import 'package:koutonou/core/api/base_prestashop_service.dart';
import 'package:koutonou/core/utils/logger.dart';
import '../models/group_model.dart';

/// Service pour gérer les groupes de clients PrestaShop
class GroupService extends BasePrestaShopService {
  static final GroupService _instance = GroupService._internal();
  factory GroupService() => _instance;
  GroupService._internal();

  static final AppLogger _logger = AppLogger();

  /// Récupère tous les groupes
  Future<List<Group>> getAllGroups({
    String? display = 'full',
    Map<String, String>? filters,
    int? limit,
    int? offset,
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching all groups from PrestaShop API');

    try {
      final queryParams = <String, dynamic>{};
      queryParams['display'] = display ?? 'full';

      if (filters != null) queryParams.addAll(filters);
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      if (language != null) queryParams['language'] = language;
      if (idShop != null) queryParams['id_shop'] = idShop.toString();

      final response = await get<Map<String, dynamic>>(
        'groups',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['groups'] is List) {
          final groupsList = data['groups'] as List;
          return groupsList
              .map(
                (json) =>
                    Group.fromPrestaShopJson(json as Map<String, dynamic>),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      _logger.error('Error fetching all groups: $e');
      rethrow;
    }
  }

  /// Récupère un groupe par ID
  Future<Group?> getGroupById(
    int groupId, {
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching group by ID: $groupId');

    try {
      final queryParams = <String, dynamic>{'display': 'full'};

      if (language != null) queryParams['language'] = language;
      if (idShop != null) queryParams['id_shop'] = idShop.toString();

      final response = await get<Map<String, dynamic>>(
        'groups/$groupId',
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['group'] is Map<String, dynamic>) {
          return Group.fromPrestaShopJson(
            data['group'] as Map<String, dynamic>,
          );
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error fetching group by ID $groupId: $e');
      rethrow;
    }
  }

  /// Crée un nouveau groupe
  Future<Group?> createGroup(Group group) async {
    _logger.info('Creating group: ${group.defaultName}');

    try {
      final response = await post<Map<String, dynamic>>(
        'groups',
        data: {'group': group.toPrestaShopJson()},
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        if (data['group'] is Map<String, dynamic>) {
          final groupData = data['group'] as Map<String, dynamic>;
          final groupId = int.tryParse(groupData['id']?.toString() ?? '0');

          if (groupId != null && groupId > 0) {
            return await getGroupById(groupId);
          }
        }
      }

      return null;
    } catch (e) {
      _logger.error('Error creating group: $e');
      rethrow;
    }
  }

  /// Met à jour un groupe
  Future<Group?> updateGroup(Group group) async {
    if (group.id == null) {
      throw ArgumentError('Group ID is required for update');
    }

    _logger.info('Updating group: ${group.id}');

    try {
      final response = await put<Map<String, dynamic>>(
        'groups/${group.id}',
        data: {'group': group.toPrestaShopJson()},
      );

      if (response.success) {
        return await getGroupById(group.id!);
      }

      return null;
    } catch (e) {
      _logger.error('Error updating group ${group.id}: $e');
      rethrow;
    }
  }

  /// Supprime un groupe
  Future<bool> deleteGroup(int groupId) async {
    _logger.info('Deleting group: $groupId');

    try {
      final response = await delete('groups/$groupId');
      return response.success;
    } catch (e) {
      _logger.error('Error deleting group $groupId: $e');
      rethrow;
    }
  }

  /// Récupère les groupes avec réduction
  Future<List<Group>> getGroupsWithReduction({
    String? language,
    int? idShop,
  }) async {
    _logger.info('Fetching groups with reduction');

    final allGroups = await getAllGroups(language: language, idShop: idShop);

    return allGroups.where((group) => group.hasReduction).toList();
  }
}
