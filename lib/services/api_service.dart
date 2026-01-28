import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiResponse {
  final int statusCode;
  final Uint8List? imageData;
  final String? errorMessage;

  ApiResponse({required this.statusCode, this.imageData, this.errorMessage});
}

class ApiService {
  static const String _baseUrl = 'https://antherless-lu-continuately.ngrok-free.dev/latest';

  // Renamed to fetchLatestImage to maintain consistency
  Future<ApiResponse> fetchLatestImage() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'Accept': 'image/jpeg, image/png, application/json',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null && contentType.startsWith('image/')) {
          return ApiResponse(statusCode: 200, imageData: response.bodyBytes);
        }
      }
      
      return ApiResponse(
        statusCode: response.statusCode,
        errorMessage: 'Server returned ${response.statusCode}',
      );
    } catch (e) {
      return ApiResponse(statusCode: 0, errorMessage: e.toString());
    }
  }
}