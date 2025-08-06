import '../models/base_response.dart';

export '../models/base_response.dart';

/// Alias pour BaseResponse pour maintenir la compatibilité
class ApiResponse<T> {
  static BaseResponse<T> success<T>(T? data, {String? message}) {
    return BaseResponse.success(data: data, message: message);
  }

  static BaseResponse<T> error<T>(String? message, {int statusCode = 400}) {
    return BaseResponse.error(message: message, statusCode: statusCode);
  }
}
