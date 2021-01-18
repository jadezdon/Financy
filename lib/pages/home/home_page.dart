import 'package:Financy/blocs/filtered_transactions/filtered_transactions_bloc.dart';
import 'package:Financy/blocs/settings/settings_bloc.dart';
import 'package:Financy/blocs/transaction/transactions_bloc.dart';
import 'package:Financy/data/models/category_model.dart';
import 'package:Financy/data/repositories/account_repository.dart';
import 'package:Financy/data/repositories/category_repository.dart';
import 'package:Financy/data/repositories/location_repository.dart';
import 'package:Financy/data/repositories/transaction_repository.dart';
import 'package:Financy/utils/date_util.dart';

import '../../blocs/accounts/accounts_bloc.dart';
import '../../blocs/ledger/ledger_bloc.dart';
import '../../widgets/error.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/route.dart';
import '../../widgets/bottom_appbar_with_fab.dart';
import 'account_page.dart';
import 'settings_page.dart';
import 'stats_page.dart';
import 'transaction_list_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentMenuIndex = 0;
  Widget currentPage = TransactionListPage();

  AnimationController scaleController;
  Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350),
    )..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed) {
            scaleController.reverse();
            Navigator.pushNamed(context, AppRoute.addTransactionPage, arguments: null);
          }
        },
      );

    scaleAnimation = Tween<double>(begin: 1, end: 60).animate(scaleController);
  }

  @override
  void dispose() {
    scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LedgerBloc, LedgerState>(
      builder: (context, state) {
        if (state is LedgerLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is LedgerLoaded) {
          return _buildMainScaffold();
        } else if (state is LedgerNotLoaded) {
          return ErrorContainer(msg: "Ledger not loaded");
        } else if (state is LedgerInitial) {
          return SizedBox.shrink();
        }
        return ErrorContainer(msg: "Ledger no state");
      },
    );
  }

  Widget _buildMainScaffold() {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.vertical),
            currentPage,
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          scaleController.forward();
        },
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: scaleAnimation,
              builder: (context, child) => Transform.scale(
                scale: scaleAnimation.value,
                child: Container(
                  width: 70,
                  height: 70,
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).floatingActionButtonTheme.backgroundColor,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FabBottomAppBar(
        color: Colors.grey,
        selectedColor: Theme.of(context).accentColor,
        notchedShape: CircularNotchedRectangle(),
        items: [
          FabBottomAppBarItem(
            iconData: Icons.list_alt_outlined,
            text: tr("detail"),
          ),
          FabBottomAppBarItem(
            iconData: Icons.insert_chart_outlined,
            text: tr("stats"),
          ),
          FabBottomAppBarItem(
            iconData: Icons.account_balance_wallet_outlined,
            text: tr("account"),
          ),
          FabBottomAppBarItem(
            iconData: Icons.settings,
            text: tr("settings"),
          ),
        ],
        onTabSelected: (index) {
          setState(() {
            _currentMenuIndex = index;
            switch (_currentMenuIndex) {
              case 0:
                BlocProvider.of<TransactionsBloc>(context)
                  ..add(GetTransactionsEvent(DateUtil.getCurrentMonth(DateTime.now())));
                currentPage = TransactionListPage();
                break;
              case 1:
                currentPage = BlocProvider(
                  create: (context) => FilteredTransactionsBloc(
                    BlocProvider.of<LedgerBloc>(context),
                    RepositoryProvider.of<TransactionRepository>(context),
                    RepositoryProvider.of<AccountRepository>(context),
                    RepositoryProvider.of<CategoryRepository>(context),
                    RepositoryProvider.of<LocationRepository>(context),
                  )..add(GetFilteredTransactionsEvent(
                      DateUtil.getCurrentMonth(DateTime.now()),
                      TransactionType.EXPENSE,
                    )),
                  child: StatsPage(),
                );
                break;
              case 2:
                BlocProvider.of<AccountsBloc>(context).add(GetAccountsEvent());
                currentPage = AccountPage();
                break;
              case 3:
                currentPage = BlocProvider(
                  create: (context) => SettingsBloc(
                    RepositoryProvider.of<TransactionRepository>(context),
                  )..add(GetDataEvent()),
                  child: SettingsPage(),
                );
                break;
              default:
                currentPage = TransactionListPage();
            }
          });
        },
      ),
    );
  }
}
