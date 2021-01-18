import 'package:Financy/blocs/categories/categories_bloc.dart';
import 'package:Financy/blocs/transaction/transactions_bloc.dart';
import 'package:Financy/config/theme.dart';
import 'package:Financy/data/models/category_model.dart';
import 'package:Financy/utils/data.dart';
import 'package:Financy/utils/date_util.dart';
import 'package:Financy/widgets/icon_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/category_model.dart';

class AddCategoryPage extends StatefulWidget {
  final CategoryModel categoryToEdit;
  AddCategoryPage({Key key, this.categoryToEdit}) : super(key: key);

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  CategoryModel category = CategoryModel();

  final TextEditingController nameTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    category.iconCodePoint = AppData.iconList.first.icon.codePoint;
    category.iconFamily = AppData.iconList.first.icon.fontFamily;
    category.transactionType = TransactionType.EXPENSE;

    if (widget.categoryToEdit != null) {
      category = widget.categoryToEdit.clone();
      nameTextController.text = category.name;
    }
  }

  @override
  void dispose() {
    nameTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text(tr("category")),
        leadingWidth: 0,
        leading: SizedBox.shrink(),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSize.pageMarginHori),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.clear),
            ),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: AppSize.pageMarginHori),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: Icon(
                              IconData(
                                category.iconCodePoint,
                                fontFamily: category.iconFamily,
                              ),
                            ),
                          ),
                          Flexible(
                            child: TextFormField(
                              controller: nameTextController,
                              decoration: InputDecoration(
                                labelText: tr("name"),
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value.length <= 0) {
                                  return tr("name must not be empty");
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        SizedBox(width: 60),
                        Expanded(
                          child: DropdownButton(
                            isExpanded: true,
                            value: category.transactionType,
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
                                category.transactionType = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    IconPicker(
                      selectedIcon: Icon(
                        IconData(
                          category.iconCodePoint,
                          fontFamily: category.iconFamily,
                        ),
                      ),
                      onIconSelected: (icon) {
                        setState(() {
                          category.iconCodePoint = icon.icon.codePoint;
                          category.iconFamily = icon.icon.fontFamily;
                        });
                      },
                    ),
                    SizedBox(height: 30),
                    InkWell(
                      onTap: () {
                        if (_formKey.currentState.validate()) {
                          category.name = nameTextController.text;

                          if (widget.categoryToEdit != null) {
                            BlocProvider.of<CategoriesBloc>(context)
                                .add(UpdateCategoryEvent(category));
                            BlocProvider.of<TransactionsBloc>(context).add(
                                GetTransactionsEvent(
                                    DateUtil.getCurrentMonth(DateTime.now())));
                          } else {
                            BlocProvider.of<CategoriesBloc>(context)
                                .add(AddCategoryEvent(category));
                          }

                          BlocProvider.of<CategoriesBloc>(context)
                              .add(GetCategoriesEvent());
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(AppSize.borderRadius)),
                          color: Theme.of(context).accentColor,
                        ),
                        child: Center(
                          child: Text(
                            tr("save"),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSize.pageMarginVert),
            ],
          ),
        ),
      ),
    );
  }
}
