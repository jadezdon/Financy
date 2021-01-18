import 'package:Financy/config/route.dart';
import 'package:Financy/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/categories/categories_bloc.dart';
import '../data/models/category_model.dart';
import 'error.dart';

class CategoryList extends StatelessWidget {
  final TransactionType type;
  final CategoryModel selectedCategory;
  final Function(CategoryModel) onCategoryPressed;

  CategoryList({
    Key key,
    @required this.type,
    @required this.onCategoryPressed,
    this.selectedCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is CategoriesLoaded) {
          return _buildCategoriesGrid(
            context,
            state.categories.where((element) => element.transactionType == type).toList(),
          );
        } else if (state is CategoriesNotLoaded) {
          return ErrorContainer(msg: "Categories not loaded");
        }

        return ErrorContainer(msg: "No CategoriesState");
      },
    );
  }

  Widget _buildCategoriesGrid(BuildContext context, List<CategoryModel> categories) {
    return GridView.count(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      crossAxisCount: (MediaQuery.of(context).size.width / 80).round(),
      children: List.generate(categories.length + 1, (index) {
        if (index == categories.length) {
          return FlatButton(
            child: Center(
              child: Icon(Icons.add_box_outlined, color: Colors.grey),
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRoute.addCategoryPage);
            },
          );
        }

        Color color = categories[index] == selectedCategory ? Theme.of(context).accentColor : Colors.grey;
        return FlatButton(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                alignment: Alignment.center,
                child: Icon(
                  IconData(
                    categories[index].iconCodePoint,
                    fontFamily: categories[index].iconFamily,
                  ),
                  color: color,
                ),
              ),
              SizedBox(height: 5.0),
              Text(
                categories[index].name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontSize: AppSize.fontNormal),
              ),
            ],
          ),
          onPressed: () {
            onCategoryPressed(categories[index]);
          },
        );
      }),
    );
  }
}
