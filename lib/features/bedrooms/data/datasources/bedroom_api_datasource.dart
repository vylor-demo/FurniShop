import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/errors/exceptions.dart';
import '../models/bedroom_model.dart';
import 'bedroom_datasource.dart';

class BedroomApiDataSource implements BedroomDataSource {
  final http.Client client;
  final String baseUrl;

  const BedroomApiDataSource({
    required this.client,
    this.baseUrl = 'http://localhost:8000/api/v1',
  });

  @override
  Future<List<BedroomModel>> getBedrooms() async {
    final uri = Uri.parse('$baseUrl/bedrooms');
    return _getBedroomList(uri);
  }

  @override
  Future<BedroomModel> getBedroomById(String id) async {
    final uri = Uri.parse('$baseUrl/bedrooms/$id');

    try {
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        return BedroomModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }

      if (response.statusCode == 404) {
        throw const NotFoundException(message: 'Bedroom not found');
      }

      throw ServerException(
        message: 'Failed to fetch bedroom',
        code: response.statusCode.toString(),
      );
    } on SocketException {
      throw const NetworkException(message: 'No internet connection');
    } on FormatException {
      throw const ServerException(message: 'Invalid response format');
    }
  }

  @override
  Future<List<BedroomModel>> getBedroomsByCategory(String category) async {
    final uri = Uri.parse('$baseUrl/bedrooms/category/$category');
    return _getBedroomList(uri);
  }

  @override
  Future<List<BedroomModel>> getFeaturedBedrooms() async {
    final uri = Uri.parse('$baseUrl/bedrooms/featured');
    return _getBedroomList(uri);
  }

  @override
  Future<List<BedroomModel>> searchBedrooms(String query) async {
    final uri = Uri.parse('$baseUrl/bedrooms/search').replace(
      queryParameters: {'q': query},
    );
    return _getBedroomList(uri);
  }

  Future<List<BedroomModel>> _getBedroomList(Uri uri) async {
    try {
      final response = await client.get(uri);

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to fetch bedrooms',
          code: response.statusCode.toString(),
        );
      }

      final decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded
          .map((json) => BedroomModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw const NetworkException(message: 'No internet connection');
    } on FormatException {
      throw const ServerException(message: 'Invalid response format');
    }
  }
}
