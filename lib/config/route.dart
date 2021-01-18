import 'package:Financy/pages/pick_date.dart';
import 'package:Financy/pages/pick_location.dart';
import 'package:Financy/pages/pick_month.dart';
import 'package:Financy/pages/settings/choose_language_page.dart';
import 'package:Financy/pages/settings/manage_categories_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../pages/add_account_page.dart';
import '../pages/add_category_page.dart';
import '../pages/add_ledger_page.dart';
import '../pages/home/add_transaction_page.dart';
import '../pages/home/home_page.dart';
import '../pages/take_picture_page.dart';
import 'theme.dart';

class AppRoute {
  static const String homePage = "/";
  static const String addTransactionPage = "/addTransaction";
  static const String takePicturePage = "/takePicture";
  static const String chooseLanguage = "/chooseLanguage";
  static const String addAccountPage = "/addAccount";
  static const String addCategoryPage = "/addCategory";
  static const String addLedgerPage = "/addLedger";
  static const String pickLocationPage = "/pickLocationPage";
  static const String manageCategoriesPage = "/manageCategoriesPage";
  static const String pickDatePage = "pickDatePage";
  static const String pickMonthPage = "pickMonthPage";
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case AppRoute.homePage:
        return PageTransition(
          type: PageTransitionType.fade,
          child: HomePage(),
        );
      case AppRoute.addTransactionPage:
        return PageTransition(
          type: PageTransitionType.fade,
          child: AddTransactionPage(transactionToEdit: args),
        );
      case AppRoute.takePicturePage:
        return PageTransition(
          child: TakePicturePage(imgUrl: args),
          type: PageTransitionType.rightToLeft,
        );
      case AppRoute.addAccountPage:
        return PageTransition(
          child: AddAccountPage(accountToEdit: args),
          type: PageTransitionType.bottomToTop,
        );
      case AppRoute.addCategoryPage:
        return PageTransition(
          child: AddCategoryPage(categoryToEdit: args),
          type: PageTransitionType.bottomToTop,
        );
      case AppRoute.addLedgerPage:
        return PageTransition(
          child: AddLedgerPage(ledger: args),
          type: PageTransitionType.bottomToTop,
        );
      case AppRoute.chooseLanguage:
        return PageTransition(
          child: ChooseLanguagePage(),
          type: PageTransitionType.rightToLeft,
        );
      case AppRoute.pickLocationPage:
        return PageTransition(
          child: PickLocationPage(location: args),
          type: PageTransitionType.rightToLeft,
        );
      case AppRoute.manageCategoriesPage:
        return PageTransition(
          child: ManageCategoriesPage(),
          type: PageTransitionType.rightToLeft,
        );
      case AppRoute.pickDatePage:
        return PageTransition(
          child: PickDatePage(initialDate: args),
          type: PageTransitionType.bottomToTop,
        );
      case AppRoute.pickMonthPage:
        return PageTransition(
          child: PickMonthPage(initialDate: args),
          type: PageTransitionType.bottomToTop,
        );
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          body: Center(
            child: Text(
              "Page not found",
              style: TextStyle(color: AppColor.red),
            ),
          ),
        );
      },
    );
  }
}
