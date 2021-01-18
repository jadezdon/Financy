part of 'categories_bloc.dart';

abstract class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object> get props => [];
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
  @override
  List<Object> get props => [];
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
  @override
  List<Object> get props => [];
}

class CategoriesLoaded extends CategoriesState {
  final List<CategoryModel> categories;
  const CategoriesLoaded(this.categories);
  @override
  List<Object> get props => [categories];
}

class CategoriesNotLoaded extends CategoriesState {
  const CategoriesNotLoaded();
  @override
  List<Object> get props => [];
}
