import 'api_client.dart';
import 'auth_service.dart';
import 'pet_service.dart';

final ApiClient apiClient = ApiClient();
final AuthService authService = AuthService(apiClient);
final PetService petService = PetService(apiClient);