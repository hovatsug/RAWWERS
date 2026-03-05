class ApiError implements Exception {
  ApiError({required this.code, required this.message, this.requestId});

  final String code;
  final String message;
  final String? requestId;

  @override
  String toString() {
    if (requestId == null || requestId!.isEmpty) {
      return message;
    }
    return '$message (request_id: $requestId)';
  }
}
