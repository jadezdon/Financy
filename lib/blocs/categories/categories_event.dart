part of 'categories_bloc.dart';

abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object> get props => [];
}

class GetCategoriesEvent extends CategoriesEvent {
  const GetCategoriesEvent();
  @override
  List<Object> get props => [];
}

class AddCategoryEvent extends CategoriesEvent {
  final CategoryModel category;
  const AddCategoryEvent(this.category);

  @override
  List<Object> get props => [category];
}

class UpdateCategoryEvent extends CategoriesEvent {
  final CategoryModel category;
  const UpdateCategoryEvent(this.category);

  @override
  List<Object> get props => [category];
}

class DeleteCategoryEvent extends CategoriesEvent {
  final CategoryModel category;
  const DeleteCategoryEvent(this.category);

  @override
  List<Object> get props => [category];
}
