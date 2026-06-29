import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/errors/exceptions.dart';
import '../models/desk_model.dart';
import 'desk_datasource.dart';

class DeskApiDataSource implements DeskDataSource {
  final http.Client client;
  final String baseUrl;

  const DeskApiDataSource({
    required this.client,
    this.baseUrl = 'http://localhost:8000/api/v1',
  });

  @override
  Future<List<DeskModel>> getDesks() async {
    final uri = Uri.parse('$baseUrl/desks');
    return _getDeskList(uri);
  }

  @override
  Future<DeskModel> getDeskById(String id) async {
    final uri = Uri.parse('$baseUrl/desks/$id');

    try {
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        return DeskModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }

      if (response.statusCode == 404) {
        throw const NotFoundException(message: 'Desk not found');
      }

      throw ServerException(
        message: 'Failed to fetch desk',
        code: response.statusCode.toString(),
      );
    } on SocketException {
      throw const NetworkException(message: 'No internet connection');
    } on FormatException {
      throw const ServerException(message: 'Invalid response format');
    }
  }

  @override
  Future<List<DeskModel>> getDesksByCategory(String category) async {
    final uri = Uri.parse('$baseUrl/desks/category/$category');
    return _getDeskList(uri);
  }

  @override
  Future<List<DeskModel>> getFeaturedDesks() async {
    final uri = Uri.parse('$baseUrl/desks/featured');
    return _getDeskList(uri);
  }

  @override
  Future<List<DeskModel>> searchDesks(String query) async {
    final uri = Uri.parse('$baseUrl/desks/search').replace(
      queryParameters: {'q': query},
    );
    return _getDeskList(uri);
  }

  Future<List<DeskModel>> _getDeskList(Uri uri) async {
    try {
      final response = await client.get(uri);

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to fetch desks',
          code: response.statusCode.toString(),
        );
      }

      final decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded
          .map((json) => DeskModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw const NetworkException(message: 'No internet connection');
    } on FormatException {
      throw const ServerException(message: 'Invalid response format');
    }
  }
}
