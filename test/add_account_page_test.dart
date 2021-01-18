import 'package:Financy/blocs/accounts/accounts_bloc.dart';
import 'package:Financy/blocs/categories/categories_bloc.dart';
import 'package:Financy/blocs/ledger/ledger_bloc.dart';
import 'package:Financy/config/locales.dart';
import 'package:Financy/data/repositories/account_repository.dart';
import 'package:Financy/data/repositories/category_repository.dart';
import 'package:Financy/data/repositories/ledger_repository.dart';
import 'package:Financy/data/repositories/location_repository.dart';
import 'package:Financy/data/repositories/transaction_repository.dart';
import 'package:Financy/pages/add_account_page.dart';
import 'package:Financy/pages/home/add_transaction_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // testWidgets(
  //   "Test add transaction page validation",
  //   (WidgetTester tester) async {
  //     await tester.pumpWidget(MaterialApp(home: AddTransactionPage()));
  //     final okButton = find.byIcon(Icons.check);
  //     await tester.tap(okButton);
  //     expect(find.text("Please select a category"), findsOneWidget);
  //   },
  // );

  testWidgets(
    "Test add account page validation",
    (WidgetTester tester) async {
      await tester.pumpWidget(
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
              child: MaterialApp(
                home: AddAccountPage(accountToEdit: null),
              ),
            ),
          ),
        ),
      );
      final saveButton = find.byKey(Key("save"));
      await tester.tap(saveButton);
      expect(find.text("Name must not be empty"), findsOneWidget);
    },
  );
}
