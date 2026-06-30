import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/bedroom_entity.dart';
import '../repositories/bedroom_repository.dart';

class GetBedroomsUseCase {
  final BedroomRepository repository;

  const GetBedroomsUseCase(this.repository);

  Future<Either<Failure, List<Bedroom>>> call() async {
    return repository.getBedrooms();
  }
}

class GetBedroomByIdUseCase {
  final BedroomRepository repository;

  const GetBedroomByIdUseCase(this.repository);

  Future<Either<Failure, Bedroom>> call(String id) async {
    return repository.getBedroomById(id);
  }
}

class GetBedroomsByCategoryUseCase {
  final BedroomRepository repository;

  const GetBedroomsByCategoryUseCase(this.repository);

  Future<Either<Failure, List<Bedroom>>> call(String category) async {
    return repository.getBedroomsByCategory(category);
  }
}

class GetFeaturedBedroomsUseCase {
  final BedroomRepository repository;

  const GetFeaturedBedroomsUseCase(this.repository);

  Future<Either<Failure, List<Bedroom>>> call() async {
    return repository.getFeaturedBedrooms();
  }
}

class SearchBedroomsUseCase {
  final BedroomRepository repository;

  const SearchBedroomsUseCase(this.repository);

  Future<Either<Failure, List<Bedroom>>> call(String query) async {
    return repository.searchBedrooms(query);
  }
}
