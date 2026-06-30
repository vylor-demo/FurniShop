import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/errors/exceptions.dart';
import '../models/chair_model.dart';
import 'chair_datasource.dart';

class ChairApiDataSource implements ChairDataSource {
  final http.Client client;
  final String baseUrl;

  const ChairApiDataSource({
    required this.client,
    this.baseUrl = 'http://localhost:8000/api/v1',
  });

  @override
  Future<List<ChairModel>> getChairs() async {
    final uri = Uri.parse('$baseUrl/chairs');
    return _getChairList(uri);
  }

  @override
  Future<ChairModel> getChairById(String id) async {
    final uri = Uri.parse('$baseUrl/chairs/$id');

    try {
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        return ChairModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }

      if (response.statusCode == 404) {
        throw const NotFoundException(message: 'Chair not found');
      }

      throw ServerException(
        message: 'Failed to fetch chair',
        code: response.statusCode,
      );
    } on SocketException {
      throw const NetworkException(message: 'No internet connection');
    } on FormatException {
      throw const ServerException(message: 'Invalid response format');
    }
  }

  @override
  Future<List<ChairModel>> getChairsByCategory(String category) async {
    final uri = Uri.parse('$baseUrl/chairs/category/$category');
    return _getChairList(uri);
  }

  @override
  Future<List<ChairModel>> getFeaturedChairs() async {
    final uri = Uri.parse('$baseUrl/chairs/featured');
    return _getChairList(uri);
  }

  @override
  Future<List<ChairModel>> searchChairs(String query) async {
    final uri = Uri.parse('$baseUrl/chairs/search').replace(
      queryParameters: {'q': query},
    );
    return _getChairList(uri);
  }

  Future<List<ChairModel>> _getChairList(Uri uri) async {
    try {
      final response = await client.get(uri);

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to fetch chairs',
          code: response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded
          .map((json) => ChairModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw const NetworkException(message: 'No internet connection');
    } on FormatException {
      throw const ServerException(message: 'Invalid response format');
    }
  }
}
