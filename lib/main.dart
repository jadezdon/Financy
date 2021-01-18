import 'package:Financy/utils/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'blocs/accounts/accounts_bloc.dart';
import 'blocs/categories/categories_bloc.dart';
import 'blocs/ledger/ledger_bloc.dart';
import 'blocs/transaction/transactions_bloc.dart';
import 'config/locales.dart';
import 'config/route.dart';
import 'config/theme.dart';
import 'data/repositories/account_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/ledger_repository.dart';
import 'data/repositories/location_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'utils/date_util.dart';

main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((prefs) {
    if (!prefs.containsKey(Constant.shp_showDaySum)) {
      prefs.setBool(Constant.shp_showDaySum, false);
    }
    if (!prefs.containsKey(Constant.shp_showDollarSign)) {
      prefs.setBool(Constant.shp_showDollarSign, true);
    }
    runApp(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            create: (context) => LedgerRepository(),
          ),
          RepositoryProvider(
            create: (context) => AccountRepository(),
          ),
          RepositoryProvider(
            create: (context) => CategoryRepository(),
          ),
          RepositoryProvider(
            create: (context) => TransactionRepository(),
          ),
          RepositoryProvider(
            create: (context) => LocationRepository(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => LedgerBloc(
                RepositoryProvider.of<LedgerRepository>(context),
                RepositoryProvider.of<TransactionRepository>(context),
              )..add(GetLedgerEvent(0)),
            ),
            BlocProvider(
              create: (context) => AccountsBloc(
                RepositoryProvider.of<AccountRepository>(context),
                RepositoryProvider.of<TransactionRepository>(context),
              )..add(GetAccountsEvent()),
            ),
            BlocProvider(
              create: (context) => CategoriesBloc(
                RepositoryProvider.of<CategoryRepository>(context),
                RepositoryProvider.of<TransactionRepository>(context),
                RepositoryProvider.of<AccountRepository>(context),
              )..add(GetCategoriesEvent()),
            ),
          ],
          child: EasyLocalization(
            supportedLocales: appLocales.keys.toList(),
            path: 'assets/translations',
            fallbackLocale: Locale('en', 'US'),
            startLocale: Locale('en', ''),
            child: MyApp(),
          ),
        ),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionsBloc(
        BlocProvider.of<LedgerBloc>(context),
        RepositoryProvider.of<TransactionRepository>(context),
        RepositoryProvider.of<AccountRepository>(context),
        RepositoryProvider.of<CategoryRepository>(context),
        RepositoryProvider.of<LocationRepository>(context),
      )..add(GetTransactionsEvent(DateUtil.getCurrentMonth(DateTime.now()))),
      child: MaterialApp(
        title: 'Financy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          backgroundColor: AppColor.grey,
          brightness: Brightness.light,
          primaryColorLight: Color(0xffaddbff),
          primaryColor: Color(0xff76aae8),
          primaryColorDark: Color(0xff3f72af),
          accentColor: Color(0xff660198),
          errorColor: AppColor.red,
          dividerColor: AppColor.lightgrey,
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Color(0xff3f72af),
            foregroundColor: Colors.white,
          ),
          textTheme: TextTheme(
            headline1: GoogleFonts.openSans(fontSize: 30.0, color: Colors.black),
            headline2: GoogleFonts.openSans(fontSize: 23.0, color: Colors.black),
            headline3: GoogleFonts.openSans(fontSize: 20.0, color: Colors.black),
            bodyText1: GoogleFonts.openSans(fontSize: 14.0, color: Colors.black),
            bodyText2: GoogleFonts.openSans(fontSize: 12.0, color: Colors.black),
          ),
        ),
        initialRoute: AppRoute.homePage,
        onGenerateRoute: RouteGenerator.generateRoute,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
      ),
    );
  }
}


//* flutter pub run easy_localization:generate --source-dir ./assets/translations