import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/rendering.dart';

class UserGuide extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserGuideState();
  }
}

class _UserGuideState extends State<UserGuide> {
  _UserGuideState();
  @override
  Widget build(BuildContext context) {
    Widget imageCarousel = Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height - 80,
      child: Carousel(
        boxFit: BoxFit.contain,
        images: [
          AssetImage('assets/start.PNG'),
          AssetImage('assets/scann.PNG'),
          AssetImage('assets/us.PNG'),
          AssetImage('assets/userguide2.PNG'),
          AssetImage('assets/userguide3.PNG'),
          AssetImage('assets/userguide4.PNG'),
        ],
        autoplay: true,
        indicatorBgPadding: 10.0,
        //autoplayDuration: Duration(milliseconds:2000),
        //animationCurve: Curves.fastOutSlowIn,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('User Guide'),
      ),
      body: ListView(children: <Widget>[
        imageCarousel,
      ]),
    );
  }
}
