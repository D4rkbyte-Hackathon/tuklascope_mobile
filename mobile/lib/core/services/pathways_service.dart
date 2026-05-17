// mobile/lib/core/services/pathways_service.dart
import 'dart:convert';
import '../network/api_client.dart';
import '../config/api_config.dart';
import '../../features/pathways/models/pathway_models.dart';

class PathwaysService {
  Future<PathwayCatalogResponse> getCatalog() async {
    final response = await ApiClient.get(ApiConfig.pathwaysCatalog);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return PathwayCatalogResponse.fromJson(decoded);
    } else {
      throw Exception('Failed to fetch catalog: ${response.body}');
    }
  }

  Future<void> enrollInPathway(String pathwayId) async {
    final response = await ApiClient.post(ApiConfig.enrollPathway(pathwayId));

    if (response.statusCode != 200 && response.statusCode != 201) {
      // Extract detail from FastAPI HTTP Exception if possible
      String errorDetail = 'Failed to enroll';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded['detail'] != null) {
          errorDetail = decoded['detail'];
        }
      } catch (_) {}

      throw Exception(errorDetail);
    }
  }

  Future<void> claimPathwayBadge(String pathwayId) async {
    final response = await ApiClient.post(ApiConfig.claimPathwayBadge(pathwayId));

    if (response.statusCode != 200 && response.statusCode != 201) {
      String errorDetail = 'Failed to claim badge';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded['detail'] != null) {
          errorDetail = decoded['detail'].toString();
        }
      } catch (_) {}

      throw Exception(errorDetail);
    }
  }
}
