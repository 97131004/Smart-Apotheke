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
          AssetImage('assets/home.jpg'),
          AssetImage('assets/Suche.PNG'),
          AssetImage('assets/suche1.jpg'),
          AssetImage('assets/home1.PNG'),
          AssetImage('assets/rezept_scannen.jpg'),
          AssetImage('assets/rezept_scannen1.jpg'),
          AssetImage('assets/home2.PNG'),
          AssetImage('assets/verlauf.jpg'),
          AssetImage('assets/verlauf1.jpg'),
          AssetImage('assets/Bestellen.jpg'),
          AssetImage('assets/Bestellen1.jpg'),
          AssetImage('assets/Check.PNG'),         
          AssetImage('assets/Daten.jpg'),
          AssetImage('assets/Daten1.jpg'),
          AssetImage('assets/Daten2.jpg'),
          AssetImage('assets/Bestellen2.jpg'),
          AssetImage('assets/Passwort.jpg'),
          AssetImage('assets/Abgeschlossen.jpg'),
          AssetImage('assets/home3.PNG'),
          AssetImage('assets/Kalender.jpg'),
          AssetImage('assets/Errinerung.jpg'),
         
          
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
