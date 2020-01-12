import 'package:flutter/material.dart';
import 'package:maph_group3/util/nampr.dart';

import 'home.dart';

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
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    child: AnimatedIcon(
                      size: 200,
                      icon: AnimatedIcons.menu_home,
                      progress: _animationController,
                    ),
                    onTap: _onBackToHome,
                  ),
                ),
                Expanded(
                  child: Text('Bestellung abgeschlossen.'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() {
    // go back to product details
    var nav = Navigator.of(context);
    nav.pop();
    //nav.pop();
    return nav.maybePop();
  }

  Future<bool> _onBackToHome() {
    return Navigator.push(context, NoAnimationMaterialPageRoute(builder: (context) => Home()));
  }
}