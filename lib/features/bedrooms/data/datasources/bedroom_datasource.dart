import '../models/bedroom_model.dart';

abstract class BedroomDataSource {
  Future<List<BedroomModel>> getBedrooms();

  Future<BedroomModel> getBedroomById(String id);

  Future<List<BedroomModel>> getBedroomsByCategory(String category);

  Future<List<BedroomModel>> getFeaturedBedrooms();

  Future<List<BedroomModel>> searchBedrooms(String query);
}
