import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/ledger/ledger_bloc.dart';
import '../config/theme.dart';
import '../data/models/ledger_model.dart';
import '../utils/number_util.dart';

class AddLedgerPage extends StatefulWidget {
  final LedgerModel ledger;
  const AddLedgerPage({Key key, this.ledger}) : super(key: key);

  @override
  _AddLedgerPageState createState() => _AddLedgerPageState();
}

class _AddLedgerPageState extends State<AddLedgerPage> {
  final TextEditingController nameTextController = TextEditingController();
  final TextEditingController budgetTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  LedgerModel ledger = LedgerModel();

  @override
  void initState() {
    super.initState();
    if (widget.ledger != null) {
      ledger = widget.ledger.clone();
      nameTextController.text = widget.ledger.name;
      budgetTextController.text =
          NumberUtil.doubleToString(widget.ledger.budget);
    }
  }

  @override
  void dispose() {
    nameTextController.dispose();
    budgetTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text(tr("ledger")),
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
        padding: EdgeInsets.only(
          top: AppSize.pageMarginVert,
          left: AppSize.pageMarginHori,
          right: AppSize.pageMarginHori,
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
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
                    TextFormField(
                      controller: budgetTextController,
                      decoration: InputDecoration(
                        labelText: tr("budget"),
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (double.tryParse(value) < 0) {
                          return tr("value must not be negative");
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    InkWell(
                      onTap: () {
                        if (_formKey.currentState.validate()) {
                          ledger.name = nameTextController.text;
                          ledger.budget =
                              double.parse(budgetTextController.text);
                          if (widget.ledger != null) {
                            BlocProvider.of<LedgerBloc>(context)
                                .add(UpdateLedgerEvent(ledger));
                          } else {
                            BlocProvider.of<LedgerBloc>(context)
                                .add(AddLedgerEvent(ledger));
                          }
                          BlocProvider.of<LedgerBloc>(context)
                              .add(GetLedgerEvent(ledger.id));
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
            ),
          ],
        ),
      ),
    );
  }
}
