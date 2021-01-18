import 'package:Financy/config/locales.dart';
import 'package:Financy/config/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ChooseLanguagePage extends StatelessWidget {
  ChooseLanguagePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Locale> supportedLocales = context.supportedLocales;
    Locale currentLocale = context.locale;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("choose-language")),
      ),
      body: ListView.builder(
        itemCount: supportedLocales.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              context.locale = supportedLocales[index];
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSize.pageMarginHori,
                vertical: 15,
              ),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appLocales[supportedLocales[index]],
                    style: TextStyle(
                      color: supportedLocales[index] == currentLocale
                          ? Theme.of(context).accentColor
                          : Colors.black,
                    ),
                  ),
                  if (supportedLocales[index] == currentLocale)
                    Icon(
                      Icons.check,
                      color: Theme.of(context).accentColor,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
