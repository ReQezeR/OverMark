import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:OverMark/databases/bookmark.dart';
import 'package:OverMark/databases/db_provider.dart';
import 'package:OverMark/pages/category_page.dart';
import 'package:OverMark/pages/detail_page.dart';
import 'package:OverMark/pages/home_page.dart';
import 'package:OverMark/pages/list_page.dart';
import 'package:OverMark/pages/settings_page.dart';
import 'package:OverMark/pages/web_page.dart';
import 'package:OverMark/themes/theme_options.dart';
import 'package:OverMark/tools/custom_pageview.dart';
import 'package:theme_provider/theme_provider.dart';


class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);
  final String title;
 
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final dbProvider = DbProvider.instance;
  ValueNotifier<double> _notifier = ValueNotifier<double>(1);
  AnimationController _indicatorController;
  NotifyingPageView customPageView;

  int _currentIndex = 1;
  int _targetIndex = 1;
  bool _isjump = false;
  bool isGradient = false;
  bool isInit= false;

  void toogleGradientState(){
    isGradient = !isGradient;
    setState(() {});
  }
  bool getGradientState(){
    return isGradient;
  }

  PageController pageController = PageController(
    initialPage: 1,
    keepPage: true,
  );

  @override
  void initState() {
    initPageView();
    _initAnimationController();
    super.initState();
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    _notifier?.dispose();
    super.dispose();
  }

  void updateTime(Bookmark b){
    String _date = new DateTime.now().toIso8601String();
    b.recentUpdate = _date;
    dbProvider.update(b.toMap(), 'Bookmarks');
  }

  void _initAnimationController(){
    _indicatorController = AnimationController(vsync: this, duration: Duration(milliseconds: 400));
  }

  void openWebPage(Bookmark bookmark) async{
    String url = bookmark.url.toString();
    var web = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ThemeConsumer(child: WebPage(url: url))));
    updateTime(bookmark);
    setState(() {});
  }

  void openCategoryPage(String categoryName, Function refresh) async{
    var category = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => ThemeConsumer(child: CategoryPage(db: dbProvider, categoryName: categoryName, openWebPage: openWebPage, openDetailPage: openDetailPage, getGradient: getGradient, isGradient: isGradient, refresh: refresh,))));
  }
  
  void openDetailPage(Bookmark bookmark, Function refresh) async{
    var detail = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ThemeConsumer(child: DetailPage(db:dbProvider, bookmark: bookmark, isGradient: isGradient, getGradient: getGradient, refresh: refresh,))));
    updateTime(bookmark);
    setState(() {});
  }


  void pageChanged(int index) {
    setState(() {
      _currentIndex = index;
      if(index == _targetIndex && _isjump == true){
        _targetIndex = index;
        _isjump = false;
      }
      else if(_isjump == false){
        _targetIndex = index;
      }
    });
  }

  void bottomTapped(int index) {
    setState(() {
      _targetIndex = index;
      _isjump = true;
      customPageView..navigateToPage(index);
    });
  }

  LinearGradient getGradient(int version){
    // light_gradient - 0
     // dark_gradient  - 1
    LinearGradient lightGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFFCF6EF), 
        Color(0xFFFCF6EF),
        Color(0xFFFCF6EF),
        Color(0xFFFCF6EF),
      ],
      stops: [
        0,
        0.6,
        0.9,
        1
      ],
    );
    LinearGradient darkGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF202750), 
        Color(0xFF203A43),
        Color(0xFF2C5364),
        Color(0xFF202750),
      ],
      stops: [
        0,
        0.4,
        0.9,
        1
      ],
    );

    if (version == 0){
      return lightGradient;
    }
    else if (version == 1){
      return darkGradient;
    }
    else return darkGradient;
  }

  double getOffset(int pageNumber){
    if(pageNumber == 0){
      if(_notifier.value<=0.5 && _notifier.value>=0.0){
        return _notifier.value;
      }
      else return 0.5;
    }
    else if(pageNumber == 1){
      if(_notifier.value<=1.5 && _notifier.value>0.5){
        return _notifier.value-pageNumber;
      }
      else if (_notifier.value>1.5) return 0.5;
      else if (_notifier.value<0.5) return -0.5;
      else return 0.0;
    }
    else if(pageNumber == 2){
      if(_notifier.value<=2.0 && _notifier.value>1.5){
        return _notifier.value-pageNumber;
      }
      else return -0.5;
    }
    print(_notifier.value);
    return 0.0;
  }

  void initPageView(){
    customPageView = NotifyingPageView(
      currentPage: _currentIndex,
      notifier: _notifier,
      pageChanged: pageChanged,
      pages: <Widget>[
        ThemeConsumer(child: ListPage(db: dbProvider, openWebPage: openWebPage, openDetailPage: openDetailPage)),
        ThemeConsumer(child:HomePage(db: dbProvider, openWebPage: openWebPage, openCategoryPage: openCategoryPage, openDetailPage: openDetailPage,)),
        ThemeConsumer(child:SettingsPage(db: dbProvider, toogleGradientState: toogleGradientState, getGradientState: getGradientState,)),
      ],
    );
  }

  BottomNavigationBarItem getCustomItem({int id, Color accent, Color detail, IconData icon, Color iconColor}){
    return BottomNavigationBarItem(
      title: Container(
        width: 40,
        height: 10,
        child: _currentIndex==id?AnimatedBuilder(
          animation: _notifier,
          builder: (context, _) {
            return Transform.translate(
              offset: Offset(15 * getOffset(id), -4),
              child:  Icon(
                Icons.expand_less,
                color: _targetIndex==id? iconColor: Colors.transparent,
                size: 15,
              ),
            );
          },
        ):Container(),
      ),
      icon: Padding(
        padding: const EdgeInsets.fromLTRB(0,10,0,0),
        child: _targetIndex==id?Icon(icon, color: iconColor,): Icon(icon, color: detail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color accent =  ThemeProvider.optionsOf<CustomThemeOptions>(context).accentIconColor;
    Color detail =  ThemeProvider.optionsOf<CustomThemeOptions>(context).defaultDetailColor;
    isInit?isInit = true:isGradient = ThemeProvider.optionsOf<CustomThemeOptions>(context).isGradientEnabled;
    isInit = true;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      body: InkWell(
        onTap: (){FocusScope.of(context).unfocus();},
        child: Container(
          decoration: isGradient?BoxDecoration(
            gradient: getGradient(ThemeProvider.themeOf(context).id == "dark_theme"?1:0),
          ):ThemeProvider.themeOf(context).id == "dark_theme"?BoxDecoration(
            color: Theme.of(context).primaryColor,
          ):BoxDecoration(
            color: ThemeProvider.optionsOf<CustomThemeOptions>(context).backgroundColor,
          ),
          child: Container(
            child: customPageView,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Theme.of(context).primaryColor,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedFontSize: 5.0,
        unselectedFontSize: 5.0,
        items: [
          getCustomItem(id: 0,accent: accent, detail: detail, icon: Icons.collections_bookmark, iconColor: Colors.blueAccent.withOpacity(0.8)),
          getCustomItem(id: 1,accent: accent, detail: detail, icon: Icons.home, iconColor: Colors.amber),
          getCustomItem(id: 2,accent: accent, detail: detail, icon: Icons.settings, iconColor: Colors.red),
        ],
        onTap: (index) {
          bottomTapped(index);
        },
      ),
    );
  }
}