class NetworkResponse {
  final bool success;
  final dynamic data;
  final String? error;

  NetworkResponse._({required this.success, this.data, this.error});

  factory NetworkResponse.success(dynamic data) {
    return NetworkResponse._(success: true, data: data);
  }

  factory NetworkResponse.error(String error) {
    return NetworkResponse._(success: false, error: error);
  }
}
