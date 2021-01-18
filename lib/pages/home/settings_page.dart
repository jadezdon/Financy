import 'package:Financy/blocs/settings/settings_bloc.dart';
import 'package:Financy/utils/constants.dart';
import 'package:Financy/widgets/error.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/route.dart';
import '../../config/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isShowDaySum = false;
  bool isShowDollarSign = false;
  int transactionNumber;
  int useTimeInDay;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        isShowDaySum = prefs.getBool(Constant.shp_showDaySum);
        isShowDollarSign = prefs.getBool(Constant.shp_showDollarSign);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsInitial) {
          return SizedBox.shrink();
        } else if (state is SettingsLoading) {
          // return Container(
          //   width: MediaQuery.of(context).size.width,
          //   height: MediaQuery.of(context).size.height,
          //   child: Center(child: CircularProgressIndicator()),
          // );
          return SizedBox.shrink();
        } else if (state is SettingsLoaded) {
          transactionNumber = state.transactionsNumber;
          useTimeInDay = state.useTimeInDay;
          return _buildPage(context);
        } else if (state is SettingsNotLoaded) {
          return ErrorContainer(msg: "Settings not loaded");
        }

        return ErrorContainer(msg: "No settings state");
      },
    );
  }

  Widget _buildPage(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context),
        SizedBox(height: 70),
        _buildSystemSettings(context),
        SizedBox(height: 20),
        _buildDisplaySettings(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    double cardHeight = 80;
    return Container(
      width: MediaQuery.of(context).size.width,
      height: cardHeight * 1.8,
      color: Theme.of(context).primaryColorLight,
      child: Stack(
        overflow: Overflow.visible,
        children: [
          Positioned(
            left: MediaQuery.of(context).size.width * 0.3 / 2,
            bottom: (-1) * cardHeight / 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: AppColor.darkBlue,
                  radius: cardHeight / 2.3,
                  child: Icon(Icons.face_retouching_natural, size: cardHeight / 2.3),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSize.borderRadius),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: cardHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          width: cardHeight / 2,
                          height: cardHeight / 2,
                          image: AssetImage("assets/images/transaction-number.png"),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "$transactionNumber",
                          style: TextStyle(fontSize: AppSize.fontLarge),
                        ),
                        SizedBox(width: 40),
                        Image(
                          width: cardHeight / 2,
                          height: cardHeight / 2,
                          image: AssetImage("assets/images/use-time.png"),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "$useTimeInDay " + tr("day"),
                          style: TextStyle(fontSize: AppSize.fontLarge),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSettings(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSize.pageMarginHori),
      color: Colors.white,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoute.manageCategoriesPage);
            },
            child: Container(
              height: AppSize.itemHeight,
              child: Row(
                children: [
                  Icon(Icons.category_outlined),
                  SizedBox(width: 10),
                  Expanded(child: Text(tr("manage categories"))),
                  Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
          Divider(height: 2),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoute.chooseLanguage);
            },
            child: Container(
              height: AppSize.itemHeight,
              child: Row(
                children: [
                  Icon(Icons.translate),
                  SizedBox(width: 10),
                  Expanded(child: Text(tr("language"))),
                  Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplaySettings(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSize.pageMarginHori),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: AppSize.itemHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr("show day sum")),
                Switch(
                  onChanged: (value) async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    setState(() {
                      prefs.setBool(Constant.shp_showDaySum, value);
                      isShowDaySum = value;
                    });
                  },
                  value: isShowDaySum,
                  activeColor: Theme.of(context).primaryColorDark,
                  activeTrackColor: Theme.of(context).primaryColorDark,
                ),
              ],
            ),
          ),
          Container(
            height: AppSize.itemHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tr("show values with dollar sign")),
                Switch(
                  onChanged: (value) async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    setState(() {
                      prefs.setBool(Constant.shp_showDollarSign, value);
                      isShowDollarSign = value;
                    });
                  },
                  value: isShowDollarSign,
                  activeColor: Theme.of(context).primaryColorDark,
                  activeTrackColor: Theme.of(context).primaryColorDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
