// Defines the base response model for API responses in the Koutonou application.
// This model provides a standardized structure for handling API responses,
// including success/error states, data payload, pagination, and metadata.

import 'package:koutonou/core/models/error_model.dart';

// Base response model for all API responses
class BaseResponse<T> {
  /// Indicates if the request was successful
  final bool success;

  /// HTTP status code
  final int statusCode;

  /// Response message
  final String message;

  /// The actual data payload (can be any type T)
  final T? data;

  /// List of errors if the request failed
  final List<ErrorModel>? errors;

  /// Pagination information for list responses
  final PaginationMeta? pagination;

  /// Additional metadata
  final Map<String, dynamic>? meta;

  /// Timestamp of the response
  final DateTime timestamp;

  BaseResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
    this.errors,
    this.pagination,
    this.meta,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Factory constructor for successful responses
  factory BaseResponse.success({
    required T data,
    String? message,
    int statusCode = 200,
    PaginationMeta? pagination,
    Map<String, dynamic>? meta,
  }) {
    return BaseResponse<T>(
      success: true,
      statusCode: statusCode,
      message: message ?? 'Success',
      data: data,
      pagination: pagination,
      meta: meta,
    );
  }

  /// Factory constructor for error responses
  factory BaseResponse.error({
    required String message,
    required int statusCode,
    List<ErrorModel>? errors,
    T? data,
    Map<String, dynamic>? meta,
  }) {
    return BaseResponse<T>(
      success: false,
      statusCode: statusCode,
      message: message,
      data: data,
      errors: errors,
      meta: meta,
    );
  }

  /// Factory constructor from JSON
  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return BaseResponse<T>(
      success: json['success'] as bool? ?? (json['status'] == 'success'),
      statusCode:
          json['status_code'] as int? ?? json['statusCode'] as int? ?? 200,
      message: json['message'] as String? ?? json['msg'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      errors: json['errors'] != null
          ? (json['errors'] as List<dynamic>)
                .map((e) => ErrorModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      pagination: json['pagination'] != null
          ? PaginationMeta.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
      meta: json['meta'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson([dynamic Function(T)? toJsonT]) {
    return {
      'success': success,
      'status_code': statusCode,
      'message': message,
      'data': data != null && toJsonT != null ? toJsonT(data as T) : data,
      'errors': errors?.map((e) => e.toJson()).toList(),
      'pagination': pagination?.toJson(),
      'meta': meta,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Check if response has data
  bool get hasData => data != null;

  /// Check if response has errors
  bool get hasErrors => errors != null && errors!.isNotEmpty;

  /// Get first error message
  String? get firstErrorMessage => hasErrors ? errors!.first.message : null;

  /// Get all error messages as a single string
  String get allErrorMessages {
    if (!hasErrors) return message;
    return errors!.map((e) => e.message).join(', ');
  }

  /// Check if response indicates success and has data
  bool get isSuccessWithData => success && hasData;

  /// Check if response is a validation error (422)
  bool get isValidationError => statusCode == 422;

  /// Check if response is unauthorized (401)
  bool get isUnauthorized => statusCode == 401;

  /// Check if response is forbidden (403)
  bool get isForbidden => statusCode == 403;

  /// Check if response is not found (404)
  bool get isNotFound => statusCode == 404;

  /// Check if response is a server error (5xx)
  bool get isServerError => statusCode >= 500 && statusCode < 600;

  /// Check if response is a client error (4xx)
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  /// Create a copy with different values
  BaseResponse<T> copyWith({
    bool? success,
    int? statusCode,
    String? message,
    T? data,
    List<ErrorModel>? errors,
    PaginationMeta? pagination,
    Map<String, dynamic>? meta,
    DateTime? timestamp,
  }) {
    return BaseResponse<T>(
      success: success ?? this.success,
      statusCode: statusCode ?? this.statusCode,
      message: message ?? this.message,
      data: data ?? this.data,
      errors: errors ?? this.errors,
      pagination: pagination ?? this.pagination,
      meta: meta ?? this.meta,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'BaseResponse(success: $success, statusCode: $statusCode, message: $message, hasData: $hasData, hasErrors: $hasErrors)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseResponse &&
          runtimeType == other.runtimeType &&
          success == other.success &&
          statusCode == other.statusCode &&
          message == other.message &&
          data == other.data;

  @override
  int get hashCode =>
      success.hashCode ^ statusCode.hashCode ^ message.hashCode ^ data.hashCode;
}

// Pagination metadata for list responses
class PaginationMeta {
  /// Current page number (1-based)
  final int currentPage;

  /// Total number of pages
  final int totalPages;

  /// Number of items per page
  final int itemsPerPage;

  /// Total number of items
  final int totalItems;

  /// Number of items in current page
  final int itemsInCurrentPage;

  /// Whether there is a next page
  final bool hasNextPage;

  /// Whether there is a previous page
  final bool hasPreviousPage;

  /// Starting item number in current page
  final int startItem;

  /// Ending item number in current page
  final int endItem;

  PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.itemsPerPage,
    required this.totalItems,
    required this.itemsInCurrentPage,
  }) : hasNextPage = currentPage < totalPages,
       hasPreviousPage = currentPage > 1,
       startItem = ((currentPage - 1) * itemsPerPage) + 1,
       endItem = ((currentPage - 1) * itemsPerPage) + itemsInCurrentPage;

  /// Factory constructor from JSON
  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int? ?? json['page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? json['last_page'] as int? ?? 1,
      itemsPerPage: json['per_page'] as int? ?? json['limit'] as int? ?? 10,
      totalItems: json['total'] as int? ?? json['total_items'] as int? ?? 0,
      itemsInCurrentPage:
          json['count'] as int? ?? json['items_in_page'] as int? ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'per_page': itemsPerPage,
      'total': totalItems,
      'count': itemsInCurrentPage,
      'has_next_page': hasNextPage,
      'has_previous_page': hasPreviousPage,
      'start_item': startItem,
      'end_item': endItem,
    };
  }

  /// Create a copy with different values
  PaginationMeta copyWith({
    int? currentPage,
    int? totalPages,
    int? itemsPerPage,
    int? totalItems,
    int? itemsInCurrentPage,
  }) {
    return PaginationMeta(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalItems: totalItems ?? this.totalItems,
      itemsInCurrentPage: itemsInCurrentPage ?? this.itemsInCurrentPage,
    );
  }

  @override
  String toString() {
    return 'PaginationMeta(page: $currentPage/$totalPages, items: $itemsInCurrentPage/$totalItems)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginationMeta &&
          runtimeType == other.runtimeType &&
          currentPage == other.currentPage &&
          totalPages == other.totalPages &&
          itemsPerPage == other.itemsPerPage &&
          totalItems == other.totalItems &&
          itemsInCurrentPage == other.itemsInCurrentPage;

  @override
  int get hashCode =>
      currentPage.hashCode ^
      totalPages.hashCode ^
      itemsPerPage.hashCode ^
      totalItems.hashCode ^
      itemsInCurrentPage.hashCode;
}
