/// Modèle de réponse base pour l'API PrestaShop
class BaseResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const BaseResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
    this.errors,
  });

  factory BaseResponse.success({
    T? data,
    String? message,
    int statusCode = 200,
  }) {
    return BaseResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory BaseResponse.error({
    String? message,
    int statusCode = 400,
    Map<String, dynamic>? errors,
  }) {
    return BaseResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return BaseResponse<T>(
      success: json['success'] ?? true,
      message: json['message']?.toString(),
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      statusCode: json['statusCode'],
      errors: json['errors'] is Map<String, dynamic> ? json['errors'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (message != null) 'message': message,
      if (data != null) 'data': data,
      if (statusCode != null) 'statusCode': statusCode,
      if (errors != null) 'errors': errors,
    };
  }
}
