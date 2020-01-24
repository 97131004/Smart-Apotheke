import 'package:flutter/material.dart';
import 'package:maph_group3/util/nampr.dart';
import 'package:maph_group3/widgets/calendar.dart';

import 'home.dart';

/// The class confirms the order at the end of the order workflow.
/// The user has the possibility to wether go back to Home or to go back to the
/// shop overview page.
class OrderConfirmation extends StatefulWidget {

  OrderConfirmation({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _OrderConfirmationState();
  }
}

class _OrderConfirmationState extends State<OrderConfirmation> with SingleTickerProviderStateMixin {

  AnimationController _animationController;

  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animationController.forward();
  }

  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  /// Build order confirmed text and animated icon.
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Bestellung abgeschlossen'),
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height/4, 0, 0),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildHomeButton(),
                _buildCalendarButton(),
                Expanded(
                  child: Text('Bestellung abgeschlossen.'),
                ),
              ],
            )
          ),
        ),
      ),
    );
  }

  /// Build animated icon.
  Widget _buildHomeButton() {
    return Expanded(
      child: GestureDetector(
        child: AnimatedIcon(
          size: 100,
          icon: AnimatedIcons.menu_home,
          progress: _animationController,
        ),
        onTap: _onBackToHome,
      ),
    );
  }

  Widget _buildCalendarButton() {
    return Expanded(
      child: GestureDetector(
        child: AnimatedIcon(
          size: 100,
          icon: AnimatedIcons.add_event,
          progress: _animationController,
        ),
        onTap: _onBackToCalendar,
      ),
    );
  }

  /// Build

  /// Method goes back 3 steps / pages.
  Future<bool> _onWillPop() {
    // go back to product details
    var nav = Navigator.of(context);
    nav.pop();
    nav.pop();
    return nav.maybePop();
  }

  /// Method goes back to Home page.
  Future<bool> _onBackToHome() {
    return Navigator.push(context, NoAnimationMaterialPageRoute(builder: (context) => Home()));
  }

  /// Method goes back to Calendar page.
  Future<bool> _onBackToCalendar() {
    return Navigator.push(
      context,
      NoAnimationMaterialPageRoute(
          builder: (context) => Calendar()),
    );
  }
}