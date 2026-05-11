import 'dart:convert';
import 'api_client.dart';

class PetService {
  final ApiClient apiClient;

  PetService(this.apiClient);

  Future<Map<String, dynamic>> getPetStatus() async {
    try {
      final response = await apiClient.get(
        '/pet/status',
        needsAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {'success': true, 'data': data};
      } else if (response.statusCode == 401) {
        return {'success': false, 'error': 'No autenticado'};
      } else {
        return {'success': false, 'error': 'Error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> feedPet() async {
    try {
      final response = await apiClient.post(
        '/pet/feed',
        body: {},
        needsAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {'success': true, 'data': data};
      } else if (response.statusCode == 401) {
        return {'success': false, 'error': 'No autenticado'};
      } else {
        return {'success': false, 'error': 'Error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error: $e'};
    }
  }
}
