import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/errors/exceptions.dart';
import '../models/living_room_model.dart';
import 'living_room_datasource.dart';

class LivingRoomApiDataSource implements LivingRoomDataSource {
  final http.Client client;
  final String baseUrl;

  const LivingRoomApiDataSource({
    required this.client,
    this.baseUrl = 'http://localhost:8000/api/v1',
  });

  @override
  Future<List<LivingRoomModel>> getLivingRooms() async {
    final uri = Uri.parse('$baseUrl/living-rooms');
    return _getRoomList(uri);
  }

  @override
  Future<LivingRoomModel> getLivingRoomById(String id) async {
    final uri = Uri.parse('$baseUrl/living-rooms/$id');

    try {
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        return LivingRoomModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }

      if (response.statusCode == 404) {
        throw const NotFoundException(message: 'Living room not found');
      }

      throw ServerException(
        message: 'Failed to fetch living room',
        code: response.statusCode.toString(),
      );
    } on SocketException {
      throw const NetworkException(message: 'No internet connection');
    } on FormatException {
      throw const ServerException(message: 'Invalid response format');
    }
  }

  @override
  Future<List<LivingRoomModel>> getLivingRoomsByCategory(String category) async {
    final uri = Uri.parse('$baseUrl/living-rooms/category/$category');
    return _getRoomList(uri);
  }

  @override
  Future<List<LivingRoomModel>> getFeaturedLivingRooms() async {
    final uri = Uri.parse('$baseUrl/living-rooms/featured');
    return _getRoomList(uri);
  }

  @override
  Future<List<LivingRoomModel>> searchLivingRooms(String query) async {
    final uri = Uri.parse('$baseUrl/living-rooms/search').replace(
      queryParameters: {'q': query},
    );
    return _getRoomList(uri);
  }

  Future<List<LivingRoomModel>> _getRoomList(Uri uri) async {
    try {
      final response = await client.get(uri);

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to fetch living rooms',
          code: response.statusCode.toString(),
        );
      }

      final decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded
          .map((json) => LivingRoomModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw const NetworkException(message: 'No internet connection');
    } on FormatException {
      throw const ServerException(message: 'Invalid response format');
    }
  }
}
