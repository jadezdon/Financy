import 'package:Financy/blocs/categories/categories_bloc.dart';
import 'package:Financy/blocs/transaction/transactions_bloc.dart';
import 'package:Financy/config/route.dart';
import 'package:Financy/config/theme.dart';
import 'package:Financy/data/models/category_model.dart';
import 'package:Financy/utils/date_util.dart';
import 'package:Financy/widgets/error.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManageCategoriesPage extends StatefulWidget {
  @override
  _ManageCategoriesPageState createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  List<CategoryModel> categories;
  TransactionType selectedType = TransactionType.INCOME;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is CategoriesLoaded) {
          categories = state.categories.where((element) => element.transactionType == selectedType).toList();
          return _buildPage(context);
        } else if (state is CategoriesNotLoaded) {
          return ErrorContainer(msg: "Transactions not loaded");
        } else if (state is CategoriesInitial) {
          return SizedBox.shrink();
        }
        return ErrorContainer(msg: "Transactions no state");
      },
    );
  }

  Widget _buildPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.chevron_left),
        ),
        title: Text(
          tr("manage categories"),
          style: TextStyle(fontSize: AppSize.fontLarge),
        ),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSize.pageMarginHori),
            child: DropdownButton(
              value: selectedType,
              items: [
                DropdownMenuItem(
                  child: Text(tr("expense")),
                  value: TransactionType.EXPENSE,
                ),
                DropdownMenuItem(
                  child: Text(tr("income")),
                  value: TransactionType.INCOME,
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          ...categories.map((e) => _buildCategoryItem(context, e)),
          Container(
            margin: EdgeInsets.symmetric(horizontal: AppSize.pageMarginHori, vertical: 5),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, AppRoute.addCategoryPage);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSize.borderRadius),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_box_outlined, color: Colors.grey),
                    SizedBox(width: 10),
                    Text(
                      tr("add category"),
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryModel category) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSize.borderRadius),
      ),
      margin: EdgeInsets.symmetric(horizontal: AppSize.pageMarginHori, vertical: 5),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          children: [
            Icon(
              IconData(category.iconCodePoint, fontFamily: category.iconFamily),
            ),
            SizedBox(width: 10),
            Text(category.name),
            Spacer(),
            InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoute.addCategoryPage,
                  arguments: category,
                );
              },
              child: Icon(Icons.edit_outlined),
            ),
            SizedBox(width: 10),
            InkWell(
              onTap: () {
                showConfirmDialog(context, category);
              },
              child: Icon(
                Icons.delete_outline_outlined,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showConfirmDialog(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(tr("delete category")),
          content: Text(tr(
              "Are you sure that you want to delete this category? All transaction will be deleted in this category.")),
          actions: [
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(tr("cancel")),
            ),
            FlatButton(
              onPressed: () {
                BlocProvider.of<CategoriesBloc>(context).add(DeleteCategoryEvent(category));
                Navigator.pop(context);
              },
              child: Text(
                tr("delete"),
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
