import 'package:equatable/equatable.dart';

import '../../domain/entities/bedroom_entity.dart';

abstract class BedroomsState extends Equatable {
  const BedroomsState();

  @override
  List<Object?> get props => [];
}

class BedroomsInitial extends BedroomsState {
  const BedroomsInitial();
}

class BedroomsLoading extends BedroomsState {
  const BedroomsLoading();
}

class BedroomsLoaded extends BedroomsState {
  final List<Bedroom> bedrooms;
  final String? selectedCategory;

  const BedroomsLoaded({
    required this.bedrooms,
    this.selectedCategory,
  });

  List<Bedroom> get filteredBedrooms {
    if (selectedCategory == null) {
      return bedrooms;
    }

    return bedrooms
        .where((item) => item.category == selectedCategory)
        .toList();
  }

  List<String> get categories {
    final unique = bedrooms.map((item) => item.category).toSet().toList();
    unique.sort();
    return unique;
  }

  BedroomsLoaded copyWith({
    List<Bedroom>? bedrooms,
    String? selectedCategory,
  }) {
    return BedroomsLoaded(
      bedrooms: bedrooms ?? this.bedrooms,
      selectedCategory: selectedCategory,
    );
  }

  @override
  List<Object?> get props => [bedrooms, selectedCategory];
}

class BedroomsError extends BedroomsState {
  final String message;

  const BedroomsError(this.message);

  @override
  List<Object?> get props => [message];
}
