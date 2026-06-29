import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/bedroom_entity.dart';
import '../../domain/repositories/bedroom_repository.dart';
import '../datasources/bedroom_datasource.dart';

class BedroomRepositoryImpl implements BedroomRepository {
  final BedroomDataSource dataSource;

  const BedroomRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<Bedroom>>> getBedrooms() async {
    try {
      final items = await dataSource.getBedrooms();
      return Right(items);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Bedroom>> getBedroomById(String id) async {
    try {
      final item = await dataSource.getBedroomById(id);
      return Right(item);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Bedroom>>> getBedroomsByCategory(String category) async {
    try {
      final items = await dataSource.getBedroomsByCategory(category);
      return Right(items);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Bedroom>>> getFeaturedBedrooms() async {
    try {
      final items = await dataSource.getFeaturedBedrooms();
      return Right(items);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Bedroom>>> searchBedrooms(String query) async {
    try {
      final items = await dataSource.searchBedrooms(query);
      return Right(items);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
